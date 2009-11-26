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

    # def test_understands_left_and_right_arrow_keys(self):
    #     key_a = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = 'a'))
    #     key_w = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = 'w'))
    #     key_s = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = 's'))
    #     key_e = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = 'e'))
    #     key_t = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = 't'))
    #     left = pygame.event.Event(KEYDOWN, key = 276)
    #     right = pygame.event.Event(KEYDOWN, key = 275)
    #     self.buffer.record(key_a)
    #     self.buffer.record(actions.Action(actions.KEY, obj = left))
    #     self.buffer.record(key_w)
    #     self.buffer.record(actions.Action(actions.KEY, obj = left))
    #     self.buffer.record(key_s)
    #     self.buffer.record(actions.Action(actions.KEY, obj = right))
    #     self.buffer.record(key_e)
    #     self.buffer.record(key_t)
    #     self.assertEqual(self.buffer.text(), "sweta")

class CharElemTest(unittest.TestCase):
    def setUp(self):
        self.char_elem = text_field.CharElem('a')

    def test_returns_value_its_initialized_with(self):
        self.assertEqual(self.char_elem.value(), 'a')
        self.assertEqual(text_field.CharElem('').value(), '')

    def test_can_push_chars(self):
        self.char_elem.push('b')
        self.assertEqual(self.char_elem.value(), "ab")

    def test_returns_next_elem_when_pushing(self):
        self.char_elem.push('b').push('c').push('d')
        self.assertEqual(self.char_elem.value(), "abcd")

    def test_can_insert_elements_when_pushed(self):
        self.char_elem.push('b').push('c')
        self.char_elem.push('d').push('e')
        self.assertEqual(self.char_elem.value(), "adebc")

    def test_can_seek_backwards_positions_to_insert_elements(self):
        b = self.char_elem.push('b')
        b.push('c')
        previous_elem = b.previous()
        previous_elem.push('d').push('e')
        self.assertEqual(self.char_elem.value(), "adebc")

    def start_and_end_values_should_be_empty(self):
        self.assertEqual(text_field.StartingCharElem().value(), '')
        self.assertEqual(text_field.EndingCharElem().value(), '')

    def test_can_seek_backwards_indifinitely_without_going_beyond_zeroth_char(self):
        self.char_elem.push('b')
        begining = self.char_elem.previous()
        begining.push('c')
        begining = begining.previous()
        begining.push('d')
        begining = begining.previous()
        begining.push('e')
        self.assertEqual(begining.value(), "edcab")

    def test_can_seek_forward_indifinitely_without_going_beyond_zeroth_char(self):
        self.char_elem.push('b')
        end = self.char_elem.next()
        end.push('c')
        end = end.next().next().next().next()
        end.push('d')
        end = end.next()
        end.push('e')
        self.char_elem.next().next().push('Z')
        self.assertEqual(self.char_elem.value(), "abcZde")

    def test_can_seek_begining(self):
        c = self.char_elem.push('b').push('c')
        self.assertEqual(c.value(), 'c')
        self.assertEqual(c.begining().value(), "abc")

    def test_can_delete_current_element_and_return_next(self):
        self.char_elem.push('b').push('c').push('d')
        b = self.char_elem.delete_current()
        self.assertEqual(b.value(), "bcd")

    def test_can_delete_next_element_and_return_current(self):
        self.char_elem.push('b').push('c').push('d')
        b = self.char_elem.delete_next()
        self.assertEqual(b.value(), "acd")
    
    def test_deletion_works_on_edges(self):
        buffer = self.char_elem.delete_next().delete_next()
        self.assertEqual(buffer.value(), "a")
        buffer = self.char_elem.previous().delete_current().delete_current()
        self.assertEqual(buffer.value(), "a")

    def test_terminals_should_not_be_deletable(self):
        self.assertEqual(text_field.StartingCharElem(None).is_deletable(), False)
        self.assertEqual(text_field.EndingCharElem(None).is_deletable(), False)
        self.assertEqual(self.char_elem.is_deletable(), True)

    def test_empty_char_elem_populates_itself_on_first_push(self):
        elem = text_field.CharElem('')
        elem.push('a')
        elem.delete_next()
        self.assertEqual(elem.value(), "a")

if __name__ == '__main__':
    unittest.main()
