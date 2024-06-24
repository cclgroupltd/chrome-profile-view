% include('header.tpl', page_title='History', include_jquery=True, include_d3=True)

        <script src="/js/table_utils.js"></script>
        <script>
            const API_ENDPOINT = "{{api_endpoint}}";

            const NODE_DISPLAY_ATTRIBUTES = {
                "id": "ID",
                "title": "Title",
                "url": "URL",
                "timestamp": "Timestamp",

            }

            function walkTree(entry, visitFunc, depth=1){
                if(entry === null || entry === undefined){
                    return;
                }

                visitFunc(entry, depth);

                for(let inner of entry["children"]){
                    walkTree(inner, visitFunc, depth + 1);
                }
            }

            function truncateString(value, maxFieldLength, truncationMarker){
                return value.length > maxFieldLength
                    ? value.substring(0, maxFieldLength) + truncationMarker
                    : value;
            }

            function getMaximums(entry, maxFieldLength, truncationMarker){
                let widths = [];  // highest width for each depth
                let depthCardinality = [];  // how many nodes at each depth
                let maxWidth = 0;

                walkTree(entry, (e, d) => {
                    if(widths.length < d){
                        widths.push(0);
                    }

                    if(depthCardinality.length < d){
                        depthCardinality.push(0);
                    }

                    // Render elements to get calculated size
                    for(let attributeProperty in NODE_DISPLAY_ATTRIBUTES){
                        let valueString = truncateString(entry["record"][attributeProperty], maxFieldLength, truncationMarker);
                        let tempNode = $(`<span>${NODE_DISPLAY_ATTRIBUTES[attributeProperty]}: ${valueString}</span>`)
                            .addClass("nodeText")
                            .css({"visibility": "hidden", "white-space": "nowrap"})
                            .appendTo($("body"));
                        let width = tempNode.width();
                        if(width > widths[d - 1]){
                            widths[d - 1] = width
                        }
                        maxWidth = Math.max(width, maxWidth);
                        
                        tempNode.remove();
                    }

                    depthCardinality[d - 1] += 1;
                });
                
                return {"widths": widths, "depthCardinality": depthCardinality, "maxWidth": maxWidth};

            }
            
            function buildGraph(data){
                const fontSize = 14;
                const maxFieldLength = 192;
                const truncationMarker = "[...]";
                let maximums = getMaximums(data, maxFieldLength, truncationMarker);
                let totalMaxes = maximums.widths.reduce((a, b) => a + b, 0);
                const width = (maximums.maxWidth * 2.2) * maximums.depthCardinality.length;
                const attribute_count = Object.keys(NODE_DISPLAY_ATTRIBUTES).length;

                // Compute the tree height; this approach will allow the height of the
                // SVG to scale according to the breadth (width) of the tree layout.
                const root = d3.hierarchy(data);
                
                const dx = 3 + fontSize * (1 + attribute_count);
                const dy = maximums.maxWidth * 2.2;

                const height = dx * Math.max(...maximums.depthCardinality)  * (1 + attribute_count);

                // Create a tree layout.
                const tree = d3.tree().nodeSize([dx, dy]);
                //const tree = d3.tree().size([width, height]);

                // Sort the tree and apply the layout.
                tree(root);

                // Compute the extent of the tree. Note that x and y are swapped here
                // because in the tree layout, x is the breadth, but when displayed, the
                // tree extends right rather than down.
                let x0 = Infinity;
                let x1 = -x0;
                root.each(d => {
                    if (d.x > x1) x1 = d.x;
                    if (d.x < x0) x0 = d.x;
                });

                // Compute the adjusted height of the tree.
                //const height = x1 - x0 + dx * 8;

                const svg = d3.create("svg")
                    .attr("width", width)
                    .attr("height", height)
                    .attr("viewBox", [-maximums.maxWidth, -(height / 2), width + maximums.maxWidth * 1.5, height * 1.2])
                    .attr("style", `max-width: 100%; height: auto; font: ${fontSize}px sans-serif;`);

                const link = svg.append("g")
                    .attr("fill", "none")
                    .attr("stroke", "#555")
                    .attr("stroke-opacity", 0.4)
                    .attr("stroke-width", 1.5)
                    .selectAll()
                    .data(root.links())
                    .join("path")
                        .attr("d", d3.linkHorizontal()
                            .x(d => d.y)
                            .y(d => d.x));
                
                const node = svg.append("g")
                    .attr("stroke-linejoin", "round")
                    .attr("stroke-width", 3)
                    .selectAll()
                    .data(root.descendants())
                    .join("g")
                    
                    .attr("id", d => d.data.record["id"])
                    .attr("transform", d => `translate(${d.y},${d.x})`);

                node.append("circle")
                    .attr("fill", d => d.children ? "#555" : "#999")
                    .attr("r", 2.5);
                
                let value_offset = 1;
                for(let attrib in NODE_DISPLAY_ATTRIBUTES){
                    node.append("text")
                    .attr("dy", `${value_offset}em`)
                    .attr("text-anchor", "middle")
                    .text(d => truncateString(d.data.record[attrib], maxFieldLength, truncationMarker))
                    .attr("stroke", "white")
                    .attr("paint-order", "stroke");
                    value_offset += 1;
                }
                
                return svg.node();
                
                

            }
            
            $(document).ready(() => {
                //let tablebody = $("#table_body");
                $.ajax(API_ENDPOINT)
                .done(data => {
                    if(data["success"]){
                        let svg = buildGraph(data["results"]);
                        let graphBox = $("#graph_box");
                        
                        graphBox.width(Math.ceil(svg.width.baseVal.value));
                        graphBox.append(svg);
                        
                        $("#{{rec_id}}")[0].scrollIntoView({"block": "center", "inline": "center"})

                    } else{
                        $("error_box").text(data["error"]);
                    }
                });
            });
        </script>
        <h1>History</h1>
        <div id="error_box"></div>
        <div id="graph_box"></div>

% include('footer.tpl')