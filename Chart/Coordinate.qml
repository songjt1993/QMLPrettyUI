import QtQuick 2.15


Canvas {
    renderStrategy: Canvas.Cooperative
    renderTarget: Canvas.FramebufferObject
    x: parent.offset[2]
    y: parent.offset[0]
    width: parent.width - parent.offset[2] - parent.offset[3]
    height: parent.height - parent.offset[0] - parent.offset[1]
    property var plotArea: Qt.rect(plotAreaOffset[2],
                                   plotAreaOffset[0],
                                   width-plotAreaOffset[2]-plotAreaOffset[3],
                                   height-plotAreaOffset[0]-plotAreaOffset[1])
    property var plotAreaOffset: [15, 30, 40, 15] // 上下左右的留白
    property var xTick: [0, 200, 400, 600, 800]
    property var yTick: [0, 300, 600, 900]
    property var type: "continuous" // "discrete"

    onPaint: {
        var ctx = getContext("2d")
//        console.log(x, y, 333)
        ctx.clearRect(0,0,width,height)
        ctx.beginPath()
        ctx.moveTo(plotArea.left, plotArea.bottom)
        ctx.lineTo(plotArea.left, plotArea.top)
        ctx.moveTo(plotArea.left, plotArea.bottom)
        ctx.lineTo(plotArea.right, plotArea.bottom)
        ctx.stroke()
        drawArrow(plotArea.left, plotArea.top, 15, "u")
        drawArrow(plotArea.right, plotArea.bottom, 15, "r")

        for (var i=0; i<xTick.length; i++) {
            var pos = parent.mapToPosition(xTick[i], 0)
//            console.log(xTick[i], 0)
            drawTick(pos[0], plotArea.bottom, 15, "r")
        }

        for (var i=0; i<yTick.length; i++) {
            var pos = parent.mapToPosition(0, yTick[i])
            drawTick(plotArea.left, pos[1], 15, "u")
        }
    }

    Repeater {
        id: xTickText
        model: xTick
        Text {
            text: modelData
            horizontalAlignment: Text.AlignHCenter
            width: plotAreaOffset[3]
            x: {var pos = root.mapToPosition(modelData, 0);return pos[0]-width/2}
            y: plotArea.bottom + 5
        }
    }

    Repeater {
        id: yTickText
        model: yTick
        Text {
            text: modelData
            horizontalAlignment: Text.AlignRight
//            width: plotAreaOffset[3]
            anchors.right: parent.left
            anchors.rightMargin: - plotAreaOffset[2] + 5
            y: {var pos = root.mapToPosition(0,modelData);return pos[1]-height/2}
        }
    }

    function drawArrow(x, y, length, direction) {
        var ctx = getContext("2d")
        ctx.beginPath()
        if (direction == "r") {
            ctx.moveTo(x+length, y)
            ctx.lineTo(x, y-length/3)
            ctx.lineTo(x, y+length/3)
        } else if (direction == "u") {
            ctx.moveTo(x, y-length)
            ctx.lineTo(x-length/3, y)
            ctx.lineTo(x+length/3, y)
        }
        ctx.closePath()
        ctx.fill()
    }

    function drawTick(x, y, length, direction) {
        var ctx = getContext("2d")
        ctx.beginPath()
        if (direction == "r") {
            ctx.moveTo(x, y)
            ctx.lineTo(x, y-length/3)
        } else if (direction == "u") {
            ctx.moveTo(x, y)
            ctx.lineTo(x+length/3, y)
        }
        ctx.stroke()
    }
}