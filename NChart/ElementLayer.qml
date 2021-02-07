import QtQuick 2.15
import QtQml.Models 2.1
import "utils.js" as Utils

Rectangle {
    id: root
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
        elementID: Utils.uuid()
        visible: false
        width: root.width/4
        height: root.height
        direction: true
        z: 19
    }

    Tooltip {
        id: dynamic
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
                var component = Qt.createComponent("Tag.qml")
                if (component.status == Component.Ready) {
                    var item = component.createObject(root, {"elementID": Utils.uuid()})
                    item.range = [hAxis.mapToValue(startPos.x + hOffset), hAxis.mapToValue(startPos.x + hOffset)]
                    moveElement(item, startPos.x, 1)
                    item.z = 21
                    elementModel.append(item)
                } else {
                    console.log("fail to create tag")
                }
            }
        }
        onClicked: {
            static.visible = true
            static.value = hAxis.mapToValue(mouse.x + hOffset)
            moveTooltip(static, mouse.x)
        }
        onPositionChanged: {
            if (startPos) {
                // 为了防止误操作
                if (Math.abs(startPos.x - mouse.x) < 10)
                    return
                if (currentElement) {
                    currentElement.range = [hAxis.mapToValue(startPos.x + hOffset), hAxis.mapToValue(mouse.x + hOffset)]
                    moveElement(currentElement, startPos.x, mouse.x - startPos.x)
                } else {
                    var component = Qt.createComponent("Tag.qml")
                    if (component.status == Component.Ready) {
                        var item = component.createObject(root, {"elementID": Utils.uuid()})
                        item.range = [hAxis.mapToValue(startPos.x + hOffset), hAxis.mapToValue(mouse.x + hOffset)]
                        item.z = 21
                        moveElement(item, startPos.x, mouse.x - startPos.x)
                        elementModel.append(item)
                        currentElement = item
                    } else {
                        console.log("fail to create tag")
                    }
                }
            } else {
                dynamic.value = hAxis.mapToValue(mouse.x + hOffset)
                moveTooltip(dynamic, mouse.x)
            }
        }
        onEntered: {
            dynamic.visible = true
        }
        onExited: {
            dynamic.visible = false
        }
    }

    function getElement(_id) {
        for (var i=0; i<elementModel.count; i++) {
            var item = elementModel.get(i)
            if (item.elementID == _id) return item
        }
    }

    function getData(pos) {
        var x = hAxis.mapToValue(pos)
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
        if (static.value) moveTooltip(static, hAxis.mapToPosition(static.value) - hOffset)
        for (var i=0; i<elementModel.count; i++) {
            var element = elementModel.get(i)
            var pos = hAxis.mapToPosition(element.range[0]) - hOffset
            if (element.range[0] == element.range[1])
                moveElement(element, pos, 1)
            else
                moveElement(element, pos, hAxis.mapToPosition(element.range[1]) - hOffset - pos)
        }
    }

    function moveElement(el, pos, width) {
        el.width = width
        el.x = pos
    }

    function moveTooltip(tp, pos) {
        tp.x = pos
        tp.update(root.getData(pos+hOffset))
        if (pos > root.width * 0.75)
            tp.direction = false
        else
            tp.direction = true
    }
}