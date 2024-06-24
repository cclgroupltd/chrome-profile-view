"""
Copyright 2024 CCL Forensics Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the “Software”), to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
"""

import io
import mimetypes
import pathlib
import sys
import typing
import zlib
import gzip
import brotli
import hashlib

import bottle

import ccl_chromium_reader.ccl_chromium_profile_folder
from ccl_chromium_reader.ccl_chromium_history import HistoryRecord
from ccl_chromium_reader.ccl_chromium_localstorage import LocalStorageRecord, LocalStorageBatch
from ccl_chromium_reader.ccl_chromium_sessionstorage import SessionStoreValue
from ccl_chromium_reader.ccl_chromium_cache import CacheKey
from ccl_chromium_reader import ChromiumProfileFolder

__version__ = "0.0.5"
__description__ = "Web app for previewing data in a Chrome Profile Folder"
__contact__ = "Alex Caithness"

PORT = 40539

app = bottle.Bottle(catchall=False)
profile: typing.Optional[ChromiumProfileFolder] = None


def local_storage_record_to_dict(record: LocalStorageRecord, batch: LocalStorageBatch):
    batch_ts = batch.timestamp if batch.timestamp is not None else ""
    return {
        "leveldb_seq_no": record.leveldb_seq_number,
        "storage_key": record.storage_key,
        "script_key": record.script_key,
        "value": record.value if record.value is not None else "",
        "is_deletion_record": not record.is_live,
        "batch_timestamp": str(batch_ts)
    }


def session_storage_record_to_dict(record: SessionStoreValue):
    return {
        "leveldb_seq_no": record.leveldb_sequence_number,
        "host": record.host,
        "key": record.key,
        "value": record.value if record.value is not None else "",
        "is_deletion_record": record.is_deleted,
    }


def cache_result_to_dict(record: ccl_chromium_reader.ccl_chromium_profile_folder.CacheResult):
    result = {
        "key": {
            "raw": record.key.raw_key,
            "url": record.key.url,
            "site": record.key.isolation_key_top_frame_site,
            "key_index": record.duplicate_key_index
        }
    }

    if record.metadata is not None:
        attributes = {}
        for k, v in record.metadata.http_header_attributes:
            attributes.setdefault(k, [])
            attributes[k].append(v)

        content_type = record.metadata.get_attribute("content-type")
        likely_image = content_type and content_type[0].startswith("image")

        result["metadata"] = {
            "request_time": str(record.metadata.request_time),
            "response_time": str(record.metadata.response_time),
            "metadata_location": f"{record.metadata_location.file_name}; offset: {record.metadata_location.offset}",
            "data_location": f"{record.data_location.file_name}; offset: {record.data_location.offset}",
            "attributes": attributes,
            "declarations": list(record.metadata.http_header_declarations),
            "likely_image": likely_image
        }
    else:
        result["metadata"] = {}

    return result


def history_record_to_dict(rec: HistoryRecord):
    return {
        "id": rec.rec_id,
        "title": rec.title,
        "url": rec.url,
        "timestamp": str(rec.visit_time),
        "visit_duration": rec.visit_duration.total_seconds(),
        "transition_core": rec.transition.core.name,
        "transition_qualifiers": [x.name for x in rec.transition.qualifier],
        "parent_visit_id": rec.from_visit_id if rec.from_visit_id else rec.opener_visit_id
    }


@app.route("/api/sessionstorage/hosts")
def api_sessionstorage_hosts_route():
    return {"success": True, "results": sorted(profile.iter_session_storage_hosts())}


@app.route("/api/sessionstorage/records")
def api_sessionstorage_records_route():
    host = bottle.request.query.host
    if not host:
        return {"success": False, "error": "No records for this host"}

    try:
        return {
            "success": True,
            "results": list(session_storage_record_to_dict(x) for x in sorted(
                    profile.iter_session_storage(
                        host=host, include_deletions=True, raise_on_no_result=True),
                    key=lambda x: x.leveldb_sequence_number))
        }
    except KeyError:
        return {"success": False, "error": "No records for this host"}


@app.route("/api/localstorage/hosts")
def api_localstorage_hosts_route():
    return {"success": True, "results": sorted(profile.iter_local_storage_hosts())}


@app.route("/api/localstorage/records")
def api_localstorage_records_route():
    host = bottle.request.query.host
    if not host:
        return {"success": False, "error": "No records for this host"}

    try:
        return {
            "success": True,
            "results": list(
                local_storage_record_to_dict(rec, batch) for rec, batch in sorted(
                    profile.iter_local_storage_with_batches(
                        host, None, include_deletions=True, raise_on_no_result=True),
                    key=lambda x: x[0].leveldb_seq_number))}
    except KeyError:
        return {"success": False, "error": "No records for this host"}


@app.route("/api/cache")
def api_cache_records_route():
    return {
        "success": True,
        "results": list(cache_result_to_dict(x) for x in profile.iterate_cache(None, omit_cached_data=True))
    }


@app.route("/api/history")
def api_history_records_route():
    return {
        "success": True,
        "results": list(history_record_to_dict(x) for x in profile.iterate_history_records())
    }


@app.route("/api/historychain")
def api_history_chain_route():
    record_id = int(bottle.request.query.id)
    record = profile.history.get_record_with_id(record_id)
    if record is None:
        return {"success": False, "error": "No history record with that visit ID"}

    while True:
        parent = record.get_parent()
        if parent is None:
            break
        record = parent

    root = {"record": history_record_to_dict(record), "children": []}
    stack = [(record.get_children().__iter__(), root)]

    while stack:
        iterator, current = stack[-1]
        try:
            next_item = next(iterator)
        except StopIteration:
            stack.pop()
            continue

        next_item_dict = {"record": history_record_to_dict(next_item), "children": []}
        current["children"].append(next_item_dict)
        stack.append((next_item.get_children().__iter__(), next_item_dict))

    return {
        "success": True,
        "results": root
    }


@app.route("/localstorage")
@bottle.view("localstorage")
def localstorage_route():
    return {"profile_path": profile.path.resolve(), "version": __version__}


@app.route("/localstorage/records")
@bottle.view("localstorage_records")
def localstorage_records_route():
    return {
        "host": bottle.request.query.host,
        "api_endpoint": f"/api/localstorage/records?host={bottle.request.query.host}",
        "profile_path": profile.path.resolve(), "version": __version__
    }


@app.route("/sessionstorage")
@bottle.view("sessionstorage")
def localstorage_route():
    return {"profile_path": profile.path.resolve(), "version": __version__}


@app.route("/sessionstorage/records")
@bottle.view("sessionstorage_records")
def localstorage_records_route():
    return {
        "host": bottle.request.query.host,
        "api_endpoint": f"/api/sessionstorage/records?host={bottle.request.query.host}",
        "profile_path": profile.path.resolve(), "version": __version__
    }


@app.route("/cache")
@bottle.view("cache")
def cache_route():
    return {
        "api_endpoint": f"/api/cache",
        "profile_path": profile.path.resolve(), "version": __version__
    }


@app.route("/cache-resource")
def cache_resource_route():
    key = bottle.request.query.key
    idx = bottle.request.query.idx

    if not key:
        bottle.response.status = 400
        return "no key given"

    try:
        idx = int(idx)
    except ValueError:
        bottle.response.status = 400
        return "idx is not a number"

    data_hits = profile.cache.get_cachefile(key)
    meta_hits = profile.cache.get_metadata(key)

    if len(data_hits) != len(meta_hits):
        raise ValueError("Data and metadata lengths do not match")

    if idx >= len(data_hits):
        bottle.response.status = 400
        return "no record with this index"

    data = data_hits[idx]
    meta = meta_hits[idx]

    parsed_key = CacheKey(key)
    #file_name = pathlib.PurePosixPath(urllib.parse.urlparse(parsed_key.url).path).name
    content_encoding = (meta.get_attribute("content-encoding") or [""])[0]

    if data is not None:
        if content_encoding.strip() == "gzip":
            data = gzip.decompress(data)
        elif content_encoding.strip() == "br":
            data = brotli.decompress(data)
        elif content_encoding.strip() == "deflate":
            data = zlib.decompress(data, -zlib.MAX_WBITS)  # suppress trying to read a header
        elif content_encoding.strip() != "":
            print(f"Warning: unknown content-encoding: {content_encoding}")

    out_extension = ""
    if mime := meta.get_attribute("content-type"):
        out_extension = mimetypes.guess_extension(mime[0]) or ""

    file_name = hashlib.sha256(data or b"").hexdigest() + out_extension

    headers = {
        "Content-Type": "application/octet-stream",
        "Content-Length": str(len(data or b"")),
        "Content-Disposition": f"attachment; filename={file_name}"
    }

    response = bottle.HTTPResponse(
        body=io.BytesIO(data),
        status=200, **headers
    )

    return response


@app.route("/history")
@bottle.view("history")
def history_route():
    return {
        "api_endpoint": f"/api/history",
        "profile_path": profile.path.resolve(), "version": __version__
    }


@app.route("/historychain")
@bottle.view("historychain")
def history_route():
    return {
        "api_endpoint": f"/api/historychain?id={bottle.request.query.id}",
        "rec_id": bottle.request.query.id,
        "profile_path": profile.path.resolve(), "version": __version__
    }


@app.route("/")
@bottle.view("index.tpl")
def index_route():
    return {"profile_path": profile.path.resolve(), "version": __version__}


@app.route("/js/<filename>")
def serve_js(filename):
    return bottle.static_file(filename, root="./js")


@app.route("/style/<filename>")
def serve_style(filename):
    return bottle.static_file(filename, root="./style")


def main(args):
    in_path = pathlib.Path(args[0])

    global profile
    profile = ChromiumProfileFolder(in_path)

    launch_message = f"Point your browser to http://localhost:{PORT}"
    print()
    print(f"+{'-' * (len(launch_message) + 2)}+")
    print(f"| {launch_message} |")
    print(f"+{'-' * (len(launch_message) + 2)}+")
    print()

    bottle.run(app, host="localhost", port=PORT, debug=True)


if __name__ == '__main__':
    main(sys.argv[1:])
