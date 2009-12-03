import unittest
import pygame
import env
import bakery_wizard
import mox
from util import actions

class BaseWindowTest(unittest.TestCase):
    def setUp(self):
        self.base_window = bakery_wizard.BaseWindow()
        self.mock_surface = pygame.surface.Surface((1024,768))

    def test_sprites_is_layered_dirty_group(self):
        self.base_window.load(self.mock_surface)
        self.assertNotEqual(self.base_window.sprites, None)
        self.assertTrue(isinstance(self.base_window.sprites, pygame.sprite.LayeredDirty))

    def test_fills_up_screen_with_white_background(self):
        mock_factory = mox.Mox()
        mock_surface = mock_factory.CreateMock(pygame.surface.Surface)
        mock_surface.fill((255, 255, 255))
        mock_factory.ReplayAll()
        self.base_window.load(mock_surface)
        mock_factory.VerifyAll()

    def test_knows_screen_after_load(self):
        self.assertFalse(hasattr(self.base_window, 'screen'))
        self.base_window.load(self.mock_surface)
        self.assertEqual(self.base_window.screen, self.mock_surface)

    def test_draws_all_sprites_to_screen(self):
        mock_factory = mox.Mox()
        mock_surface = mock_factory.CreateMock(pygame.surface.Surface)
        mock_sprites = mock_factory.CreateMock(pygame.sprite.LayeredDirty)
        self.base_window.screen = mock_surface
        self.base_window.sprites = mock_sprites
        mock_sprites.draw(mock_surface)
        mock_factory.ReplayAll()
        self.base_window.draw()
        mock_factory.VerifyAll()

    def test_draws_background_if_present(self):
        mock_factory = mox.Mox()
        mock_surface = mock_factory.CreateMock(pygame.surface.Surface)
        mock_sprites = mock_factory.CreateMock(pygame.sprite.LayeredDirty)
        self.base_window.screen = mock_surface
        self.base_window.sprites = mock_sprites
        self.base_window.bg = pygame.surface.Surface((10, 10))
        mock_sprites.draw(mock_surface, self.base_window.bg)
        mock_factory.ReplayAll()
        self.base_window.draw()
        mock_factory.VerifyAll()

    def test_is_publisher(self):
        self.assertTrue(isinstance(self.base_window, actions.Publisher))

if __name__ == '__main__':
    unittest.main()
