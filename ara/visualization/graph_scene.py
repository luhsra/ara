from PySide6.QtWidgets import QGraphicsScene, QWidget, QGraphicsProxyWidget

class GraphScene(QGraphicsScene):

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def del_widget(self, w:QWidget):
        for c in w.children():
            self.del_widget(c)
            w.children().remove(c)

    def clear_rec(self):
        for i in self.items():
            if isinstance(i, QGraphicsProxyWidget):
                self.del_widget(i.widget())
                self.removeItem(i)
            else:
                self.removeItem(i)
