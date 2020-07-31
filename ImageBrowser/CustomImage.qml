import QtQuick 2.15
import QtGraphicalEffects 1.12

Image {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height * 0.2
        signal draged(var dalpha)
        signal droped(var dalpha)
        signal selected(var flg)
        property var alpha: 0
        property var index
        x: {(Math.sin(alpha+parent.dalpha)+1) * parent.width / 2 - width / 2}
        z: height
//        width: {200 * (1 - Math.abs(0.5 * (1+Math.sin(alpha+parent.dalpha)) - 0.5))}
        height: {parent.height * 0.6 * (1 - Math.abs(0.5 * (1+Math.sin(alpha+parent.dalpha)) - 0.5))}
        source: "noImage"
        fillMode: Image.PreserveAspectFit

        ShaderEffect {
            anchors.top: parent.bottom
            width: parent.width
            height: parent.height
            anchors.left: parent.left

            property variant source: parent
            property size sourceSize: Qt.size(0.5 / parent.width, 0.5 / parent.height)

            fragmentShader: "
                varying highp vec2 qt_TexCoord0;
                uniform lowp sampler2D source;
                uniform lowp vec2 sourceSize;
                uniform lowp float qt_Opacity;
                void main() {

                    lowp vec2 tc = qt_TexCoord0 * vec2(1, -1) + vec2(0, 1);
                    lowp vec4 col = 0.25 * (texture2D(source, tc + sourceSize)
                                            + texture2D(source, tc- sourceSize)
                                            + texture2D(source, tc + sourceSize * vec2(1, -1))
                                            + texture2D(source, tc + sourceSize * vec2(-1, 1))
                                           );
                    gl_FragColor = col * qt_Opacity * (1.0 - qt_TexCoord0.y) * 0.2;
                }"
        }

        onXChanged: {
            if (alpha+parent.dalpha <= - Math.PI / 2 || alpha+parent.dalpha >= Math.PI / 2) {
                visible = false
            } else {
                visible = true
            }
        }

        MouseArea {
            property var pressedX
            property var operation
            acceptedButtons: Qt.LeftButton
            anchors.fill: parent
            hoverEnabled: true
            onPressed: {
                pressedX = mouse.x
                selected(index)
            }
            onReleased: {
                if (operation == "doubleClicked") {
                    parent.droped(-parent.alpha)
                } else if (operation == "drag") {
                    parent.droped(parent.normalizeX(mouse.x-pressedX+parent.x))
                }
                pressedX = undefined
                operation = undefined
            }
            onPositionChanged: {
                if (pressedX) {
                    operation = "drag"
                    parent.draged(parent.calDAlpha(mouse.x-pressedX+parent.x))
                }
            }
            onDoubleClicked: {
                operation = "doubleClicked"
            }
//            onEntered: {
//
//            }
        }

        function calDAlpha(x) {
            var tmp = Math.asin((x + width / 2) * 2 / parent.width - 1)-alpha
            return tmp
        }

        function normalizeX(x) {
            var tmp = calDAlpha(x)
            var norA = - Math.PI / 2
            while (norA + parent.unit / 2 < tmp) {
                norA = norA + parent.unit
            }
            return norA
        }
    }