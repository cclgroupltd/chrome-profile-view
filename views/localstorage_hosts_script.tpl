$(document).ready(() => {
                let ul = $("{{selector}}");
                $.ajax("/api/localstorage/hosts")
                .done(data => {
                    if(data["success"]){
                        ul.append(data["results"].map(x => `<li><a href="/localstorage/records?host=${x}">${x}</a></li>`))
                    } else{
                        $("error_box").text(data["error"]);
                    }
                });
            });