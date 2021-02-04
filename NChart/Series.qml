import QtQuick 2.15

Canvas {
    renderStrategy: Canvas.Cooperative
    renderTarget: Canvas.FramebufferObject
    property var obj: null
    onPaint: {
        if (obj) {
            var ctx = getContext("2d")
            obj.draw(ctx)
        }
    }
}