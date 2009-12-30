import unittest
import env
import story_player
import bakery_wizard
import pygame

class StoryPlayer(unittest.TestCase):
    def setUp(self):
        self.screen = pygame.surface.Surface((10, 10))
        self.wizard = bakery_wizard.BakeryWizard()
        self.window = story_player.StoryPlayer(self.wizard)

    def test_is_base_window(self):
        self.assertTrue(isinstance(self.window, bakery_wizard.BaseWindow))

if __name__ == '__main__':
    unittest.main()
