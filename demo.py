# -*-coding: utf-8-*-
import sys, os
from PyQt5.QtCore import QUrl
from PyQt5.QtQuick import QQuickView
from PyQt5.QtGui import QGuiApplication


app = QGuiApplication(sys.argv)
view = QQuickView()
view.setResizeMode(QQuickView.SizeRootObjectToView)
view.engine().quit.connect(app.quit)
view.setSource(QUrl("./ImageBrowser/ImageBrowser.qml"))
for i in range(5):
    view.rootObject().addImage("../resources/{}.jpg".format(i+1))
view.show()
sys.exit(app.exec_())
