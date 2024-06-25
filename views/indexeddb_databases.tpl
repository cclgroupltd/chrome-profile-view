% include('header.tpl', page_title='IndexedDB', include_jquery=True)

        <script src="/js/table_utils.js"></script>
        <script>
            const API_ENDPOINT = "{{api_endpoint}}";
            $(document).ready(() => {
                //let tablebody = $("#table_body");
                let databases_list = $("#databases_list");
                $.ajax(API_ENDPOINT)
                .done(data => {
                    if(data["success"]){
                        databases_list.append(
                            data["results"].map(x => 
                                $("<li></li>").text(x["db_name"]).append(
                                    $("<ul></ul>").append(x["object_stores"].map(y =>
                                        $("<li></li>").append(
                                            $("<a></a>")
                                            .attr("href", `/indexeddb/records?host={{host}}&db=${x["db_number"]}&objstore=${y["objstore_number"]}`)
                                            .text(y["objstore_name"]))
                                    ))
                                )
                            )
                        );
                    } else{
                        $("error_box").text(data["error"]);
                    }
                });
            });
        </script>
        <h1>IndexedDB: {{host}}</h1>
        <div id="error_box"></div>
        <ul id="databases_list"></ul>

% include('footer.tpl')