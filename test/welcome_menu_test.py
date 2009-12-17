import unittest
import env
import welcome_menu
import bakery_wizard
import mox
from util import game_util
import pygame
from common import text_button

class WelcomeMenuTest(unittest.TestCase):
    def setUp(self):
        self.bakery_wizard = object()
        self.window = welcome_menu.WelcomeMenu(self.bakery_wizard)
        self.screen = pygame.surface.Surface((10, 10))
        pygame.display.set_mode((10, 10))

    def test_knows_wizard(self):
        self.assertEqual(self.window.bakery_wizard, self.bakery_wizard)
        
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
        mock_factory.StubOutWithMock(self.window, 'initialize_buttons')
        self.window.initialize_buttons()
        mock_factory.ReplayAll()
        self.window.load(self.screen)
        self.assertEqual(self.window.bg, mock_bg_cake)
        mock_factory.VerifyAll()

    def test_button_initialization_adds_it_up_as_sprite_and_registers_as_subscriber(self):
        mock_factory = mox.Mox()
        mock_factory.StubOutWithMock(self.window, 'resume_game_action')
        self.window.resume_game_action()
        self.window.sprites = pygame.sprite.Group()
        self.window.initialize_button('resume_game_action', "Resume Game", 10, 20)
        button = self.window.sprites.sprites()[0]
        self.assertEqual(button.x(), 10)
        self.assertEqual(button.y(), 20)
        self.assertEqual(button.label, "Resume Game")
        self.assertTrue(self.window.has_subscriber(button))
        mock_factory.ReplayAll()
        button.handle(object())
        mock_factory.VerifyAll()

    def test_initializes_all_buttons(self):
        mock_factory = mox.Mox()
        mock_factory.StubOutWithMock(self.window, 'initialize_button')
        self.assertTrue(callable(self.window.resume_game_action))
        self.window.initialize_button('resume_game_action', 'Resume Game', 400, 200)
        self.assertTrue(callable(self.window.new_game_action))
        self.window.initialize_button('new_game_action', 'New Game', 400, 300)
        self.assertTrue(callable(self.window.load_save_action))
        self.window.initialize_button('load_save_action', 'Load or Save Game', 400, 400)
        self.assertTrue(callable(self.window.credits_action))
        self.window.initialize_button('credits_action', 'Credits', 400, 500)
        self.assertTrue(callable(self.window.about_action))
        self.window.initialize_button('about_action', 'About', 400, 600)
        self.assertTrue(callable(self.window.go_back_action))
        self.window.initialize_button('go_back_action', 'Go Back', 400, 700)
        self.assertTrue(callable(self.window.exit_action))
        self.window.initialize_button('exit_action', 'Exit', 400, 800)
        mock_factory.ReplayAll()
        self.window.load(self.screen)
        mock_factory.VerifyAll()

if __name__ == '__main__':
    unittest.main()
