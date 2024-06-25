function object2tr(obj, addClass=false, ...properties) {
    let cells;
    if(addClass){
        cells = properties.map(x => $("<td></td>").attr("class", "x").text(obj[x]));
    }else{
        cells = properties.map(x => $("<td></td>").text(obj[x]));
    }
    return $("<tr></tr>").append(cells);
}