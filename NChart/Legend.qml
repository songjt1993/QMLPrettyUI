import QtQuick 2.15

Rectangle {
    id: root
    signal itemPressed(var obj)
    signal rightButtonPressed(var p)
    width: 200
    height: 500
    Component {
        id: simplify
        Row {
            spacing: 5
            Canvas {
                id: mark
                width: 20
                height:parent.height
                onPaint: {
                    var ctx = getContext("2d")
                    if (lineType == "solidLine") {
                        ctx.beginPath()
                        ctx.strokeStyle = _color
                        ctx.strokeWidth = 2
                        ctx.moveTo(0, height/2)
                        ctx.lineTo(width, height/2)
                        ctx.stroke()
                    }
                }
            }
            Text {
                color: _color
                text: name
            }
        }
    }

    ListModel {
        id: legendModel
    }

    ListView {
        id: legendView
        anchors.fill: parent
        model: legendModel
        spacing: 5
        delegate: simplify
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: {
            if (mouse.button == Qt.LeftButton) {
                root.itemPressed(legendView.indexAt(mouse.x, mouse.y))
            } else if (mouse.button == Qt.RightButton) {
                root.rightButtonPressed(mouse.x, mouse.y)
            }
        }
    }

    function addLegend(obj) {
        legendModel.insert(legendModel.count, obj)
    }
}