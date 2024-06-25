% include('header.tpl', page_title='Cache', include_jquery=True)

        <script src="/js/table_utils.js"></script>
        <script>
            const API_ENDPOINT = "{{api_endpoint}}";
            
            
            function buildHeaders(declarations, attributes){
                let lines = [];
                if(declarations !== null && declarations !== undefined){
                    for(let dec of declarations){
                        lines.push(dec);
                    }
                }

                if(attributes !== null && attributes !== undefined){
                    let keys = Object.keys(attributes).sort()
                    for(let key of keys){
                        for(let value of attributes[key]){
                            lines.push(`${key}: ${value}`);
                        }
                    }
                }

                return lines.join("\n");
            }

            function makePreviewImage(record){
                let url = `/cache-resource?key=${encodeURIComponent(record["key"]["raw"])}&idx=${encodeURIComponent(record["key"]["key_index"])}`
                return record["metadata"]["likely_image"] ? `<a href="${url}"><img style="max-width: 33vw; max-height: 100vh;" src="${url}"></a>` : ""
            }

            $(document).ready(() => {
                let tablebody = $("#table_body");
                $.ajax(API_ENDPOINT)
                .done(data => {
                    if(data["success"]){
                        tablebody.append(
                            data["results"].map(x =>
                                $("<tr></td>").data("rawkey", x["key"]["raw"]).data("keyidx", x["key"]["key_index"]).append(
                                    $("<td></td>").append($("<a>💾</a>").attr("href", `/cache-resource?key=${encodeURIComponent(x["key"]["raw"])}&idx=${encodeURIComponent(x["key"]["key_index"])}`)),
                                    $(`<td style="max-width: 50vw; word-wrap: break-word;"></td>`).text(x["key"]["url"]),
                                    $("<td></td>").text(x["key"]["site"]),
                                    $("<td></td>").text(x["metadata"]["request_time"]),
                                    $("<td></td>").text(x["metadata"]["response_time"]),
                                    $("<td></td>").text(x["metadata"]["metadata_location"]),
                                    $("<td></td>").text(x["metadata"]["data_location"]),
                                    $(`<td style="font-size: 0.7rem; white-space: pre-line; max-width: 50vw; word-wrap: break-word;"></td>`).text(buildHeaders(x["metadata"]["declarations"], x["metadata"]["attributes"])),
                                    $(`<td>${makePreviewImage(x)}</td>`)

                                )    
                            )
                        );
                    } else{
                        $("error_box").text(data["error"]);
                    }
                });
            });
        </script>
        <h1>Cache</h1>
        <div id="error_box"></div>
        <table class="standard-table" style="table-layout: fixed; width: max-content;">
            <thead>
                <tr>
                    <th></th>
                    <th>URL</th>
                    <th>Site</th>
                    <th>Request Time</th>
                    <th>Response Time</th>
                    <th>Metadata Location</th>
                    <th>Data Location</th>
                    <th>HTTP Header Fields</th>
                    <th>Image Preview</th>

                </tr>
            </thead>
            <tbody id="table_body" class="smaller-text">

            </tbody>
        </table>

% include('footer.tpl')