import QtQuick 2.15

Rectangle {
    id: root
    signal tagUpdated(string contant)
    signal rightButtonClicked(string _id)
    required property var elementID
    property var allowEdit: false
    property var tagColor: "#6666FF"
    property alias text: label.text
    property alias finish: labeledit.focus
    property var range
    height: parent.height
    border.width: 1
    border.color: tagColor
    color: tagColor.replace("#", "#1A")
    Text {
        id: label
        visible: false
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 3
        color: tagColor
        text: "tag"
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onDoubleClicked: {
                if (root.allowEdit) label.visible = false
            }
            onPressed: {
                if (mouse.button == Qt.RightButton)
                    rightButtonClicked(root.elementID)
            }
        }
    }
    TextInput {
        id: labeledit
        visible: !label.visible
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 3
        color: tagColor
        text: label.text
        focus: true
        onEditingFinished: {
            label.visible = true
            label.text = text
            root.tagUpdated(text)
        }

        Component.onCompleted: labeledit.selectAll()
    }
}