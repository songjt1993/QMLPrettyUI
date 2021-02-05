import QtQuick 2.15
import QtQml.Models 2.1
import "valueaxis.js" as ValueAxis
import "lineseries.js" as LineSeries
import "utils.js" as Utils

Rectangle {
    id: root
    property var padding: {"top":50, "left":20, "bottom": 20, "right": 200}
    property var series: new Object()
    property alias plotArea: coordinate.plotArea
    property var showLegend: true
    property var showStatistics: false
    width: 1000
    height: 300

    ObjectModel {
        id: seriesModel
    }

    Text {
        anchors.top: parent.top
        anchors.topMargin: 5
        anchors.horizontalCenter: parent.horizontalCenter
        id: title
        text: "哈哈哈"
    }

    Legend {
        id: legend
        visible: showLegend
        anchors.right: parent.right
        anchors.left: coordinate.right
        anchors.top: coordinate.top
        anchors.bottom: coordinate.bottom
        onRightButtonPressed: {root.showLegend = false; showStatistics = true}
    }

    Statistics {
        id: statistics
        visible: showStatistics
        anchors.right: parent.right
        anchors.left: coordinate.right
        anchors.top: coordinate.top
        anchors.bottom: coordinate.bottom
        onRightButtonPressed: {root.showLegend = true; showStatistics = false}
    }

    Coordinate {
        id: coordinate
        x: parent.padding.left
        y: parent.padding.top
        width:  parent.width - parent.padding.left - parent.padding.right
        height: parent.height - parent.padding.top - parent.padding.bottom
    }

    Repeater {
        model: seriesModel
    }

    ElementLayer {
        seriesModel: seriesModel
        hAxis: coordinate.bottomAxis
        vAxis: coordinate.leftAxis
        hOffset: plotArea.left
        vOffset: plotArea.top
        anchors.left: coordinate.left
        anchors.leftMargin: plotArea.left
        anchors.top: coordinate.top
        anchors.topMargin: plotArea.top
        width: plotArea.width
        height: plotArea.height
        z: 10
    }

    Component.onCompleted: {
//        coordinate.bottomAxis = createValueAxis("bottom", plotArea)
//        coordinate.leftAxis = createValueAxis("left", plotArea)
    }

    onPlotAreaChanged: {
        for (var alignment of ["top", "bottom", "left", "right"]) {
            var axis = coordinate[alignment+"Axis"]
            if (axis) {
                changeAxisRange(alignment, axis.range[0], axis.range[1])
            }
        }
    }

    function changeAxisRange(alignment, min, max) {
        var axis = coordinate[alignment+"Axis"]
        axis.range = [min, max]
        axis.calFactor(axis.range[0], axis.range[1], root.plotArea)
        axis.adjust()
        rePaint()
    }

    function rePaint() {
        coordinate.rePaint()
        for (var i=0; i<seriesModel.count; i++){
            var cvs = seriesModel.get(i)
            cvs.markDirty(Qt.rect(0, 0, cvs.width, cvs.height))
        }
    }

    function createValueAxis(alignment) {
        var axis = new ValueAxis.ValueAxis(alignment)
        axis.calFactor(axis.range[0], axis.range[1], root.plotArea)
        axis.adjust()
        coordinate[alignment+"Axis"] = axis
    }

    function addSeries(xAlignment, yAlignment, name) {
        var s = new LineSeries.LineSeries()
        s.hAxis = coordinate[xAlignment+"Axis"]
        s.vAxis = coordinate[yAlignment+"Axis"]
        s.name = name
        var component = Qt.createComponent("Series.qml")
        if (component.status == Component.Ready) {
            var item = component.createObject(root,{
                "obj": s,
                "x": Qt.binding(function() {return root.padding.left}),
                "y": Qt.binding(function() {return root.padding.top}),
                "width":  Qt.binding(function() {return root.width - root.padding.left - root.padding.right}),
                "height": Qt.binding(function() {return root.height - root.padding.top - root.padding.bottom})
            })
            seriesModel.insert(0, item)
            // 添加legend
            legend.addLegend({
                "lineType": "solidLine",
                "_color": s.color,
                "name": s.name,
            })
            // 添加statistic
            statistics.update({
                "_color": s.color,
                "name": s.name,
            })
        } else {
            console.log("fail to create " + series)
        }
    }

    function updateStatistic(obj) {
        statistics.update(obj)
    }

    function addPoints(name, points) {
        for (var i=0; i<seriesModel.count; i++){
            var cvs = seriesModel.get(i)
            if (cvs.obj.name == name) {
                cvs.obj.points.push.apply(cvs.obj.points, points)
                cvs.requestPaint()
                break
            }
        }
    }

    function replacePoints(name, points) {
        for (var i=0; i<seriesModel.count; i++){
            var cvs = seriesModel.get(i)
            if (cvs.obj.name == name) {
                cvs.obj.points=points
                cvs.requestPaint()
                break
            }
        }
    }
}