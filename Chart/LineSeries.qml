import QtQuick 2.15

Canvas {
    renderStrategy: Canvas.Cooperative
    renderTarget: Canvas.FramebufferObject
    x: parent.offset[2]
    y: parent.offset[0]
    width: parent.width - parent.offset[2] - parent.offset[3]
    height: parent.height - parent.offset[0] - parent.offset[1]
    property var points:[]
    property var color: "black"
    property var lineWidth: 2
    property var name: ""
    onPaint: {
//        console.log(x,y,"7777")
        if (points.length >= 2) {
            var ctx = getContext("2d")
            ctx.clearRect(0,0,width,height)
            ctx.strokeStyle = color
            ctx.lineWidth = lineWidth
            ctx.beginPath()
            var pos = parent.mapToPosition(points[0].x, points[0].y)
//            console.log(pos)
            ctx.moveTo(pos[0], pos[1])
            for (var i=1; i<points.length; i++) {
                var pos = parent.mapToPosition(points[i].x, points[i].y)
                ctx.lineTo(pos[0], pos[1])
            }
            ctx.stroke()
        }
    }
}