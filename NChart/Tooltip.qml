import QtQuick 2.15

Canvas {
    width: 300
    height: 100
    id: root
    required property var elementID
    property var direction: true
    property var halfW: 1
    property var textColor: "Blue"
    onPaint: {
        var ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)
        ctx.beginPath()
        ctx.strokeStyle = textColor
        ctx.lineWidth = halfW * 2
        ctx.lineCap = "round"
        ctx.moveTo(halfW, halfW)
        ctx.lineTo(halfW, height-halfW)
        ctx.stroke()
    }

    ListModel {
        id: tooltipModel
    }

    Column {
        id: tooltipView
        anchors.left: parent.left
        anchors.leftMargin: halfW * 4
        anchors.right: parent.left
        anchors.rightMargin: parent.width - halfW * 4
        Repeater {
            model: tooltipModel
            Text {
                anchors.right: parent.right
                anchors.left: parent.left
                color: textColor
                text: name + ": " + value
                horizontalAlignment: root.direction?Text.AlignLeft:Text.AlignRight
            }
        }
    }

    onDirectionChanged: {
        root.requestPaint()
        if (root.direction) {
            tooltipView.anchors.left = root.left
            tooltipView.anchors.leftMargin = halfW * 4
            tooltipView.anchors.right = root.left
            tooltipView.anchors.rightMargin = root.width - halfW * 4
        } else {
            tooltipView.anchors.right = root.left
            tooltipView.anchors.rightMargin = halfW * 4
            tooltipView.anchors.left = root.left
            tooltipView.anchors.leftMargin = root.width - halfW * 4
        }
    }

    function update(obj) {
        tooltipModel.clear()
        for (var name in obj) {
            tooltipModel.append({"name": name, "value": obj[name]})
        }
    }
}