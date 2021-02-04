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
    root.series.push(s)
    seriesContainer.model = root.series.length
}

