import unittest
import env
import story_player
import bakery_wizard
import pygame
from util import game_util
import mox

class StoryPlayer(unittest.TestCase):
    def setUp(self):
        self.screen = pygame.surface.Surface((10, 10))
        self.wizard = bakery_wizard.BakeryWizard()
        self.wizard.context['level'] = 1
        self.window = story_player.StoryPlayer(self.wizard)

    def test_is_base_window(self):
        self.assertTrue(isinstance(self.window, bakery_wizard.BaseWindow))

    def test_loads_images_for_the_corresponding_month(self):
        self.assertFalse(hasattr(self.window, 'story_screens'))
        mock_factory = mox.Mox()
        mock_factory.StubOutWithMock(game_util, 'load_image')
        image_1 = pygame.surface.Surface((10, 10))
        image_2 = pygame.surface.Surface((10, 10))
        image_3 = pygame.surface.Surface((10, 10))

        game_util.load_image('stories/jan/1.png').AndReturn(image_1)
        game_util.load_image('stories/jan/2.png').AndReturn(image_2)
        game_util.load_image('stories/jan/3.png').AndReturn(image_3)
        mock_factory.ReplayAll()
        self.window.load(self.screen);
        mock_factory.VerifyAll()
        self.assertEqual(self.window.story_screens, [image_1, image_2, image_3])


if __name__ == '__main__':
    unittest.main()
