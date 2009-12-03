import unittest
import env
import player_loader
import bakery_wizard
from util import game_util
import pygame
import mox
from common import text_button

class PlayerLoaderTest(unittest.TestCase):
    def setUp(self):
        self.window = player_loader.PlayerLoader()
        self.screen = pygame.surface.Surface((10, 10))
        pygame.display.set_mode((10, 10))
    
    def test_is_base_window(self):
        self.assertTrue(isinstance(self.window, bakery_wizard.BaseWindow))

    def test_loads_up_background_in_load(self):
        self.assertFalse(hasattr(self.window, 'bg'))
        mock_factory = mox.Mox()
        mock_factory.StubOutWithMock(game_util, 'load_image')
        mock_loading_cake = object()
        game_util.load_image('loading-cake.png').AndReturn(mock_loading_cake)
        game_util.load_image('get_baking_button.png').AndReturn(pygame.surface.Surface((10, 10)))
        mock_factory.ReplayAll()
        self.window.load(self.screen)
        self.assertEqual(self.window.bg, mock_loading_cake)
        mock_factory.VerifyAll()

    def test_adds_up_text_button_as_sprite(self):
        mock_factory = mox.Mox()
        mock_factory.StubOutWithMock(self.window, 'load_welcome')
        self.window.load_welcome()
        self.window.load(self.screen)
        found_text_button = False
        for sprite in self.window.sprites:
            if isinstance(sprite, text_button.TextButton):
                self.assertEqual(sprite.x(), 450)
                self.assertEqual(sprite.y(), 450)
                self.assertEqual(sprite.dx(), 100)
                self.assertEqual(sprite.dy(), 100)
                mock_factory.ReplayAll()
                sprite.handle(object())
                mock_factory.VerifyAll()
                return
        self.fail("didn't find text button")

if __name__ == '__main__':
    unittest.main()
        
