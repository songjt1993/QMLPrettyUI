import QtQuick 2.15

Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        property var alpha: 0
        x: {(Math.sin(alpha+parent.dalpha)+1) * parent.width / 2 - 100}
        z: width
        width: {200 * (1 - Math.abs(0.5 * (1+Math.sin(alpha+parent.dalpha)) - 0.5))}
        height: {100 * (1 - Math.abs(0.5 * (1+Math.sin(alpha+parent.dalpha)) - 0.5))}
        color: "red"
    }