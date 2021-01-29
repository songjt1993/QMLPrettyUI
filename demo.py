# -*-coding: utf-8-*-
import sys, os, random
from PyQt5.QtCore import QUrl, QTimer, QVariant, QPoint
from PyQt5.QtWidgets import QApplication
from PyQt5.QtQuick import QQuickView


# app = QGuiApplication(sys.argv)
app = QApplication(sys.argv)

view = QQuickView()
# view.setResizeMode(QQuickView.SizeRootObjectToView)
view.engine().quit.connect(app.quit)

# ImageBrowser
# view.setSource(QUrl("./ImageBrowser/ImageBrowser.qml"))
# for i in range(5):
#     view.rootObject().addImage("../resources/ImageBrowser/{}.jpg".format(i+1))

# NotJustLineChart
view.setTitle("NotJustLineChart")
view.setSource(QUrl("Chart/LineChart.qml"))
view.setResizeMode(QQuickView.SizeRootObjectToView)

view.rootObject().addSeries("a", "lineSeries", "red", 1)
view.rootObject().addSeries("b", "lineSeries", "blue", 1)
view.rootObject().addSeries("c", "lineSeries", "green", 1)
view.rootObject().addSeries("d", "lineSeries", "lightblue", 1)

cnt = 0
timer = QTimer()
def slot():
    global cnt
    cnt += 1
    view.rootObject().addPoints("a", QVariant([QPoint(cnt, random.randint(100, 200))]))
    view.rootObject().addPoints("b", QVariant([QPoint(cnt, random.randint(400, 500))]))
    view.rootObject().addPoints("c", QVariant([QPoint(cnt, random.randint(700, 900))]))
    view.rootObject().addPoints("d", QVariant([QPoint(cnt, cnt)]))
    if cnt > 1000:
        timer.stop()

timer.timeout.connect(slot)
timer.start(1)

# view.setSource(QUrl("./LineChart/ZoomSlider.qml"))

view.show()
sys.exit(app.exec_())
