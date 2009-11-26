import pygame, pygame.font, pygame.event, pygame.draw, string
from pygame.locals import *
from util import actions

class CharElem:
    def __set_or_default_next(self, optionals):
        if optionals.has_key('next_elem'):
            self.next_elem = optionals['next_elem']
        else:
            self.next_elem = EndingCharElem(self)
        if self.next_elem:
            self.next_elem.previous_elem = self

    def __set_or_default_previous(self, optionals):
        if optionals.has_key('previous_elem'):
            self.previous_elem = optionals['previous_elem']
        else:
            self.previous_elem = StartingCharElem(self)
        
    def __init__(self, char, **optionals):
        self.__char = char
        self.__set_or_default_next(optionals)
        self.__set_or_default_previous(optionals)

    def value(self):
        return self.__char + self.next_elem.value()

    def push(self, char):
        if self.__char == '' and self.is_deletable():
            self.__char = char
            return self
        self.next_elem = CharElem(char, next_elem = self.next_elem, previous_elem = self)
        return self.next_elem.logical_return()

    def logical_return(self):
        return self

    def previous(self):
        return (self.previous_elem or self).logical_return()

    def next(self):
        return (self.next_elem or self).logical_return()

    def begining(self):
        return self.previous().begining()

    def delete_current(self):
        if not self.is_deletable(): return self.logical_return()
        self.next_elem.previous_elem = self.previous_elem
        self.previous_elem.next_elem = self.next_elem
        return self.next()

    def delete_next(self):
        deletable = self.next_elem
        returnable = self.logical_return()
        if not deletable.is_deletable(): return returnable
        self.next_elem = deletable.next_elem
        self.next_elem.previous_elem = self
        return returnable

    def is_deletable(self):
        return True

class TerminalCharElem(CharElem):
    def __init__(self, previous_elem, next_elem):
        CharElem.__init__(self, '', previous_elem = previous_elem, next_elem = next_elem)
    
    def is_deletable(self):
        return False

class StartingCharElem(TerminalCharElem):
    def __init__(self, next_elem):
        TerminalCharElem.__init__(self, None, next_elem)
    
    def logical_return(self):
        return self

    def begining(self):
        return self

class EndingCharElem(TerminalCharElem):
    def __init__(self, previous_elem):
        TerminalCharElem.__init__(self, previous_elem, None)
    
    def value(self):
        return ''

    def logical_return(self):
        return self.previous_elem

class Buffer(pygame.sprite.DirtySprite):
    def __init__(self, **options):
        self.__cursor = CharElem('')
        self.dirty, self.layer = 1, 0

    def cursor_pos(self):
        return 0

    def text(self):
        return self.__cursor.begining().value()

    def record(self, action):
        key_evt = action.get_obj()
        if len(key_evt.unicode) != 0:
            self.__cursor = self.__cursor.push(key_evt.unicode)
        else:
            self.__handle_navigation(key_evt)
    
    def __handle_navigation(self, key_evt):
        if key_evt.key == 276:
            self.__cursor = self.__cursor.previous()
        elif key_evt.key == 275:
            self.__cursor = self.__cursor.next()

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
