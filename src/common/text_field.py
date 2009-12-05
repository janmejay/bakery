import pygame, pygame.font, pygame.event, pygame.draw, string
from pygame.locals import *
from util import actions
import unicodedata
import sub_select_dict
from util import game_util

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

PRINTABLE_CATEGORIES = ('L', 'N', 'P', 'S')

class Buffer:
    def __init__(self, value = ''):
        self.__cursor = CharElem('')
        for ch in value:
            self.__cursor = self.__cursor.push(ch)
        self.dirty = 1

    def cursor_pos(self):
        return 0

    def text(self):
        return self.__cursor.begining().value()

    def text_before_cursor(self):
        after_cursor_length = len(self.__cursor.next().value())
        return self.text()[:-after_cursor_length]

    def record(self, action):
        key_evt = action.get_obj()
        if (len(key_evt.unicode) > 0) and (unicodedata.category(key_evt.unicode)[0] in PRINTABLE_CATEGORIES):
            self.__cursor = self.__cursor.push(key_evt.unicode)
        else:
            self.handle_navigation(key_evt)
    
    def handle_navigation(self, key_evt):
        if key_evt.key == 276:
            self.__cursor = self.__cursor.previous()
        elif key_evt.key == 275:
            self.__cursor = self.__cursor.next()
        elif key_evt.key == 8:
            self.__cursor = self.__cursor.delete_current()
        elif key_evt.key == 127:
            self.__cursor = self.__cursor.delete_next()

class Manager:
    def __init__(self):
        self.__focused = None

    def is_focused(self, field):
        return field == self.__focused

    def set_focused(self, field):
        self.__focused = field

class TextField(actions.ActiveRectangleSubscriber, pygame.sprite.DirtySprite):
    BORDER_WIDTH = 2
    DEFAULT_COLOR = (0, 0, 0, 0)
    CURSOR_WIDTH = 3
    def __init__(self, manager, x = 0, y = 0, dx = 100, border_color = (150, 150, 150, 150),
                 font_size = 5, font_file = 'hand.ttf', font_color = DEFAULT_COLOR, value = ''):
        self.__initialize_font(font_file, font_size)
        dy = self.font.get_height() + TextField.BORDER_WIDTH*2
        actions.ActiveRectangleSubscriber.__init__(self, x, y, dx, dy)
        pygame.sprite.DirtySprite.__init__(self)
        self.__initialize_image(x, y, dx, dy, border_color)
        self.__manager = manager
        self.__font_color = font_color
        self.__buffer = Buffer(value)
        self.dirty = 1

    def __initialize_image(self, x, y, dx, dy, border_color):
        self.base_image = pygame.surface.Surface((dx + TextField.BORDER_WIDTH, dy + TextField.BORDER_WIDTH))
        self.base_image.fill((255, 255, 255))
        self.base_image.set_colorkey((255, 255, 255))
        border = pygame.rect.Rect(0, 0, dx, dy)
        pygame.draw.rect(self.base_image, border_color, border, TextField.BORDER_WIDTH)
        self.rect = self.base_image.get_rect()
        self.rect.move_ip(x, y)

    def __initialize_font(self, font_file, font_size):
        self.font = pygame.font.Font(game_util.media(font_file), font_size)

    def update(self):
        if self.dirty > 0:
            self.image = self.base_image.copy()
            glyph = self.font.render(self.get_value(), True, self.__font_color)
            self.image.blit(glyph, (TextField.BORDER_WIDTH, TextField.BORDER_WIDTH))
            if self.is_focused():
                pygame.draw.line(self.image, TextField.DEFAULT_COLOR, self.cursor_top(), self.cursor_bottom(), TextField.CURSOR_WIDTH)

    def cursor_top(self):
        return (self.cursor_x(), self.y() + TextField.BORDER_WIDTH*2)

    def cursor_bottom(self):
        return (self.cursor_x(), self.y() + self.font.get_height() - TextField.BORDER_WIDTH*2)

    def handle(self, action):
        self.dirty = 1
        if action.is_click():
            self.__manager.set_focused(self)
        elif self.is_focused():
            self.__buffer.record(action)

    def cursor_x(self):
        glyph = self.font.render(self.__buffer.text_before_cursor(), True, TextField.DEFAULT_COLOR)
        return self.x() + TextField.BORDER_WIDTH + glyph.get_width()

    def is_focused(self):
        return self.__manager.is_focused(self)

    def __listening_to_kb(self, action):
        return self.is_focused() and action.is_key() and (action.get_obj().type == pygame.constants.KEYDOWN)

    def can_consume(self, action):
        return actions.ActiveRectangleSubscriber.can_consume(self, action) or \
            self.__listening_to_kb(action)

    def get_value(self):
        return self.__buffer.text()

