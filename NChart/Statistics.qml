import QtQuick 2.15

Rectangle {
    id: root
    width: 200
    height: 500
    signal itemPressed(var obj)
    signal rightButtonPressed(var p)
    Component {
        id: detail
        Column {
            Text {
                color: _color
                text: "  latest: "+realTime+unit
            }
            Text {
                color: _color
                text: "  average: "+average+unit
            }
            Text {
                color: _color
                text: "  minimum: "+min+unit
            }
            Text {
                color: _color
                text: "  maximum: "+max+unit
            }
        }
    }

    ListModel {
        id: statisticsModel
    }

    ListView {
        id: statisticsView
        anchors.fill: parent
        model: statisticsModel
        spacing: 5
        delegate: detail
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: {
            if (mouse.button == Qt.LeftButton) {
                root.itemPressed(statisticsView.indexAt(mouse.x, mouse.y))
            } else if (mouse.button == Qt.RightButton) {
                root.rightButtonPressed(mouse.x, mouse.y)
            }
        }
    }

    function update(obj) {
        for (var i=0; i<statisticsModel.count; i++){
            if (statisticsModel.get(i).name = obj.name) {
                statisticsModel.set(i, obj)
                return
            }
        }
        statisticsModel.append(obj)
    }
}