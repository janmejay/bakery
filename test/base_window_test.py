import unittest
import pygame
import env
import bakery_wizard
import mox
from util import actions
from pygame import constants
import sys

class BaseWindowTest(unittest.TestCase):
    def setUp(self):
        self.bakery_wizard = object()
        self.base_window = bakery_wizard.BaseWindow(self.bakery_wizard)
        self.mock_surface = pygame.surface.Surface((20,10))

    def test_sprites_is_layered_dirty_group(self):
        self.base_window.load(self.mock_surface)
        self.assertNotEqual(self.base_window.sprites, None)
        self.assertTrue(isinstance(self.base_window.sprites, pygame.sprite.LayeredDirty))

    def test_knows_wizard(self):
        self.assertEqual(self.base_window.bakery_wizard, self.bakery_wizard)

    def test_fills_up_screen_with_white_background_and_blits_actual_bg(self):
        mock_factory = mox.Mox()
        mock_surface = mock_factory.CreateMock(pygame.surface.Surface)
        mock_surface_copy = mock_factory.CreateMock(pygame.surface.Surface)
        mock_surface.copy().AndReturn(mock_surface_copy)
        mock_surface_copy.fill((255, 255, 255))
        mock_surface_copy.get_rect().AndReturn(pygame.rect.Rect(0, 0, 30, 40))
        self.base_window.bg = pygame.surface.Surface((30, 40))
        mock_surface_copy.blit(self.base_window.bg, (0, 0))
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
        self.base_window.load(self.mock_surface)
        self.base_window.bg = pygame.surface.Surface((10, 10))
        self.base_window.sprites = mock_sprites
        self.base_window.screen = mock_surface
        mock_sprites.draw(mock_surface, self.base_window.bg)
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

    def test_expands_bg_to_center_it_wrt_surface(self):
        self.base_window.bg = pygame.surface.Surface((2, 2))
        self.base_window.bg.fill((100, 100, 100))
        self.base_window.load(self.mock_surface)
        self.assertEqual(self.base_window.bg.get_rect(), pygame.rect.Rect(0, 0, 20, 10))
        self.assertEqual(self.base_window.bg.get_at((10, 5)), (100, 100, 100))
        self.assertEqual(self.base_window.bg.get_at((8, 5)), (255, 255, 255))
        self.assertEqual(self.base_window.bg.get_at((10, 3)), (255, 255, 255))
        self.assertEqual(self.base_window.bg.get_at((12, 5)), (255, 255, 255))
        self.assertEqual(self.base_window.bg.get_at((10, 7)), (255, 255, 255))

    def test_understands_if_has_bg_set(self):
        self.assertFalse(self.base_window.has_bg())
        self.base_window.bg = pygame.surface.Surface((10, 10))
        self.assertTrue(self.base_window.has_bg())

    def test_handles_quit(self):
        self.assertTrue(isinstance(self.base_window, actions.Subscriber))
        evt = pygame.event.Event(constants.KEYDOWN, scancode = 56, key = 98, unicode = u'b', mod =  4096)
        key_action = actions.Action(actions.KEY, evt)
        self.assertFalse(self.base_window.can_consume(key_action))

        evt = pygame.event.Event(constants.MOUSEBUTTONDOWN, button = 1, pos = (10, 15))
        click_action = actions.Action(actions.LEFT_CLICK, evt)
        self.assertFalse(self.base_window.can_consume(key_action))

    def test_quits_vm_on_window_handle(self):
        mock_factory = mox.Mox()
        mock_factory.StubOutWithMock(sys, 'exit')
        sys.exit(0)
        mock_factory.ReplayAll()
        self.base_window.handle(object())
        mock_factory.VerifyAll()

    def test_registers_itself_as_a_subscriber(self):
        self.base_window.load(self.mock_surface)
        self.assertTrue(self.base_window.has_subscriber(self.base_window))

    def test_adds_sprites_to_corresponding_layers(self):
        self.base_window.load(self.mock_surface)
        tenth = pygame.sprite.DirtySprite()
        tenth.layer = 10
        fifth = pygame.sprite.DirtySprite()
        fifth.layer = 5
        self.base_window.add_sprite(tenth)
        self.base_window.add_sprite(fifth)
        self.assertEqual(5, self.base_window.sprites.get_layer_of_sprite(fifth))
        self.assertEqual(10, self.base_window.sprites.get_layer_of_sprite(tenth))

if __name__ == '__main__':
    unittest.main()
