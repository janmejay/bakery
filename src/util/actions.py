LEFT_CLICK, RIGHT_CLICK = 'left_click', 'right_click'

class Action():
    def __init__(self, macro, x, y):
        self.__macro = macro
        self.__x = x
        self.__y = y
        self.propagatable = True
        self.__consumers = []

    def subscribed_by(self, subscriber):
        self.__consumers.append(subscriber)

class Subscriber():
    def consume(self, action):
        if self.can_consume(action):
            action.subscribed_by(self)
            self.handle(action)
            action.propagatable = self.allow_propagation(action)

    def can_consume(self, action):
        return False

    def allow_propagation(self, action):
        return True
    
    def __cmp__(self, other):
        return other.zindex() - self.zindex()

    def zindex(self):
        return 0

    def __eq__(self, other):
        id(self) == id(other)

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

