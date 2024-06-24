% include('header.tpl', page_title='History', include_jquery=True)

        <script src="/js/table_utils.js"></script>
        <script>
            const API_ENDPOINT = "{{api_endpoint}}";
            $(document).ready(() => {
                let tablebody = $("#table_body");
                $.ajax(API_ENDPOINT)
                .done(data => {
                    if(data["success"]){
                        tablebody.append(
                            data["results"].map(x =>{
                                x["combined_transition"] = `${x["transition_core"]} (${x["transition_qualifiers"].join(" / ")})`;
                                x["chain"] = `<a href="/historychain?id=${x["id"]}">⛓️</a>`;
                                return object2tr(x, addClass=true, "chain", "id", "title", "url", "timestamp", "visit_duration", "combined_transition", "parent_visit_id");
                            })
                        );
                    } else{
                        $("error_box").text(data["error"]);
                    }
                    //max-width: 50vw; word-wrap: break-word
                    $("#table_body .url").css("max-width", "50vw").css("word-wrap", "break-word");
                });
            });
        </script>
        <h1>History</h1>
        <div id="error_box"></div>
        <table class="standard-table">
            <thead>
                <tr>
                    <th>Chain</th>
                    <th>Visit ID</th>
                    <th>Title</th>
                    <th>URL</th>
                    <th>Timestamp</th>
                    <th>Visit Duration (s)</th>
                    <th>Transition</th>
                    <th>Parent Visit ID</th>
                </tr>
            </thead>
            <tbody id="table_body">

            </tbody>
        </table>

% include('footer.tpl')