from PyQt5.QtWidgets import QApplication, QSlider, QWidget, QGridLayout, QScrollArea
from PyQt5.QtQuickWidgets import QQuickWidget
from PyQt5.QtQuick import QQuickView 
from PyQt5.QtCore import QUrl, QPointF, QTimer, QVariant, Qt
import time, random
from functools import partial


class DownSampling(object):
    def __init__(self, step, parent=None):
        self._next = parent
        self._step = step  # 每10000个点 降采样 后到 1000个点，则 step = 10000/1000
        self.scatters = []
        self._result = []

    def add_points(self, points):
        if not self._result:
            self._result.append(points[0])
            points.pop(0)
        self.scatters.extend(points)
        while len(self.scatters) >= 2*self._step:
            bucket = self.scatters[0:self._step]
            self.lttb(bucket, self.average(self.scatters[self._step:2*self._step]))
            self.scatters = self.scatters[self._step:]

    def lttb(self, points, p3):
        p1 = self._result[-1]
        max_area, p = 0, None
        for p2 in points:
            if p is None:
                max_area = self.area(p1, p2, p3)
                p = p2
            elif self.area(p1, p2, p3) > max_area:
                p = p2
        self._result.append(p)
        if self._next:
            self._next.add_points([p])

    def area(self, p1, p2, p3):
        return abs((p1.x()*(p2.y()-p3.y()) + p2.x()*(p3.y()-p1.y()) + p3.x()*(p1.y()-p2.y())) / 2)

    def average(self, points):
        _sum_x = 0
        _sum_y = 0
        for p in points:
            _sum_y += p.y()
            _sum_x += p.x()
        return QPointF(_sum_x/len(points), _sum_y/len(points))

    def sampling(self, bucket):
        p_min, p_max = bucket[1], bucket[-2]
        for p in bucket[1:-1]:
            if p.y() > p_max.y():
                p_max = p
            if p.y() < p_min.y():
                p_min = p
        if p_min.x() < p_max.x():
            self._result.extend([p_min, p_max])
            if self._next:
                self._next.add_points([p_min, p_max])
        else:
            self._result.extend([p_max, p_min])
            if self._next:
                self._next.add_points([p_max, p_min])

    def get_scatters(self):
        return self.scatters

    def get_result(self):
        if self._next:
            return self._next.get_result() + self.get_scatters()
        else:
            return self._result + self.get_scatters()


class QMLLineChart(QQuickWidget):

    def __init__(self, title="", parent=None):
        super(QMLLineChart, self).__init__(QUrl("./Chart/LineChart.qml"), parent=parent)
        self.setResizeMode(self.SizeRootObjectToView)
        self.rootObject().setProperty("titleText", title)
        self.points = {}

    def set_down_sampling(self, step, rank):
        ds = DownSampling(step, None)
        for i in range(rank-1):
            ds = DownSampling(step, ds)
        return ds
    
    def add_series(self, name, color, line_width):
        self.rootObject().addSeries(name, "lineSeries", color, line_width)
        self.points[name] = {
            "points": [],
            "down_sampling": self.set_down_sampling(20, 1)
        }

    def add_points(self, name, new_points):
        points = self.points[name]["points"]
        down_sampling = self.points[name]["down_sampling"]
        points.extend(new_points)
        if down_sampling:
            down_sampling.add_points(new_points)
            self.rootObject().replacePoints(name, down_sampling.get_result())
        else:
            self.rootObject().replacePoints(name, points)
    
    def set_xrange(self, x_min, x_max):
        self.rootObject().setProperty("xRange", QVariant([x_min, x_max]))
        self.rootObject().clearCanvas()


CHARTS = []
init_cnt = 10000
total = init_cnt // 2 * 3
r = 4
c = 5

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
    for i in range(5):
        p = generate_points(1, (init_cnt/total*1000, (init_cnt+1)/total*1000), (i*200, (i+1)*200))
        for wgt in CHARTS:
            wgt.add_points("line {}".format(i+1), p)
        print(p)
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