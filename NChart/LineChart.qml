import QtQuick 2.15
import QtQml.Models 2.1
import "valueaxis.js" as ValueAxis
import "lineseries.js" as LineSeries

Rectangle {
    id: root
    property var padding: {"top":20, "left":20, "bottom": 20, "right": 20}
//    property var series: []
    property var series: new Object()
    property alias plotArea: coordinate.plotArea
    width: 1000
    height: 300

    ObjectModel {
        id: seriesModel
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

    Component.onCompleted: {
//        coordinate.bottomAxis = createValueAxis("bottom", plotArea)
//        coordinate.leftAxis = createValueAxis("left", plotArea)
//        addSeries("bottomAxis", "leftAxis", "aa")
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
            var item = component.createObject(root,
            {
                "obj": s,
                "x": root.padding.left,
                "y": root.padding.top,
                "width":  root.width - root.padding.left - root.padding.right,
                "height": root.height - root.padding.top - root.padding.bottom
            }
            )
            seriesModel.insert(0, item)
        } else {
            console.log("fail to create " + series)
        }
    }

    function addPoints(name, points) {
        for (var i; i<seriesModel.count; i++){
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