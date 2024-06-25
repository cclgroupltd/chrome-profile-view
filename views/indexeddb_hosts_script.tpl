$(document).ready(() => {
                let ul = $("{{selector}}");
                $.ajax("/api/indexeddb/hosts")
                .done(data => {
                    if(data["success"]){
                        ul.append(data["results"].map(x => `<li><a href="/indexeddb/databases?host=${x}">${x}</a></li>`))
                    } else{
                        $("error_box").text(data["error"]);
                    }
                });
            });