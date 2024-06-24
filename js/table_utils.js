function object2tr(obj, addClass=false, ...properties) {
    let cells;
    if(addClass){
        cells = properties.map(x => `<td class="${x}">${obj[x]}</td>`);
    }else{
        cells = properties.map(x => `<td>${obj[x]}</td>`);
    }

    return `<tr>${cells}</tr>`;
}