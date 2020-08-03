# -*-coding: utf-8-*-
import sys, os
from PyQt5.QtCore import QUrl
from PyQt5.QtWidgets import QApplication
from PyQt5.QtQuick import QQuickView


# app = QGuiApplication(sys.argv)
app = QApplication(sys.argv)

view = QQuickView()
view.setResizeMode(QQuickView.SizeRootObjectToView)
view.engine().quit.connect(app.quit)

# ImageBrowser 
# view.setSource(QUrl("./ImageBrowser/ImageBrowser.qml"))
# for i in range(5):
#     view.rootObject().addImage("../resources/ImageBrowser/{}.jpg".format(i+1))

# NotJustLineChart
view.setTitle("NotJustLineChart")
view.setSource(QUrl("./NotJustLineChart/NotJustLineChart.qml"))

view.show()
sys.exit(app.exec_())
