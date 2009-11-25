import pygame, pygame.font, pygame.event, pygame.draw, string
from pygame.locals import *
from util import actions

class Buffer(pygame.sprite.DirtySprite):
    def __init__(self, **options):
        self.__cursor = 0
        self.__text = ""
        self.dirty, self.layer = 1, 0

    def cursor_pos(self):
        return self.__cursor

    def text(self):
        return self.__text

class Manager:
    def __init__(self):
        self.__focused = None

    def is_focused(self, field):
        return field == self.__focused

    def set_focused(self, field):
        self.__focused = field

class TextField(actions.ActiveRectangleSubscriber):
    def __init__(self, manager, **options_subset):
        options = { 'x' : 0, 'y' : 0, 'dx' : 100, 'dy' : 30}
        options.update(options_subset)
        actions.ActiveRectangleSubscriber.__init__(self, **options)
        self.__manager = manager
        self.__value = ""

    def handle(self, action):
        if action.is_click():
            self.__manager.set_focused(self)
        else:
            self.__value += action.get_obj().unicode

    def is_focused(self):
        return self.__manager.is_focused(self)

    def __listening_to_kb(self, action):
        return self.is_focused() and action.is_key() and (action.get_obj().type == pygame.constants.KEYDOWN)

    def can_consume(self, action):
        return actions.ActiveRectangleSubscriber.can_consume(self, action) or \
            self.__listening_to_kb(action)

    def get_value(self):
        return self.__value


# def get_key():
#   while 1:
#     event = pygame.event.poll()
#     if event.type == KEYDOWN:
#       return event.key
#     else:
#       pass

# def display_box(screen, message):
#   "Print a message in a box in the middle of the screen"
#   fontobject = pygame.font.Font(None,18)
#   pygame.draw.rect(screen, (0,0,0),
#                    ((screen.get_width() / 2) - 100,
#                     (screen.get_height() / 2) - 10,
#                     200,20), 0)
#   pygame.draw.rect(screen, (255,255,255),
#                    ((screen.get_width() / 2) - 102,
#                     (screen.get_height() / 2) - 12,
#                     204,24), 1)
#   if len(message) != 0:
#     screen.blit(fontobject.render(message, 1, (255,255,255)),
#                 ((screen.get_width() / 2) - 100, (screen.get_height() / 2) - 10))
#   pygame.display.flip()

# def ask(screen, question):
#   "ask(screen, question) -> answer"
#   pygame.font.init()
#   current_string = []
#   display_box(screen, question + ": " + string.join(current_string,""))
#   while 1:
#     inkey = get_key()
#     if inkey == K_BACKSPACE:
#       current_string = current_string[0:-1]
#     elif inkey == K_RETURN:
#       break
#     elif inkey == K_MINUS:
#       current_string.append("_")
#     elif inkey <= 127:
#       current_string.append(chr(inkey))
#     display_box(screen, question + ": " + string.join(current_string,""))
#   return string.join(current_string,"")
