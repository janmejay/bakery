import unittest
import env
from common import label
import pygame
import mox
from util import game_util

class LabelTest(unittest.TestCase):
    def test_is_dirty_sprite_and_starts_out_dirty(self):
        label_instance = label.Label()
        self.assertTrue(isinstance(label_instance, pygame.sprite.DirtySprite))
        self.assertEqual(label_instance.dirty, 1)
        self.assertTrue(isinstance(label_instance.image, pygame.surface.Surface))
        self.assertTrue(isinstance(label_instance.rect, pygame.rect.Rect))

    def test_should_accept_defualt_text_and_render_it_in_right_place_size_and_color(self):
        mock_factory = mox.Mox()
        font = mock_factory.CreateMock(pygame.font.Font)
        font_surface = mock_factory.CreateMock(pygame.surface.Surface)
        font_surface.get_rect().AndReturn(pygame.rect.Rect(0, 0, 30, 20))
        font.render("ABC def", True, (100, 100, 100)).AndReturn(font_surface)
        mock_factory.StubOutWithMock(pygame, 'font')
        pygame.font.Font(game_util.media('title.ttf'), 30).AndReturn(font)
        mock_factory.ReplayAll()
        label_instance = label.Label(text = "ABC def", size = 30, font = 'title.ttf', color = (100, 100, 100))
        mock_factory.VerifyAll()
        self.assertEqual(label_instance.image, font_surface)

    def test_positions_itself_at_given_x_y(self):
        label_instance = label.Label(text = "ABC def", x = 10, y = 20)
        self.assertEqual(label_instance.rect.left, 10)
        self.assertEqual(label_instance.rect.top, 20)

if __name__ == '__main__':
    unittest.main()
