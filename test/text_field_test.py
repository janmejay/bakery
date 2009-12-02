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
        self.assertEqual(field_instance.dy(), self.field_instance.font.get_height() + 4)

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
        key_a = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = u'a'))
        self.field_instance.handle(key_a)
        self.assertEqual(self.field_instance.get_value(), "a")

    def test_is_dirty_sprite_and_starts_out_dirty(self):
        self.assertTrue(isinstance(self.field_instance, pygame.sprite.DirtySprite))
        self.assertTrue(self.field_instance.dirty, 1)

    def test_uses_surface_of_same_size_as_ui(self):
        field_instance = text_field.TextField(self.manager, dx = 200)
        field_instance.update()
        self.assertTrue(isinstance(field_instance.image, pygame.surface.Surface))
        border_width = text_field.TextField.BORDER_WIDTH
        self.assertEqual(field_instance.image.get_rect(), pygame.rect.Rect(0, 0, 200 + border_width, 13))

    def test_draws_border_and_fills_up_image_with_color(self):
        field_instance = text_field.TextField(self.manager, dx = 200, border_color = (255, 0, 0, 0), font_size = 30)
        field_instance.update()
        self.assertEqual(field_instance.image.get_at((100, 15)), (0, 0, 0, 255))
        red = (255, 0, 0, 255) # if surface doesn't have per pixel alpha, then alpha value is 255
        self.assertEqual(field_instance.image.get_at((1, 22)), red)
        self.assertEqual(field_instance.image.get_at((100, 1)), red)
        self.assertEqual(field_instance.image.get_at((199, 1)), red)
        self.assertEqual(field_instance.image.get_at((199, 22)), red)
        self.assertEqual(field_instance.image.get_at((199, 45)), red)
        self.assertEqual(field_instance.image.get_at((100, 45)), red)
        self.assertEqual(field_instance.image.get_at((1, 45)), red)

    def test_marks_itself_dirty_only_after_handling_actions(self):
        self.field_instance.handle(actions.Action(actions.LEFT_CLICK, 10, 10))
        key_a = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = u'a'))
        self.field_instance.dirty = 0
        self.field_instance.handle(key_a)
        self.assertEqual(self.field_instance.dirty, 1)

    def test_initializes_its_font_based_on_name_and_size_and_honors_passed_in_values_over_defaults(self):
        self.assertEqual(self.field_instance.font.get_height(), 7)
        field_instance = text_field.TextField(self.manager, font_file = "title.ttf")
        self.assertEqual(field_instance.font.get_height(), 10)
        field_instance = text_field.TextField(self.manager, font_size = 6)
        self.assertEqual(field_instance.font.get_height(), 9)

    def test_renders_font_onto_image_when_updated_with_dirty_flag_off(self):
        self.field_instance.dirty = 0
        mock_factory = mox.Mox()
        self.field_instance.font = mock_factory.CreateMock(pygame.font.Font)
        mock_factory.ReplayAll()
        self.field_instance.update()
        mock_factory.VerifyAll()

    def test_renders_font_in_the_correct_color(self):
        font_color = (255, 100, 100, 0)
        field_instance = text_field.TextField(self.manager, font_color = font_color)
        mock_factory = mox.Mox()
        field_instance.font = mock_factory.CreateMock(pygame.font.Font)
        font_surface = pygame.surface.Surface((20, 20))
        field_instance.font.render("", True, font_color).AndReturn(font_surface)
        field_instance.font.get_height().AndReturn(20)
        mock_factory.StubOutWithMock(field_instance, 'cursor_x')
        field_instance.cursor_x().AndReturn(10)
        field_instance.cursor_x().AndReturn(10)
        field_instance.handle(actions.Action(actions.LEFT_CLICK, 50, 3))
        mock_factory.ReplayAll()
        field_instance.update()
        mock_factory.VerifyAll()

    def test_understands_current_cursor_x_and_coordinates(self):
        click = actions.Action(actions.LEFT_CLICK, 50, 3)
        key_a = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = u'a'))
        key_b = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = u'b'))
        key_left = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = u'', key = 276))
        key_c = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = u'c'))
        field_instance_with_x_and_y = text_field.TextField(self.manager, x = 100, y = 200)
        self.field_instance.handle(click)
        self.field_instance.handle(key_a)
        self.field_instance.handle(key_b)
        self.field_instance.handle(key_c)
        self.field_instance.handle(key_left)
        glyph = self.field_instance.font.render("ab", True, text_field.TextField.DEFAULT_COLOR)
        field_instance_with_x_and_y.handle(click)
        field_instance_with_x_and_y.handle(key_a)
        field_instance_with_x_and_y.handle(key_b)
        field_instance_with_x_and_y.handle(key_c)
        field_instance_with_x_and_y.handle(key_left)
        cursor_x = glyph.get_width() + text_field.TextField.BORDER_WIDTH
        self.assertEqual(self.field_instance.cursor_x(), cursor_x)
        self.assertEqual(self.field_instance.cursor_top(), (cursor_x, 4))
        self.assertEqual(self.field_instance.cursor_bottom(), (cursor_x, glyph.get_height() - 4))
        self.assertEqual(field_instance_with_x_and_y.cursor_x(), 100 + cursor_x)
        self.assertEqual(field_instance_with_x_and_y.cursor_top(), (100 + cursor_x, 200 + 4))
        self.assertEqual(field_instance_with_x_and_y.cursor_bottom(), (100 + cursor_x, 200 + glyph.get_height() - 4))

    def test_renders_font_and_cursor_onto_image_when_updated_with_dirty_flag_on(self):
        font_color = (0, 0, 0, 0)
        self.field_instance.handle(actions.Action(actions.LEFT_CLICK, 50, 3))
        key_a = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = u'a'))
        self.field_instance.handle(key_a)
        mock_factory = mox.Mox()
        self.field_instance.font = mock_factory.CreateMock(pygame.font.Font)
        self.field_instance.base_image = mock_factory.CreateMock(pygame.surface.Surface)
        image = mock_factory.CreateMock(pygame.surface.Surface)
        font_surface = pygame.surface.Surface((20, 20))
        self.field_instance.font.render("a", True, font_color).AndReturn(font_surface)
        self.field_instance.base_image.copy().AndReturn(image)
        image.blit(font_surface, (2, 2))
        mock_factory.StubOutWithMock(self.field_instance, 'cursor_top')
        mock_factory.StubOutWithMock(self.field_instance, 'cursor_bottom')
        self.field_instance.cursor_top().AndReturn((5, 10))
        self.field_instance.cursor_bottom().AndReturn((5, 20))
        mock_factory.StubOutWithMock(pygame.draw, 'line')
        pygame.draw.line(image, (0, 0, 0, 0), (5, 10), (5, 20), 3)
        self.field_instance.handle(actions.Action(actions.LEFT_CLICK, 50, 3))
        mock_factory.ReplayAll()
        self.field_instance.update()
        mock_factory.VerifyAll()
        self.assertEqual(self.field_instance.image, image)

    def test_doesnot_show_cursor_onto_image_when_not_focused(self):
        font_color = (0, 0, 0, 0)
        self.field_instance.handle(actions.Action(actions.LEFT_CLICK, 50, 3))
        key_a = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = u'a'))
        self.field_instance.handle(key_a)
        mock_factory = mox.Mox()
        self.field_instance.font = mock_factory.CreateMock(pygame.font.Font)
        self.field_instance.base_image = mock_factory.CreateMock(pygame.surface.Surface)
        image = mock_factory.CreateMock(pygame.surface.Surface)
        font_surface = pygame.surface.Surface((20, 20))
        self.field_instance.font.render("a", True, font_color).AndReturn(font_surface)
        self.field_instance.base_image.copy().AndReturn(image)
        image.blit(font_surface, (2, 2))
        mock_factory.StubOutWithMock(self.field_instance, 'cursor_top')
        mock_factory.StubOutWithMock(self.field_instance, 'cursor_bottom')
        mock_factory.StubOutWithMock(pygame.draw, 'line')
        another_field_instance = text_field.TextField(self.manager)
        another_field_instance.handle(actions.Action(actions.LEFT_CLICK, 50, 3))
        mock_factory.ReplayAll()
        self.field_instance.update()
        mock_factory.VerifyAll()
        self.assertEqual(self.field_instance.image, image)

    def test_does_not_consume_key_events_when_not_focused(self):
        key_a = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = u'a'))
        self.field_instance.handle(key_a)
        self.assertEqual(self.field_instance.get_value(), "")
        self.field_instance.handle(actions.Action(actions.LEFT_CLICK, 50, 3))
        self.field_instance.handle(key_a)
        self.assertEqual(self.field_instance.get_value(), "a")

class BufferTest(unittest.TestCase):
    def setUp(self):
        self.buffer = text_field.Buffer()
    
    def test_starts_empty_with_cursor(self):
        self.assertEqual(self.buffer.cursor_pos(), 0)
        self.assertEqual(self.buffer.text(), "")

    def test_understands_left_and_right_arrow_keys(self):
        key_a = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = u'a'))
        key_w = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = u'w'))
        key_s = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = u's'))
        key_e = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = u'e'))
        key_t = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = u't'))
        left = pygame.event.Event(KEYDOWN, key = 276, unicode = '')
        right = pygame.event.Event(KEYDOWN, key = 275, unicode = '')
        self.buffer.record(key_a)
        self.buffer.record(actions.Action(actions.KEY, obj = left))
        self.buffer.record(key_w)
        self.buffer.record(actions.Action(actions.KEY, obj = left))
        self.buffer.record(key_s)
        self.buffer.record(actions.Action(actions.KEY, obj = right))
        self.buffer.record(key_e)
        self.buffer.record(key_t)
        self.assertEqual(self.buffer.text(), "sweta")

    def test_returns_values_before_cursor(self):
        key_a = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = u'a'))
        key_w = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = u'w'))
        key_s = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = u's'))
        left = pygame.event.Event(KEYDOWN, key = 276, unicode = '')
        right = pygame.event.Event(KEYDOWN, key = 275, unicode = '')
        self.buffer.record(key_a)
        self.buffer.record(actions.Action(actions.KEY, obj = left))
        self.buffer.record(key_w)
        self.buffer.record(actions.Action(actions.KEY, obj = left))
        self.buffer.record(key_s)
        self.buffer.record(actions.Action(actions.KEY, obj = right))
        self.assertEqual(self.buffer.text_before_cursor(), "sw")

    def test_understands_left_and_right_arrow_keys_and_does_not_go_wrong_on_edges(self):
        key_a = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = u'a'))
        key_w = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = u'w'))
        key_s = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = u's'))
        key_e = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = u'e'))
        key_t = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = u't'))
        left = pygame.event.Event(KEYDOWN, key = 276, unicode = u'')
        right = pygame.event.Event(KEYDOWN, key = 275, unicode = u'')
        self.buffer.record(key_a)
        for i in range(0, 5):
            self.buffer.record(actions.Action(actions.KEY, obj = right))
        self.buffer.record(actions.Action(actions.KEY, obj = left))
        self.buffer.record(key_w)
        for i in range(0, 10):
            self.buffer.record(actions.Action(actions.KEY, obj = right))
        for i in range(0, 4):
            self.buffer.record(actions.Action(actions.KEY, obj = left))
        self.buffer.record(key_s)
        self.buffer.record(actions.Action(actions.KEY, obj = right))
        self.buffer.record(key_e)
        self.buffer.record(key_t)
        self.assertEqual(self.buffer.text(), "sweta")

    def test_understands_deletion_and_backspace(self):
        key_a = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = u'a'))
        key_w = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = u'w'))
        key_s = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = u's'))
        key_e = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = u'e'))
        key_t = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = u't'))
        key_W = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = u'W'))
        key_X = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = u'X'))
        key_Y = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = u'Y'))
        key_Z = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = u'Z'))
        self.buffer.record(key_W)
        self.buffer.record(key_s)
        self.buffer.record(key_X)
        self.buffer.record(key_w)
        self.buffer.record(key_X)
        self.buffer.record(key_Y)
        self.buffer.record(key_e)
        self.buffer.record(key_X)
        self.buffer.record(key_Y)
        self.buffer.record(key_Z)
        self.buffer.record(key_t)
        self.buffer.record(key_W)
        self.buffer.record(key_X)
        self.buffer.record(key_Y)
        self.buffer.record(key_Z)
        self.buffer.record(key_a)
        self.buffer.record(key_Z)
        self.assertEqual(self.buffer.text(), "WsXwXYeXYZtWXYZaZ")
        key_bksp = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = u'\x08', key = 8))
        key_del = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, unicode = u'\x7f', key = 127))
        key_left = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, key = 275, unicode = u''))
        key_right = actions.Action(actions.KEY, obj = pygame.event.Event(KEYDOWN, key = 276, unicode = u''))
        self.buffer.record(key_bksp)
        self.buffer.record(key_left)
        for i in range(0, 3):
            self.buffer.record(key_bksp)
        for i in range(0, 20):
            self.buffer.record(key_left)
        self.buffer.record(key_del)
        self.buffer.record(key_right)
        self.buffer.record(key_del)
        self.buffer.record(key_right)
        for i in range(0, 1):
            self.buffer.record(key_del)
        self.buffer.record(key_right)
        for i in range(0, 2):
            self.buffer.record(key_del)
        
    def test_accepts_non_printable_chars_as_control(self):
        mock_factory = mox.Mox()
        mock_factory.StubOutWithMock(self.buffer, 'handle_navigation')
        delete_evt = pygame.event.Event(KEYDOWN, key = 127, unicode = u'\x7f')
        bksp_evt = pygame.event.Event(KEYDOWN, key = 8, unicode = u'\x08')
        right_evt = pygame.event.Event(KEYDOWN, key = 275, unicode = u'')
        left_evt = pygame.event.Event(KEYDOWN, key = 276, unicode = u'')
        a_evt = pygame.event.Event(KEYDOWN, key = 97, unicode = u'a')
        A_evt = pygame.event.Event(KEYDOWN, key = 97, unicode = u'A')
        slash_evt = pygame.event.Event(KEYDOWN, key = 47, unicode = u'/')
        at_evt = pygame.event.Event(KEYDOWN, key = 50, unicode = u'@')
        num_evt = pygame.event.Event(KEYDOWN, key = 49, unicode = u'1')
        paren_evt = pygame.event.Event(KEYDOWN, key = 57, unicode = u'(')
        self.buffer.handle_navigation(bksp_evt)
        self.buffer.handle_navigation(left_evt)
        self.buffer.handle_navigation(delete_evt)
        self.buffer.handle_navigation(left_evt)
        self.buffer.handle_navigation(right_evt)
        mock_factory.ReplayAll()
        self.buffer.record(actions.Action(actions.KEY, obj = at_evt))
        self.buffer.record(actions.Action(actions.KEY, obj = a_evt))
        self.buffer.record(actions.Action(actions.KEY, obj = A_evt))
        self.buffer.record(actions.Action(actions.KEY, obj = bksp_evt))
        self.buffer.record(actions.Action(actions.KEY, obj = left_evt))
        self.buffer.record(actions.Action(actions.KEY, obj = delete_evt))
        self.buffer.record(actions.Action(actions.KEY, obj = left_evt))
        self.buffer.record(actions.Action(actions.KEY, obj = right_evt))
        self.buffer.record(actions.Action(actions.KEY, obj = slash_evt))
        self.buffer.record(actions.Action(actions.KEY, obj = num_evt))
        self.buffer.record(actions.Action(actions.KEY, obj = paren_evt))
        mock_factory.VerifyAll()

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
