% include('header.tpl', page_title='IndexedDB', include_jquery=True)

        <script src="/js/table_utils.js"></script>
        <script>
            const API_ENDPOINT = "{{!api_endpoint}}";

            function makeValueCell(record){
                if(!record["is_long_record"]){
                    return $(`<td style="max-width: 50vw; word-wrap: break-word;"></td>`).text(record["value"])
                }else{
                    return $(`<td style="max-width: 50vw; word-wrap: break-word;"></td>`).append(
                        $("<a></a>")
                        .attr("href", `/indexeddb/single-record?host={{host}}&db=${record["db_number"]}&objstore=${record["objstore_number"]}&seq=${record["leveldb_seq_no"]}`)
                        .text("Long Record")
                    );
                }
            }

            $(document).ready(() => {
                //let tablebody = $("#table_body");
                $.ajax(API_ENDPOINT)
                .done(data => {
                    if(data["success"]){
                        $("#db-cell").text(data["results"]["db_name"]);
                        $("#objstore-cell").text(data["results"]["objstore_name"]);
                        $("#seq-cell").text(data["results"]["leveldb_seq_no"]);
                        $("#key-cell").text(data["results"]["key"]);
                        $("#value-cell").text(data["results"]["value"]);

                        // let recordsDiv = $("#records-box");
                        // let template = document.querySelector("#record-table-template");
                        // let table = $(template.content.cloneNode(true));
                        // table.find("caption").text(`${data["results"]["db_name"]}/${data["results"]["objstore_name"]}`);
                        // let tableBody = table.find("tbody");
                        //         tableBody.append(
                        //             data["results"]["records"].map(x => 
                        //                 $("<tr></tr>").append(
                        //                     $("<td></td>").text(x["leveldb_seq_no"]),
                        //                     $("<td></td>").text(x["is_deletion_record"]),
                        //                     $(`<td style="max-width: 40vw; word-wrap: break-word;"></td>`).text(x["key"]),
                        //                     makeValueCell(x)
                        //                 )
                        //             )
                        //         );
                        // recordsDiv.append(table);
                    } else{
                        $("error_box").text(data["error"]);
                    }
                });
            });
        </script>

        <h1 id="main-title">IndexedDB {{host}}</h1>
        <div id="error_box"></div>
        <table class="standard-table smaller-text">
            <tr><th scope="row">Database</th><td id="db-cell"></td></tr>
            <tr><th scope="row">Object Store</th><td id="objstore-cell"></td></tr>
            <tr><th scope="row">LevelDB Sequence No.</th><td id="seq-cell"></td></tr>
            <tr><th scope="row">Key</th><td id="key-cell"></td></tr>
            <tr><th scope="row">Value</th><td id="value-cell"></td></tr>
        </table>

% include('footer.tpl')