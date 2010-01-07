import unittest
import env
import story_player
import bakery_wizard, shop
import pygame
from util import game_util
import mox
import os

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
        mock_factory.StubOutWithMock(bakery_wizard.BaseWindow, 'load')
        image_1 = pygame.surface.Surface((1, 1))
        image_2 = pygame.surface.Surface((2, 2))
        image_3 = pygame.surface.Surface((3, 3))

        game_util.load_image('stories/jan/3.png').AndReturn(image_3)
        game_util.load_image('stories/jan/2.png').AndReturn(image_2)
        game_util.load_image('stories/jan/1.png').AndReturn(image_1)
        bakery_wizard.BaseWindow.load(self.window, self.screen)
        game_util.load_image('arrow_button.png').AndReturn(pygame.surface.Surface((20, 20)))
        mock_factory.ReplayAll()
        self.window.load(self.screen);
        mock_factory.VerifyAll()
        self.assertEqual([image_3, image_2], self.window.story_screens)
        self.assertEqual(image_1, self.window.bg)
        
    def test_hooks_up_go_button_as_sprite_and_listener(self):
        self.window.load(self.screen)
        button = self.window.sprites.sprites()[0]
        button_rect = button.rect
        self.assertEqual(930, button_rect.x)
        self.assertEqual(680, button_rect.y)
        arrow_rectangle = game_util.load_image('arrow_button.png').get_rect()
        self.assertEqual(arrow_rectangle.h, button_rect.h)
        self.assertEqual(arrow_rectangle.h, button_rect.h)

    def test_has_story_images_for_levels_from_1_to_12(self):
        expected_story_dir_names = [os.path.join('stories', name) for name in story_player.StoryPlayer.MONTHS]
        expected_story_files = [os.listdir(game_util.media(name)) for name in expected_story_dir_names]
        for files in expected_story_files:
            files.sort()
            self.assertEqual('1.png', files[0])

    def test_bg_transitions_to_next_screen_when_go_is_clicked(self):
        self.window.load(self.screen)
        self.window.story_screens = ['b', 'a']
        self.assertEqual(len(self.window.story_screens), 2)
        self.window.go()
        self.assertEqual('a', self.window.bg)
        self.assertEqual(1, len(self.window.story_screens))
        self.window.go()
        self.assertEqual('b', self.window.bg)
        self.assertEqual(0, len(self.window.story_screens))

    def test_loads_shop_after_exausting_story_images(self):
        self.window.load(self.screen)
        self.window.story_screens = []
        mock_factory = mox.Mox()
        mock_factory.StubOutWithMock(self.wizard, 'show')
        self.wizard.show(mox.IsA(shop.Shop(self.screen)))
        mock_factory.ReplayAll()
        self.window.go()
        mock_factory.VerifyAll()

if __name__ == '__main__':
    unittest.main()
