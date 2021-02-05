import QtQuick 2.15
import QtQml.Models 2.1
import "utils.js" as Utils

Rectangle {
    id: root
    property var xAxis
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
                    item.width = 1
                    item.x = mouse.x
                    item.z = 21
                    elementModel.append(item)
                } else {
                    console.log("fail to create tag")
                }
            }
        }
        onClicked: {
            static.visible = true
            static.x = mouse.x
            static.update({"time": 6, "fps": 60})
            if (mouse.x > root.width * 0.75)
                static.direction = false
            else
                static.direction = true
        }
        onPositionChanged: {
            if (startPos) {
                // 为了防止误操作
                if (Math.abs(startPos.x - mouse.x) < 10)
                    return
                if (currentElement) {
                    currentElement.width = mouse.x - startPos.x
                    currentElement.x = startPos.x
                } else {
                    var component = Qt.createComponent("Tag.qml")
                    if (component.status == Component.Ready) {
                        var item = component.createObject(root, {"elementID": Utils.uuid()})
                        item.width = mouse.x - startPos.x
                        item.x = startPos.x
                        item.z = 21
                        elementModel.append(item)
                        currentElement = item
                    } else {
                        console.log("fail to create tag")
                    }
                }
            } else {
                dynamic.x = mouse.x
                dynamic.update({"time": 6, "fps": 60})
                if (mouse.x > root.width * 0.75)
                    dynamic.direction = false
                else
                    dynamic.direction = true
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
}