import QtQuick 2.15
import QtQml.Models 2.1
import "linechart.js" as JS

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
        coordinate.bottomAxis = JS.createValueAxis("bottom", plotArea)
        coordinate.leftAxis = JS.createValueAxis("left", plotArea)
        JS.addSeries("bottomAxis", "leftAxis", "aa")
    }
}