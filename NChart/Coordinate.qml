import QtQuick 2.15

Canvas {
    property var padding: {"top":15, "left":15, "bottom": 15, "right": 15}
    property var plotArea: Qt.rect(padding.left, padding.top, width-padding.left-padding.right, height-padding.top-padding.bottom)
    property var topAxis: null
    property var bottomAxis: null
    property var leftAxis: null
    property var rightAxis: null
    onPaint: {
        var ctx = getContext("2d")
        if (topAxis) topAxis.draw(ctx, plotArea)
        if (bottomAxis) bottomAxis.draw(ctx, plotArea)
        if (leftAxis) leftAxis.draw(ctx, plotArea)
        if (rightAxis) rightAxis.draw(ctx, plotArea)
    }

    // 标签
    Repeater {
        id: topLabel
        model: topAxis?topAxis.tick.marks:[]
        Text {
            color: topAxis.color
            text: modelData.label
            x: modelData.position-width/2
            y: plotArea.top - topAxis.tick.length - height
        }
    }
    Repeater {
        id: leftLabel
        model: leftAxis?leftAxis.tick.marks:[]
        Text {
            color: leftAxis.color
            text: modelData.label
            x: plotArea.left - width - leftAxis.tick.length
            y: modelData.position - height / 2
        }
    }
    Repeater {
        id: bottomLabel
        model: bottomAxis?bottomAxis.tick.marks:[]
        Text {
            color: bottomAxis.color
            text: modelData.label
            x: modelData.position-width/2
            y: plotArea.bottom + bottomAxis.tick.length
        }
    }

    Repeater {
        id: rightLabel
        model: rightAxis?rightAxis.tick.marks:[]
        Text {
            color: rightAxis.color
            text: modelData.label
            x: plotArea.right + rightAxis.tick.length
            y: modelData.position - height / 2
        }
    }


}