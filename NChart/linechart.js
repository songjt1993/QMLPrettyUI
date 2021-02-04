Qt.include("valueaxis.js")
Qt.include("lineseries.js")

function createValueAxis(alignment, plotArea) {
    var axis = new ValueAxis(alignment)
    axis.calFactor(axis.range[0], axis.range[1], plotArea)
    axis.adjust()
    return axis
}

function addSeries(xAlignment, yAlignment, name) {
    var s = new LineSeries()
    s.hAxis = coordinate[xAlignment]
    s.vAxis = coordinate[yAlignment]
    s.name = name
    var component = Qt.createComponent("Series.qml")
    if (component.status == Component.Ready) {
        var item = component.createObject(root,
        {
            "obj": s,
            "x": root.padding.left,
            "y": root.padding.top,
            "width":  root.width - root.padding.left - root.padding.right,
            "height": root.height - root.padding.top - root.padding.bottom
        }
        )
        seriesModel.insert(0, item)
    } else {
        console.log("fail to create " + series)
    }
}

