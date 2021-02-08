from PyQt5.QtWidgets import QApplication, QSlider, QWidget, QGridLayout, QScrollArea
from PyQt5.QtQuickWidgets import QQuickWidget
from PyQt5.QtQuick import QQuickView, QQuickItem
from PyQt5.QtCore import QUrl, QPointF, QTimer, QVariant, Qt, pyqtSignal
import time, random
import math


class DownSampling(object):
    def __init__(self, step, parent=None):
        self._next = parent
        self._step = step  # 每10000个点 降采样 后到 1000个点，则 step = 10000/1000
        self.scatters = []
        self._result = []

        self._value_range = ()
        self._index_range = ()  # 不包括 scatters, scatters需要在返回结果时判断

    def set_value_range(self, _range):
        self._value_range = _range
        self._index_range = (self.find_nearest(self._result, _range[0]),
                             self.find_nearest(self._result, _range[1]))
        if self._next:
            self._next.set_value_range(_range)

    def add_points(self, points):
        if not self._result:
            self._result.append(points[0])
            points.pop(0)
        self.scatters.extend(points)
        while len(self.scatters) >= 2*self._step:
            bucket = self.scatters[0:self._step]
            p = self.lttb(bucket, self.average(self.scatters[self._step:2*self._step]))
            self._result.append(p)
            # 如果新的点在有效范围，更新_index_range
            if self._value_range[0] <= p.x() <= self._value_range[1]:
                self._index_range = (self._index_range[0], len(self._result)-1)
            # 本级的新采样点，要作为下一级的输入
            if self._next:
                self._next.add_points([p])
            # 计算过的点移除
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
        return p

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
        bgn = self.find_nearest(self.scatters, self._value_range[0])
        end = self.find_nearest(self.scatters, self._value_range[1])
        return self.scatters[bgn:end]

    def get_result(self, point_count, scatters=None):
        tmp = self._result[self._index_range[0]:self._index_range[1]] + self.get_scatters() + (scatters or [])

        if len(tmp) <= point_count or self._next is None:
            return tmp
        else:
            return self._next.get_result(point_count, self.get_scatters() + (scatters or []))

    @staticmethod
    def find_nearest(points, value):
        bgn = 0
        end = len(points) - 1
        while end > bgn:
            mid = (bgn + end) // 2
            if value > points[mid].x():
                bgn = mid + 1
            else:
                end = mid - 1
        return bgn


class QMLLineChart(QQuickWidget):
    TOOLTIP_MOVED = pyqtSignal(QVariant, QVariant)
    REQUEST_MODIFY_SCENE = pyqtSignal(str)

    def __init__(self, title="", parent=None):
        super(QMLLineChart, self).__init__(QUrl("./NChart/LineChart.qml"), parent=parent)
        self.setResizeMode(self.SizeRootObjectToView)
        # self.rootObject().setProperty("titleText", title)
        self.points = {}
        self.statistics = {}
        self.y_unit = ""
        self.range = [0, 1000]

        self._element_layer.toolTipMoved.connect(self.TOOLTIP_MOVED)

    @property
    def _plotarea(self):
        res = self.rootObject().property("plotArea")
        return res

    @property
    def _element_layer(self):
        return self.rootObject().findChild(QQuickItem, name="ElementLayer")

    def createAxes(self, alignment, name, unit):
        if alignment == "left":
            self.y_unit = unit
        self.rootObject().createValueAxis(alignment)

    def set_down_sampling(self, step, rank):
        ds = DownSampling(step, None)
        for i in range(rank-1):
            ds = DownSampling(step, ds)
        ds = DownSampling(1, ds)
        ds.set_value_range(self.range)
        return ds
    
    def add_series(self, name, color, line_width):
        self.rootObject().addSeries("bottom", "left", name)
        self.points[name] = {
            "points": [],
            "down_sampling": self.set_down_sampling(2, 3)
        }
        self.statistics[name] = {
            "name": name,
            "unit": self.y_unit,
            "realTime": None,
            "average": None,
            "min": None,
            "max": None
        }

    def add_points(self, name, new_points):
        points = self.points[name]["points"]
        down_sampling = self.points[name]["down_sampling"]
        points.extend(new_points)
        if down_sampling:
            down_sampling.add_points(new_points)
        self.refresh(name)
        # 计算统计值
        self.rootObject().updateStatistic(self.cal_statistics(name, new_points))
    
    def set_xrange(self, x_min, x_max):
        self.range = [x_min, x_max]
        self.rootObject().changeAxisRange("bottom", x_min, x_max)
        for _, series in self.points.items():
            series["down_sampling"].set_value_range((x_min, x_max))
        for name in self.points:
            self.refresh(name)

    def cal_statistics(self, name, points):
        # min
        _min = min([p.y() for p in points])
        if self.statistics[name]["min"]:
            self.statistics[name]["min"] = min(self.statistics[name]["min"], _min)
        else:
            self.statistics[name]["min"] = _min
        # max
        _max = min([p.y() for p in points])
        if self.statistics[name]["max"]:
            self.statistics[name]["max"] = max(self.statistics[name]["max"], _max)
        else:
            self.statistics[name]["max"] = _max
        # average
        _sum = sum([p.y() for p in points])
        n = len(self.points[name])
        if self.statistics[name]["average"]:
            self.statistics[name]["average"] = self.statistics[name]["average"] * (n-len(points)) / n + _sum / n
        else:
            self.statistics[name]["average"] = _sum / len(points)
        # latest
        self.statistics[name]["realTime"] = points[-1].y()

        return QVariant(self.statistics[name])

    def refresh(self, name):
        points = self.points[name]["points"]
        down_sampling = self.points[name]["down_sampling"]
        if down_sampling:
            # st = time.time()
            points = down_sampling.get_result(self._plotarea.width())
            # print("refresh:{}".format(time.time()-st))
        self.rootObject().replacePoints(name, points)

    def add_scene(self, v_min, v_max):
        item = self._element_layer.createElement(v_min, v_max)
        item.rightButtonClicked.connect(self.REQUEST_MODIFY_SCENE)
        return item.property("elementID")

    def update_scene(self, _id, text):
        item = self._element_layer.getElement(QVariant(_id))
        item.setProperty("text", text)

    def move_tooltip(self, obj_name, value):
        tooltip = self._element_layer.findChild(QQuickItem, name=obj_name)
        tooltip.setProperty("visible", True)
        self._element_layer.moveTooltip(tooltip, QVariant(value))


CHARTS = []
init_cnt = 6000
total = init_cnt // 2 * 3
r = 5
c = 2

def generate_points(n, x_range, y_range):
    points = []
    for i in range(n):
        points.append(QPointF(i*(x_range[1]-x_range[0])/n + x_range[0], y_range[0] + random.random() * (y_range[1]-y_range[0])))
    # print(points)
    return points

def create_charts(n):
    for i in range(n):
        wgt = QMLLineChart("table {}".format(i))
        wgt.createAxes("bottom", "x", "s")
        wgt.createAxes("left", "y", "%")
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
        st = time.time()
        for wgt in CHARTS:
            wgt.add_points("line {}".format(i+1), p)
        print("更新{}点耗时：{}".format(init_cnt, time.time() - st))
        # print(p)
    init_cnt += 1

def set_range(v):
    for wgt in CHARTS:
        wgt.set_xrange(0, v/100*1000)

def move_tooltip(name, value):
    for c in CHARTS:
        c.move_tooltip(name, value)



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
    # wgt.show()

    sld = QSlider(Qt.Horizontal)
    sld.setMinimumSize(300, 30)
    sld.valueChanged.connect(set_range)
    sld.show()

    t1 = QTimer()
    t1.timeout.connect(timeout_slot)
    t1.start(1000)

    _id = CHARTS[0].add_scene(300, 400)
    CHARTS[0].update_scene(_id, "hahahah")
    CHARTS[0].REQUEST_MODIFY_SCENE.connect(print)
    CHARTS[0].TOOLTIP_MOVED.connect(move_tooltip)
    app.exec_()