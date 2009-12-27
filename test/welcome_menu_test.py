import unittest
import env
import welcome_menu
import bakery_wizard
import mox
from util import game_util
import pygame
from common import text_button
import sys

class WelcomeMenuTest(unittest.TestCase):
    def setUp(self):
        self.bakery_wizard = object()
        self.window = welcome_menu.WelcomeMenu(self.bakery_wizard)
        self.screen = pygame.surface.Surface((10, 10))
        pygame.display.set_mode((10, 10))
        self.window.screen = self.screen

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
        self.window.initialize_button('resume_game_action', "Resume Game", (10, 20))
        button = self.window.sprites.sprites()[0]
        self.assertEqual(button.x(), 10)
        self.assertEqual(button.y(), 20)
        self.assertEqual(button.label, "Resume Game")
        self.assertTrue(self.window.has_subscriber(button))
        mock_factory.ReplayAll()
        button.handle(object())
        mock_factory.VerifyAll()
    
    def assert_button_inited(self, button_callback, offset, label):
        self.assertTrue(callable(button_callback))
        mock_xy = object()
        self.window.button_xy(mox.IsA(pygame.surface.Surface), offset).AndReturn(mock_xy)
        self.window.initialize_button(button_callback.func_name, label, mock_xy)

    def test_initializes_all_buttons(self):
        mock_factory = mox.Mox()
        mock_factory.StubOutWithMock(self.window, 'initialize_button')
        mock_factory.StubOutWithMock(self.window, 'button_xy')
        self.assert_button_inited(self.window.resume_game_action, -3, "Resume Game")
        self.assert_button_inited(self.window.new_game_action, -2, "New Game")
        self.assert_button_inited(self.window.load_save_action, -1, "Load or Save Game")
        self.assert_button_inited(self.window.credits_action, 0, "Credits")
        self.assert_button_inited(self.window.about_action, 1, "About")
        self.assert_button_inited(self.window.go_back_action, 2, "Go Back")
        self.assert_button_inited(self.window.exit_action, 3, "Exit")
        mock_factory.ReplayAll()
        self.window.load(self.screen)
        mock_factory.VerifyAll()

    def test_button_xy_places_buttons_relative_to_center(self):
        button_image = pygame.surface.Surface((2, 2))
        self.assertEqual(self.window.button_xy(button_image, -2), (4, -156))
        self.assertEqual(self.window.button_xy(button_image, -1), (4, -76))
        self.assertEqual(self.window.button_xy(button_image, 0), (4, 4))
        self.assertEqual(self.window.button_xy(button_image, 1), (4, 84))
        self.assertEqual(self.window.button_xy(button_image, 2), (4, 164))

    def test_quit_button_quits(self):
        mock_factory = mox.Mox()
        mock_factory.StubOutWithMock(sys, 'exit')
        sys.exit(0)
        mock_factory.ReplayAll()
        self.window.exit_action()
        mock_factory.VerifyAll()

if __name__ == '__main__':
    unittest.main()
