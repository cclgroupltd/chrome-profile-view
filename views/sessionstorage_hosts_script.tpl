$(document).ready(() => {
                let ul = $("{{selector}}");
                $.ajax("/api/sessionstorage/hosts")
                .done(data => {
                    if(data["success"]){
                        ul.append(data["results"].map(x => `<li><a href="/sessionstorage/records?host=${x}">${x}</a></li>`))
                    } else{
                        $("error_box").text(data["error"]);
                    }
                });
            });