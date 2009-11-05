LEFT_CLICK, RIGHT_CLICK = 'left_click', 'right_click'

class Action():
    def __init__(self, macro, x, y):
        self.__macro = macro
        self.__x = x
        self.__y = y
        self.__propagatable = True
        self.__consumers = []

    def subscribed_by(self, subscriber):
        self.__consumers.append(subscriber)

class Subscriber():
    def consume(self, action):
        action.subscribed_by(self)
        self.handle(action)

class Publisher():
    def __init__(self):
        self.__subscribers = []

    def register(self, *subscribers):
        for subscriber in subscribers:
            if subscriber not in self.__subscribers:
                self.__subscribers.append(subscriber)
        
    def publish(self, action): 
        for subscriber in self.__subscribers:
            subscriber.consume(action) 

