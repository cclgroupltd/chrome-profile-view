% include('header.tpl', page_title='Local Storage', include_jquery=True)

        <script src="/js/table_utils.js"></script>
        <script>
            const API_ENDPOINT = "{{api_endpoint}}";
            $(document).ready(() => {
                let tablebody = $("#table_body");
                $.ajax(API_ENDPOINT)
                .done(data => {
                    if(data["success"]){
                        tablebody.append(
                            data["results"].map(x =>
                                object2tr(x, false, "leveldb_seq_no", "batch_timestamp", "is_deletion_record", "script_key", "value")
                            )
                        );
                    } else{
                        $("error_box").text(data["error"]);
                    }
                });
            });
        </script>
        <h1>Local Storage: {{host}}</h1>
        <div id="error_box"></div>
        <table class="standard-table">
            <thead>
                <tr>
                    <th>LevelDB Sequence No.</th>
                    <th>Batch Timestamp</th>
                    <th>Is Deletion Record</th>
                    <th>Script Key</th>
                    <th>Value</th>
                </tr>
            </thead>
            <tbody id="table_body">

            </tbody>
        </table>

% include('footer.tpl')