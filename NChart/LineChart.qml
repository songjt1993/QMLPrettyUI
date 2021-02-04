import QtQuick 2.15
import "linechart.js" as JS

Rectangle {
    id: root
    property var padding: {"top":20, "left":20, "bottom": 20, "right": 20}
    property var series: []
    property alias plotArea: coordinate.plotArea
    width: 1000
    height: 300
    Coordinate {
        id: coordinate
        x: parent.padding.left
        y: parent.padding.top
        width:  parent.width - parent.padding.left - parent.padding.right
        height: parent.height - parent.padding.top - parent.padding.bottom
    }

    Repeater {
        id: seriesContainer
        model: 0
        Series {
            obj: root.series[index]
            x: parent.padding.left
            y: parent.padding.top
            width:  parent.width - parent.padding.left - parent.padding.right
            height: parent.height - parent.padding.top - parent.padding.bottom
        }
    }

    Component.onCompleted: {
        coordinate.bottomAxis = JS.createValueAxis("bottom", plotArea)
        coordinate.leftAxis = JS.createValueAxis("left", plotArea)
        JS.addSeries("bottomAxis", "leftAxis", "aa")
    }
}