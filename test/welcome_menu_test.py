import unittest
import env
import welcome_menu
import bakery_wizard
import mox
from util import game_util
import pygame

class WelcomeMenuTest(unittest.TestCase):
    def setUp(self):
        self.window = welcome_menu.WelcomeMenu()
        self.screen = pygame.surface.Surface((10, 10))
        pygame.display.set_mode((10, 10))
        
    def test_is_base_window(self):
        self.assertTrue(isinstance(self.window, bakery_wizard.BaseWindow))

    def test_loads_up_background_in_load(self):
        self.assertFalse(hasattr(self.window, 'bg'))
        mock_factory = mox.Mox()
        mock_factory.StubOutWithMock(game_util, 'load_image')
        mock_factory.StubOutWithMock(bakery_wizard.BaseWindow, 'load')
        self.window.sprites = pygame.sprite.RenderPlain()
        bakery_wizard.BaseWindow.load(self.window, self.screen)
        mock_bg_cake = pygame.surface.Surface((10, 10))
        game_util.load_image('game_loader_bg.png').AndReturn(mock_bg_cake)
        mock_factory.ReplayAll()
        self.window.load(self.screen)
        self.assertEqual(self.window.bg, mock_bg_cake)
        mock_factory.VerifyAll()

if __name__ == '__main__':
    unittest.main()
