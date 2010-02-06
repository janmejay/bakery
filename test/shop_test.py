import unittest
import env
import shop
import bakery_wizard
import pygame
from util import game_util
import mox
import zorder
from common import surface_sprite

class ShopTest(unittest.TestCase):
    def setUp(self):
        self.screen = pygame.surface.Surface((10, 10))
        self.wizard = bakery_wizard.BakeryWizard()
        self.window = shop.Shop(self.wizard)
        self.wizard.context['level'] = 1

    def test_is_base_window(self):
        self.assertTrue(isinstance(self.window, bakery_wizard.BaseWindow))

    def test_loads_level_floor(self):
        self.window.load(self.screen)
        self.assertEqual('floor.png', self.window.sprites.get_sprite(0).image_path)

if __name__ == '__main__':
    unittest.main()
