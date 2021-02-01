from PyQt5.QtWidgets import QApplication, QSlider, QWidget, QGridLayout, QScrollArea
from PyQt5.QtQuickWidgets import QQuickWidget
from PyQt5.QtQuick import QQuickView 
from PyQt5.QtCore import QUrl, QPointF, QTimer, QVariant, Qt
import time, random
from functools import partial

class QMLLineChart(QQuickWidget):

    def __init__(self, title="", parent=None):
        super(QMLLineChart, self).__init__(QUrl("./Chart/LineChart.qml"), parent=parent)
        self.setResizeMode(self.SizeRootObjectToView)
        self.rootObject().setProperty("titleText", title)
    
    def add_series(self, name, color, line_width):
        self.rootObject().addSeries(name, "lineSeries", color, line_width)
    
    def add_points(self, name, points):
        self.rootObject().addPoints(name, points)
        
    
    def set_xrange(self, x_min, x_max):
        self.rootObject().setProperty("xRange", QVariant([x_min, x_max]))
        self.rootObject().clearCanvas()


CHARTS = []
init_cnt = 6000
total = init_cnt // 2 * 3
r = 3
c = 4

def generate_points(n, x_range, y_range):
    points = []
    for i in range(n):
        points.append(QPointF(i*(x_range[1]-x_range[0])/n + x_range[0], y_range[0] + random.random() * (y_range[1]-y_range[0])))
    # print(points)
    return points

def create_charts(n):
    for i in range(n):
        wgt = QMLLineChart("table {}".format(i))
        wgt.add_series("line 1", "red", 1)
        wgt.add_series("line 2", "green", 1)
        wgt.add_series("line 3", "blue", 1)
        wgt.add_series("line 4", "purple", 1)
        wgt.add_series("line 5", "black", 1)
        for i in range(5):
            wgt.add_points("line {}".format(i+1), generate_points(init_cnt, (0, init_cnt/total*1000), (i*200, (i+1)*200)))
        CHARTS.append(wgt)

def timeout_slot():
    global init_cnt
    st = time.time()
    for wgt in CHARTS:
        for i in range(5):
            wgt.add_points("line {}".format(i+1), generate_points(1, (init_cnt/total*1000, (init_cnt+1)/total*1000), (i*200, (i+1)*200)))
        init_cnt += 1
    print("更新{}点耗时：{}".format(init_cnt, time.time()-st))

def set_range(v):
    for wgt in CHARTS:
        wgt.set_xrange(0, v/100*1000)


if __name__ == "__main__":
    app = QApplication([])
    create_charts(r*c)
    scl = QScrollArea()
    wgt = QWidget()
    gbox = QGridLayout(wgt)
    for i in range(r):
        for j in range(c):
            print(i, j)
            gbox.addWidget(CHARTS[i*c+j], i, j)
    
    scl.setWidget(wgt)
    scl.show()

    sld = QSlider(Qt.Horizontal)
    sld.setMinimumSize(300, 30)
    sld.valueChanged.connect(set_range)
    sld.show()

    t1 = QTimer()  
    t1.timeout.connect(timeout_slot)
    t1.start(1000)

    app.exec_()