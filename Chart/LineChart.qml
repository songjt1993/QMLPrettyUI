import QtQuick 2.15
import QtQml.Models 2.15

Rectangle {
    id: root
    width: 540;
    height: 400;
    property alias plotAreaOffset: coordinate.plotAreaOffset
    property alias plotArea: coordinate.plotArea
    property alias xTick: coordinate.xTick
    property alias yTick: coordinate.yTick
    property var xRange: [0, 1000]
    property var yRange: [0, 1000]
    property var offset: [50, 5, 5, 200] // 上下左右的留白
    property var xTickStrategy: [0, 100, 10] // 锚点，最小间隔，tick数量
    property var yTickStrategy: [0, 300, 3]
    property var dynamicObjects: new Object()

    Text {
        id: title
        text: "帧率统计"
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Text {
        id: xLabel
        text: "时间[s]"
        horizontalAlignment: Text.AlignHCenter
        width: plotArea.width
        anchors.bottom: parent.bottom
        anchors.leftMargin: plotAreaOffset[2] + offset[2]
        anchors.left: parent.left
    }

    Text {
        id: yLabel
        text: "帧率[f/s]"
        width: plotArea.height
        horizontalAlignment: Text.AlignHCenter
        anchors.top: parent.top
        anchors.topMargin: plotAreaOffset[0] + offset[0]
        anchors.left: parent.left
        anchors.leftMargin: height
        transform: Rotation { origin.x: 0; origin.y: 0; angle: 90}
    }

    MouseArea {
        x: offset[0]
        y: offset[2]
        width: plotArea.width + plotAreaOffset[2] + plotAreaOffset[3]
        height: plotArea.height + plotAreaOffset[0] + plotAreaOffset[1]
        onPressed: {
            root.xRange = [0, 2000]
            clearCanvas()
        }
    }

    Coordinate {
        id: coordinate
        type: "continuous"
    }

    Column {
        anchors.left: parent.right
        anchors.leftMargin: -offset[3]
        anchors.top: parent.top
        anchors.topMargin: offset[0]
        Repeater {
            id: legendGroup
            model: 0
            Legend {
                text: {var keys = Object.keys(dynamicObjects); return dynamicObjects[keys[modelData]].name}
                clr: {var keys = Object.keys(dynamicObjects); return dynamicObjects[keys[modelData]].color}
                width: 100
                height: 20
                visible: true
            }
        }
    }

    onXRangeChanged: {
        root.xTick = adjustTick(root.xTickStrategy, root.xRange)
    }

    onYRangeChanged: {
        root.yTick = adjustTick(root.yTickStrategy, root.yRange)
    }

    function mapToPosition(x, y) {
        var posX = plotArea.left + (x-xRange[0]) / (xRange[1] - xRange[0]) * plotArea.width
        var posY = plotArea.bottom - (y-yRange[0]) / (yRange[1] - yRange[0]) * plotArea.height
        return [posX.toFixed(), posY.toFixed()]
    }

    function addPoints(series, points) {
        var obj = dynamicObjects[series]
        obj.points.push.apply(obj.points, points)
        obj.requestPaint()
    }

    function addSeries(series, type, color, lineWidth) {
        if (type="lineSeries") {
            var component = Qt.createComponent("LineSeries.qml")
            if (component.status == Component.Ready) {
                dynamicObjects[series] = component.createObject(root, {"color": color, "lineWidth": lineWidth, "name":series})
                legendGroup.model = Object.keys(dynamicObjects).length
            } else {
                console.log("fail to create " + series)
            }
        }
    }

    function clearCanvas() {
        coordinate.markDirty(Qt.rect(0, 0, coordinate.width, coordinate.height))
        for (var series in dynamicObjects) {
            var cvs = dynamicObjects[series]
            cvs.markDirty(Qt.rect(0, 0, cvs.width, cvs.height))
            console.log(Qt.rect(0, 0, cvs.width, cvs.height))
        }
    }

    function adjustTick(strategy, range) {
        var minInterval = (range[1] - range[0]) / strategy[2]
        // 计算真正的interval
        var realInterval = strategy[1]
        while (minInterval > realInterval) {
            realInterval = realInterval * 2
        }
        while (minInterval < realInterval) {
            realInterval = realInterval / 2
        }
        // 查找第一的anchor
        var firstTick = strategy[0]
        if (strategy[0] > range[0]) {
            firstTick = strategy[0] - realInterval * Math.floor((strategy[0] - range[0]) / realInterval)
        } else {
            firstTick = Math.ceil((range[0] - strategy[0]) / realInterval) * realInterval + strategy[0]
        }

        var tick = []
        for (var i=0; i<strategy[2]+1; i++) {
            tick.push(firstTick + i * realInterval)
        }
        return tick
    }
}