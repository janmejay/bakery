import unittest
import env
from util import actions
import mox
from common import text_field
from util import actions
import zorder
import pygame
from pygame.locals import *

class TextFieldTest(unittest.TestCase):

    def setUp(self):
        self.manager = text_field.Manager()
        self.field_instance = text_field.TextField(self.manager)
    
    def test_should_be_active_subscriber(self):
        self.assertTrue(isinstance(self.field_instance, actions.ActiveRectangleSubscriber))

    def test_should_honor_dimensions(self):
        field_instance = text_field.TextField(self.manager, x = 5, y = 3, dx = 4, dy = 2)
        self.assertEqual(field_instance.x(), 5)
        self.assertEqual(field_instance.y(), 3)
        self.assertEqual(field_instance.dx(), 4)
        self.assertEqual(field_instance.dy(), 2)

    def test_can_consume_click(self):
        click = actions.Action(actions.LEFT_CLICK, 10, 10)
        self.assertTrue(self.field_instance.can_consume(click))

    def test_gets_focused_when_clicked(self):
        field_instance_1 = text_field.TextField(self.manager)
        field_instance_2 = text_field.TextField(self.manager)
        self.assertFalse(field_instance_1.is_focused())
        self.assertFalse(field_instance_2.is_focused())
        action = actions.Action(actions.LEFT_CLICK)
        field_instance_1.handle(action)
        self.assertTrue(field_instance_1.is_focused())
        self.assertFalse(field_instance_2.is_focused())
        field_instance_2.handle(action)
        self.assertFalse(field_instance_1.is_focused())
        self.assertTrue(field_instance_2.is_focused())

    def test_consumes_key_down_events_only_when_focused(self):
        key_down = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN))
        key_up = actions.Action(actions.KEY, obj = pygame.event.Event(KEYUP))
        self.assertFalse(self.field_instance.can_consume(key_down))
        self.field_instance.handle(actions.Action(actions.LEFT_CLICK, 10, 10))
        self.assertTrue(self.field_instance.can_consume(key_down))
        self.assertFalse(self.field_instance.can_consume(key_up))

    def test_does_not_consume_out_of_boundry_clicks_even_if_focused(self):
        action  = actions.Action(actions.LEFT_CLICK)
        self.field_instance.handle(action)
        click = actions.Action(actions.LEFT_CLICK, 200, 10)
        self.assertFalse(self.field_instance.can_consume(click))

    def test_records_key_events_when_focused(self):
        self.field_instance.handle(actions.Action(actions.LEFT_CLICK, 10, 10))
        key_a = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = 'a'))
        self.field_instance.handle(key_a)
        self.assertEqual(self.field_instance.get_value(), "a")

class BufferTest(unittest.TestCase):
    def setUp(self):
        self.buffer = text_field.Buffer()
    
    def test_starts_empty_with_cursor(self):
        self.assertEqual(self.buffer.cursor_pos(), 0)
        self.assertEqual(self.buffer.text(), "")

    def test_is_dirty_sprite(self):
        self.assertTrue(isinstance(self.buffer, pygame.sprite.DirtySprite))
        self.assertEqual(self.buffer.layer, 0)
        self.assertEqual(self.buffer.dirty, 1)

if __name__ == '__main__':
    unittest.main()
