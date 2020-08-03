import QtQuick 2.15
import QtCharts 2.0

ChartView {
    id: chartview
    title: "NotJustLineChart"
    titleColor: "red"
    width: 500
    height: 500
    theme: ChartView.ChartThemeBrownSand
    antialiasing: true
    margins.left: 100

    Component.onCompleted: {
        console.log(chartview.margins.top, chartview.margins.right)
    }

        ValueAxis {
        id: valueAxis
        min: 2000
        max: 2011
        tickCount: 12
        labelFormat: "%.0f"
    }

        ValueAxis {
        id: valueAxisY
        min: 0
        max: 15
        tickCount: 12
        labelFormat: "%.0f"
    }

        AreaSeries {
        name: "Russian"
        axisX: valueAxis
        axisY: valueAxisY
        upperSeries: LineSeries {
        XYPoint { x: 2000; y: 3 }
        XYPoint { x: 2001; y: 3 }
        XYPoint { x: 2002; y: 3 }
        XYPoint { x: 2003; y: 1 }
        XYPoint { x: 2004; y: 3 }
        XYPoint { x: 2005; y: 1 }
        XYPoint { x: 2006; y: 1 }
        XYPoint { x: 2007; y: 3 }
        XYPoint { x: 2008; y: 6 }
        XYPoint { x: 2009; y: 3 }
        XYPoint { x: 2010; y: 10 }
        XYPoint { x: 2011; y: 1 }
        }
    }

    AreaSeries {
            name: "Russian"
            axisX: valueAxis
            upperSeries: LineSeries {
            XYPoint { x: 2000; y: 1 }
            XYPoint { x: 2001; y: 1 }
            XYPoint { x: 2002; y: 1 }
            XYPoint { x: 2003; y: 1 }
            XYPoint { x: 2004; y: 1 }
            XYPoint { x: 2005; y: 0 }
            XYPoint { x: 2006; y: 1 }
            XYPoint { x: 2007; y: 1 }
            XYPoint { x: 2008; y: 4 }
            XYPoint { x: 2009; y: 3 }
            XYPoint { x: 2010; y: 2 }
            XYPoint { x: 2011; y: 1 }
        }
    }
}