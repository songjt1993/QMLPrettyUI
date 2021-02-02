import QtQuick 2.15

Canvas {
    renderStrategy: Canvas.Cooperative
    renderTarget: Canvas.FramebufferObject
    x: parent.offset[2]
    y: parent.offset[0]
    width: parent.width - parent.offset[2] - parent.offset[3]
    height: parent.height - parent.offset[0] - parent.offset[1]
    property var points:[]
    property var renderPoints:[]
    property var color: "black"
    property var lineWidth: 2
    property var name: ""
    property var downSamplingInterval: 1
    onPaint: {
        draw()
    }

    function draw() {
        var tstamp=new Date().getTime()
//        console.log(points.length)
        if (points.length >= 2) {
            var ctx = getContext("2d")
            ctx.clearRect(0,0,width,height)
            ctx.strokeStyle = color
            ctx.lineWidth = lineWidth
            ctx.beginPath()
            var pos = parent.mapToPosition(points[0].x, points[0].y)
            ctx.moveTo(pos[0], pos[1])
            var tmpy = [pos[1]]
            var tmpx = pos[0]
            for (var i=1; i<points.length; i++) {
                var pos = parent.mapToPosition(points[i].x, points[i].y)
                ctx.lineTo(pos[0], pos[1])
            }
            ctx.stroke()
        }
//        console.log("ms", new Date().getTime() - tstamp)
    }

    function mapToPosition(x, y) {
        var posX = plotArea.left + (x-parent.xRange[0]) * 0.3
        var posY = plotArea.bottom - (y-parent.yRange[0]) * 0.3
        return [posX, posY]
    }

    function downSampling() {
        var bgn = findNearest(parent.xRange[0])
        var end = findNearest(parent.xRange[1])
        renderPoints = []
//        console.log(points.length, bgn, end)
        for (var i=bgn; i<=end; i++) {
            var pos = parent.mapToPosition(points[i].x, points[i].y)
            if (renderPoints.length > 0 && pos[0] == renderPoints[renderPoints.length-1][0]) {
                if (pos[1] < renderPoints[renderPoints.length-2][1]) renderPoints[renderPoints.length-2]=pos;
                if (pos[1] > renderPoints[renderPoints.length-1][1]) renderPoints[renderPoints.length-1]=pos;
            } else {
                renderPoints.push(pos)
                renderPoints.push(pos)
            }
        }
        console.log(renderPoints.length)
    }

    function findNearest(value) {
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
}