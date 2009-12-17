import unittest
import env
import player_loader
import bakery_wizard
from util import game_util
import pygame
import mox
from common import text_button, text_field, label

class PlayerLoaderTest(unittest.TestCase):
    def setUp(self):
        self.bakery_wizard = object()
        self.window = player_loader.PlayerLoader(self.bakery_wizard)
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
        mock_loading_cake = pygame.surface.Surface((10, 10))
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
        for sprite in self.window.sprites:
            if isinstance(sprite, text_button.TextButton):
                self.assertEqual(sprite.x(), 670)
                self.assertEqual(sprite.y(), 545)
                mock_factory.ReplayAll()
                sprite.handle(object())
                mock_factory.VerifyAll()
                return
        self.fail("didn't find text button")

    def test_adds_up_label_as_sprite(self):
        mock_factory = mox.Mox()
        mock_factory.StubOutWithMock(self.window, 'load_welcome')
        self.window.load_welcome()
        self.window.load(self.screen)
        for sprite in self.window.sprites:
            if isinstance(sprite, label.Label):
                self.assertEqual(sprite.rect.left, 220)
                self.assertEqual(sprite.rect.top, 582)
                return
        self.fail("didn't find text button")

    def test_adds_up_text_field_as_sprite(self):
        self.window.load(self.screen)
        for sprite in self.window.sprites:
            if isinstance(sprite, text_field.TextField):
                self.assertEqual(sprite.x(), 450)
                self.assertEqual(sprite.y(), 582)
                self.assertEqual(sprite.dx(), 250)
                return
        self.fail("didn't find text field")

    def test_text_field_is_initialized_with_last_player_name(self):
        mock_factory = mox.Mox()
        mock_factory.StubOutWithMock(game_util.LastPlayer, 'get_name')
        game_util.LastPlayer.get_name().AndReturn("foo_bar")
        mock_factory.ReplayAll()
        self.window.load(self.screen)
        mock_factory.VerifyAll()
        for sprite in self.window.sprites:
            if isinstance(sprite, text_field.TextField):
                self.assertEqual(sprite.get_value(), "foo_bar")

    def test_field_is_registered_with_player_loader_as_a_subscriber_on_load(self):
        self.window.load(self.screen)
        field = None
        for sprite in self.window.sprites:
            if isinstance(sprite, text_field.TextField):
                field = sprite
        self.assertTrue(self.window.has_subscriber(field))

    def test_get_baking_button_is_registered_with_player_loader_as_a_subscriber_on_load(self):
        self.window.load(self.screen)
        button = None
        for sprite in self.window.sprites:
            if isinstance(sprite, text_button.TextButton):
                button = sprite
        self.assertTrue(self.window.has_subscriber(button))


    def test_writes_player_name_to_last_player_file_on_load_welcome(self):
        self.window.load(self.screen)
        mock_factory = mox.Mox()
        mock_factory.StubOutWithMock(game_util.LastPlayer, 'set_name')
        mock_factory.StubOutWithMock(self.window.text_field, 'get_value')
        self.window.text_field.get_value().AndReturn("foo_bar")
        game_util.LastPlayer.set_name("foo_bar")
        mock_factory.ReplayAll()
        self.window.load_welcome()
        mock_factory.VerifyAll()

    def test_update_should_call_update_on_text_field_before_draw(self):
        self.window.load(self.screen)
        self.window.text_field.image = pygame.surface.Surface((10,10))
        self.window.text_field.rect = self.window.text_field.image.get_rect()
        mock_factory = mox.Mox()
        self.window.text_field = mock_factory.CreateMock(text_field.TextField)
        self.window.text_field.update()
        mock_factory.ReplayAll()
        self.window.draw()
        mock_factory.VerifyAll()

if __name__ == '__main__':
    unittest.main()
        
