import QtQuick 2.15
import QtGraphicalEffects 1.12
Rectangle {
    id: container
    width: 1000
    height: 500
    property list<CustomImage> imgs
    property var unit: Math.PI / 6
    property var dalpha: 0

    ConicalGradient {
        width: parent.width;
        height: parent.height;
        angle: 0;
        verticalOffset: 0.3 * parent.height
        gradient: Gradient {
            GradientStop{ position: 0.0; color: "#000000";}
            GradientStop{ position: 0.10; color: "#181818";}
            GradientStop{ position: 0.26; color: "#363636";}
            GradientStop{ position: 0.28; color: "#181818";}
            GradientStop{ position: 0.5; color: "#000000";}
            GradientStop{ position: 0.72; color: "#181818";}
            GradientStop{ position: 0.74; color: "#363636";}
            GradientStop{ position: 0.90; color: "#181818";}
            GradientStop{ position: 1; color: "#000000";}
        }
    }


    SmoothedAnimation on dalpha {
        id: anim
        velocity: 0.5
    }

    RectangularGlow {
        id: effect
        anchors.fill: undefined
        glowRadius: 15
        spread: 0.2
        color: "white"
        cornerRadius: glowRadius
    }

    Rectangle {
        id: last
        z: 1000
        width: 50
        height: 50
        radius: 25
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 10
        anchors.left: parent.left
        color: "#00000000"
        Image {
            anchors.fill: parent
            source: "./res/last.png"
        }
        MouseArea {
            anchors.fill: parent
            onClicked: runAnimation(dalpha - container.unit)
        }
    }
    Rectangle {
        id: next
        z: 1000
        width: 50
        height: 50
        radius: 25
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 10
        color: "#00000000"
        Image {
            anchors.fill: parent
            source: "./res/next.png"
        }
        MouseArea {
            anchors.fill: parent
            onClicked: runAnimation(dalpha + container.unit)
        }
    }

    MouseArea {
        anchors.fill: parent
        onWheel: {
            runAnimation(dalpha + (wheel.angleDelta.y > 0 ? container.unit : - container.unit))
        }
    }

    function addImage(imgPath) {
        var component = Qt.createComponent("CustomImage.qml")
        var img = component.createObject(container, {
            alpha: - unit * imgs.length,
            source: imgPath ? imgPath : "./res/noImage.png",
            index: imgs.length
        })
        img.draged.connect(changeDAlpha)
        img.droped.connect(runAnimation)
        img.selected.connect(selectImg)
        imgs.push(img)
    }

    function runAnimation(a) {
        anim.stop()
        anim.to = a
        anim.running = true
    }

    function changeDAlpha(da) {
        dalpha = da
    }

    function selectImg(index) {
        effect.anchors.fill = imgs[index]
        effect.z = Qt.binding(function () {return imgs[index].z - 0.1})
        effect.visible = Qt.binding(function () {return imgs[index].visible})
    }
}