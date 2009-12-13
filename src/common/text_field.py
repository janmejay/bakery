import pygame, pygame.font, pygame.event, pygame.draw, string
from pygame.locals import *
from util import actions
import unicodedata
import sub_select_dict
import zorder
from util import game_util

class CharElem:
    def __init__(self, char):
        self.__char = char

    def value(self):
        return self.__char + self.next_elem.value()

    def push(self, char):
        inital_next = self.next_elem
        self.next_elem = CharElem(char)
        self.next_elem.previous_elem = self
        self.next_elem.next_elem = inital_next
        inital_next.previous_elem = self.next_elem
        return self.next_elem.logical_return()

    def logical_return(self):
        return self

    def previous(self):
        return self.previous_elem.logical_return()

    def next(self):
        return self.next_elem.logical_return()

    def begining(self):
        return self.previous().begining()

    def delete_current(self):
        self.next_elem.previous_elem = self.previous_elem
        self.previous_elem.next_elem = self.next_elem
        return self.next()

    def delete_next(self):
        deletable = self.next_elem
        if deletable.not_deleteable(): return self.logical_return()
        self.next_elem = deletable.next_elem
        self.next_elem.previous_elem = self
        return self.logical_return()

    def not_deleteable(self):
        return False

class TerminalCharElem(CharElem):
    def __init__(self):
        CharElem.__init__(self, '')

    def not_deleteable(self):
        return True
    
class StartingCharElem(TerminalCharElem):
    def __init__(self):
        TerminalCharElem.__init__(self)
        self.next_elem = EndingCharElem()
        self.next_elem.previous_elem = self
        
    def delete_current(self):
        return self
    
    def logical_return(self):
        return self

    def begining(self):
        return self

    def previous(self):
        return self

class EndingCharElem(TerminalCharElem):
    def __init__(self):
        TerminalCharElem.__init__(self)
    
    def value(self):
        return ''

    def delete_next(self):
        pass

    def logical_return(self):
        return self.previous_elem

PRINTABLE_CATEGORIES = ('L', 'N', 'P', 'S')

class Buffer:
    def __init__(self, value = ''):
        self.cursor = StartingCharElem()
        for ch in value:
            self.cursor = self.cursor.push(ch)
        self.dirty = 1

    def cursor_pos(self):
        return 0

    def text(self):
        return self.cursor.begining().value()

    def text_before_cursor(self):
        after_cursor_length = len(self.cursor.next_elem.value())
        text = self.text()
        return text[:len(text)-after_cursor_length]

    def record(self, action):
        key_evt = action.get_obj()
        if (len(key_evt.unicode) > 0) and (unicodedata.category(key_evt.unicode)[0] in PRINTABLE_CATEGORIES):
            self.cursor = self.cursor.push(key_evt.unicode)
        else:
            self.handle_navigation(key_evt)
    
    def handle_navigation(self, key_evt):
        if key_evt.key == 276:
            self.cursor = self.cursor.previous()
        elif key_evt.key == 275:
            self.cursor = self.cursor.next()
        elif key_evt.key == 8:
            self.cursor = self.cursor.delete_current()
        elif key_evt.key == 127:
            self.cursor = self.cursor.delete_next()

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
    V_MARGIN = BORDER_WIDTH*3
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
        self.dirty, self.layer = 1, zorder.TEXT_FIELD

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
            self.image.blit(glyph, (TextField.BORDER_WIDTH*3, TextField.BORDER_WIDTH))
            if self.is_focused():
                pygame.draw.line(self.image, TextField.DEFAULT_COLOR, self.cursor_top(), self.cursor_bottom(), TextField.CURSOR_WIDTH)

    def cursor_top(self):
        return (self.cursor_x(),  TextField.V_MARGIN)

    def cursor_bottom(self):
        return (self.cursor_x(), self.dy() - TextField.V_MARGIN)

    def handle(self, action):
        self.dirty = 1
        if action.is_click():
            self.__manager.set_focused(self)
        elif self.is_focused():
            self.__buffer.record(action)

    def cursor_x(self):
        glyph = self.font.render(self.__buffer.text_before_cursor(), True, TextField.DEFAULT_COLOR)
        return TextField.BORDER_WIDTH + glyph.get_width()

    def is_focused(self):
        return self.__manager.is_focused(self)

    def __listening_to_kb(self, action):
        return self.is_focused() and action.is_key() and (action.get_obj().type == pygame.constants.KEYDOWN)

    def can_consume(self, action):
        return actions.ActiveRectangleSubscriber.can_consume(self, action) or \
            self.__listening_to_kb(action)

    def get_value(self):
        return self.__buffer.text()

