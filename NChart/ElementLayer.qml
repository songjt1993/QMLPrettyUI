import QtQuick 2.15
import QtQml.Models 2.1
import "utils.js" as Utils

Rectangle {
    id: root
    signal toolTipMoved(var which, var value)
    required property var seriesModel
    required property var hAxis
    required property var vAxis
    required property var hOffset
    required property var vOffset
    color: "#00000000"
    clip: true
    width: 800
    height: 200

    Tooltip {
        id: static
        objectName: "staticTooltip"
        elementID: Utils.uuid()
        visible: false
        width: root.width/4
        height: root.height
        direction: true
        z: 19
    }

    Tooltip {
        id: dynamic
        objectName: "dynamicTooltip"
        elementID: Utils.uuid()
        visible: false
        width: root.width/4
        height: root.height
        direction: true
        z: 19
    }

    ObjectModel {
        id: elementModel
    }

    Repeater {
        id: elementView
        model: elementModel
    }

    MouseArea {
        property var startPos
        property var currentElement
        anchors.fill: parent
        hoverEnabled: true
        z: 20
        onPressed: {
            startPos = Qt.point(mouse.x, mouse.y)
            for (var i=0; i<elementModel.count; i++) {
                var item = elementModel.get(i)
                item.finish = false
            }
        }
        onReleased: {
            startPos = null
            currentElement = null
        }
        onPressAndHold: {
            if (startPos.x == mouse.x && startPos.y == mouse.y) {
                createElement(mapToValue(startPos.x), mapToValue(startPos.x))
            }
        }
        onClicked: {
            static.visible = true
            moveTooltip(static, mapToValue(mouse.x))
            toolTipMoved(static.objectName, static.value)
        }
        onPositionChanged: {
            if (startPos) {
                // 为了防止误操作
                if (Math.abs(startPos.x - mouse.x) < 10)
                    return
                if (currentElement) {
                    moveElement(currentElement, mapToValue(startPos.x), mapToValue(mouse.x))
                } else {
                    if (createElement(mapToValue(startPos.x), mapToValue(mouse.x)))
                        currentElement = elementModel.get(elementModel.count-1)
                }
            } else {
                moveTooltip(dynamic, mapToValue(mouse.x))
                toolTipMoved(dynamic.objectName, dynamic.value)
            }
        }
        onEntered: {
            dynamic.visible = true
        }
        onExited: {
            dynamic.visible = false
        }
    }

    function createElement(v_min, v_max) {
        var component = Qt.createComponent("Tag.qml")
        if (component.status == Component.Ready) {
            var item = component.createObject(root, {"elementID": Utils.uuid()})
            moveElement(item, v_min, v_max)
            item.z = 21
            elementModel.append(item)
            return item
        } else {
            console.log("fail to create tag")
            return null
        }
    }

    function getElement(_id) {
        for (var i=0; i<elementModel.count; i++) {
            var item = elementModel.get(i)
            if (item.elementID == _id) return item
        }
    }

    function moveElement(el, v_min, v_max) {
        el.range = [v_min, v_max]
        el.x = mapToPosition(v_min)
        if (v_min == v_max)
            el.width = 1
        else
            el.width = mapToPosition(v_max) - el.x
    }

    function getData(x) {
        var result = {}
        result[hAxis.name] = x.toFixed(2)
        for (var i=0; i<seriesModel.count; i++) {
            var series = seriesModel.get(i).obj
            var index = Utils.findNearest(x, series.points)
            if (series.points.length > index + 1 )
                result[series.name] = series.points[index].y.toString()
        }
        return result
    }

    function rePaint() {
        if (static.value) moveTooltip(static, static.value)
        for (var i=0; i<elementModel.count; i++) {
            var element = elementModel.get(i)
            moveElement(element, element.range[0], element.range[1])
        }
    }

    function moveTooltip(tp, value) {
        tp.value = value
        tp.x = mapToPosition(value)
        tp.update(root.getData(value))
        if (tp.x > root.width * 0.75)
            tp.direction = false
        else
            tp.direction = true
    }

    function mapToValue(pos) {
        return hAxis.mapToValue(pos + hOffset)
    }

    function mapToPosition(value) {
        return hAxis.mapToPosition(value) - hOffset
    }
}