function uuid() {
    var d = new Date().getTime();
    var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        var r = (d + Math.random()*16)%16 | 0;
        d = Math.floor(d/16);
        return (c=='x' ? r : (r&0x7|0x8)).toString(16);
    });
    return uuid;
}


function findNearest(value, points) {
    if (points.length <= 0) return null;
    var bgn = 0
    var end = points.length-1
    while (end > bgn) {
        var mid = Math.floor((bgn + end) / 2)
        if (value > points[mid].x) {
            bgn = mid + 1
        } else {
            end = mid - 1
        }
    }
    return bgn
}