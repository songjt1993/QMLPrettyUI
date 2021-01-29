import QtQuick 2.15

Rectangle {
    id: root
    property color clr: "purple"
    property var text: "dsafsadf"
    visible: false
    Rectangle {
        id: icon
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        color: root.clr
        width: 30
        height: 2
    }
    Text {
        text: root.text
        color: root.clr
        anchors.left: parent.left
        anchors.leftMargin: icon.width + 10
        anchors.verticalCenter: parent.verticalCenter
    }
}