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

        self.down_sampling = True
        self.step = 4
        self.level = 3
        self.max_point = 8
        self.points = {}
    
    def add_series(self, name, color, line_width):
        self.rootObject().addSeries(name, "lineSeries", color, line_width)
        self.points[name] = []
        if self.down_sampling:
            for i in range(self.level):
                self.points[name].append([])

    def add_points(self, name, points):
        self.points[name][0].extend(points)
        if self.down_sampling:
            # 降采样
            levels = self.points[name]
            for i in range(len(levels)-1):
                border = len(levels[i + 1]) // 2 * self.step
                for j in range(border, len(levels[i]), self.step):
                    if j + self.step <= len(levels[i]):
                        levels[i + 1].extend(self.sample(levels[i][j:j + self.step]))
            # print(levels)
            # 获取更新点
            self.rootObject().replacePoints(name, self.get_series(name))
        else:
            self.rootObject().replacePoints(name, self.points[name][1])
    
    def set_xrange(self, x_min, x_max):
        self.rootObject().setProperty("xRange", QVariant([x_min, x_max]))
        self.rootObject().clearCanvas()

    @staticmethod
    def sample(bucket):
        p1, p2 = bucket[0], bucket[0]
        for p in bucket:
            if p.y() > p1.y():
                p1 = p
            if p.y() < p2.y():
                p2 = p
        if p1.x() > p2.x():
            return [p2, p1]
        else:
            return [p1, p2]

    def get_series(self, name):
        for i, points in enumerate(self.points[name]):
            if i == 0:
                if len(points) < self.max_point:
                    return points
                else:
                    continue

            if len(points) < self.max_point:
                return points + self.points[name][0][len(points) // 2 * (self.step//2) ** i:]
        i, points = len(self.points[name]) - 1, self.points[name][-1]
        return points + self.points[name][0][len(points) // 2 * (self.step // 2) ** i:]



CHARTS = []
init_cnt = 40
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