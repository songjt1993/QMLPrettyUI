import QtQuick 2.15

Rectangle {
    id: images
    color: "lightBlue"
    property var dalpha: 0
    Repeater {
        model: 10
        CustomImage {
            property var name: "green"
            alpha: index * Math.PI / 12 - Math.PI / 2
            color: "green"
            Text {
                anchors.centerIn: parent
                text: "image-"+index
            }
        }
    }
    Rectangle {
        id: last
        z: 1000
        width: 10
        height: 10
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        color: "blue"
        MouseArea {
            anchors.fill: parent
            onClicked: {
                anim.to = dalpha - Math.PI / 12
                anim.running = true
            }
        }
    }
    Rectangle {
        id: next
        z: 1000
        width: 10
        height: 10
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        color: "blue"
        MouseArea {
            anchors.fill: parent
            onClicked: {
//                aaa.move(Math.PI / 12)
                anim.to = dalpha +Math.PI / 12
                anim.running = true
            }
        }
    }
    NumberAnimation on dalpha {
        id: anim
        duration: 500
    }
}