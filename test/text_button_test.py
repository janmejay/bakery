import unittest
import env
from util import actions
import mox
from common import button, text_button
from util import actions, game_util
import zorder
import pygame

class TextButtonTest(unittest.TestCase):
    class DummyOwner():
        def on_click(self):
            pass

    def setUp(self):
        pygame.display.set_mode((10, 10))
        pygame.font.init()
        self.dummy_owner = self.DummyOwner()
        self.publisher = actions.Publisher()
        self.options = {'x' : 5, 'y' : 6, 'label' : "hi there"}

    def test_is_a_button(self):
        button_instance = text_button.TextButton(self.dummy_owner, 'on_click', self.publisher, **self.options)
        self.assertTrue(isinstance(button_instance, button.Button))

    def test_has_image_as_text_over_image(self):
        mock_factory = mox.Mox()
        font = mock_factory.CreateMock(pygame.font.Font)
        font_surface = mock_factory.CreateMock(pygame.surface.Surface)
        mock_factory.StubOutWithMock(pygame, 'font')
        pygame.font.Font(game_util.media('hand.ttf'), 10).AndReturn(font)
        font.render(self.options['label'], True, (255, 255, 255)).AndReturn(font_surface)
        mock_factory.StubOutWithMock(game_util, 'load_image')
        image_surface = mock_factory.CreateMock(pygame.surface.Surface)
        image_surface.get_rect().AndReturn(pygame.rect.Rect(10, 10, 10, 10))
        game_util.load_image('default.png').AndReturn(image_surface)
        image_surface.blit(font_surface, (0, 0))
        mock_factory.ReplayAll()
        button_instance = text_button.TextButton(self.dummy_owner, 'on_click', self.publisher, **self.options)
        mock_factory.VerifyAll()
        self.assertEqual(button_instance.image, image_surface)

    def test_should_honor_font_file_name_size_and_text(self):
        mock_factory = mox.Mox()
        font = mock_factory.CreateMock(pygame.font.Font)
        font_surface = pygame.surface.Surface((10, 10))
        mock_factory.StubOutWithMock(pygame, 'font')
        pygame.font.Font(game_util.media('title.ttf'), 5).AndReturn(font)
        self.options['font'] = game_util.media('title.ttf')
        self.options['size'] = 5
        self.options['label'] = "Button Label"
        self.options['color'] = (10, 20, 30)
        font.render("Button Label", True, (10, 20, 30)).AndReturn(font_surface)
        mock_factory.ReplayAll()
        button_instance = text_button.TextButton(self.dummy_owner, 'on_click', self.publisher, **self.options)
        mock_factory.VerifyAll()


if __name__ == '__main__':
    unittest.main()
        
