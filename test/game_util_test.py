import unittest
import env
import pygame
from util import game_util
import os

class GameUtilTest(unittest.TestCase):
    def setUp(self):
        pygame.display.set_mode((10, 10))
    
    def test_load_image_loads_files_from_media(self):
        surface = game_util.load_image('test_rgba.png')
        self.assertEqual(surface.get_at((0, 1)), (255, 0, 0, 255))
        self.assertEqual(surface.get_at((1, 1)), (0, 255, 0, 255))
        self.assertEqual(surface.get_at((2, 1)), (0, 0, 255, 255))
        self.assertEqual(surface.get_at((3, 1)), (0, 0, 0, 0))

    def test_loads_image_loads_files_from_media_without_alpha_convert(self):
        surface = game_util.load_image('test_rgb.png')
        self.assertEqual(surface.get_at((0, 1)), (255, 0, 0))
        self.assertEqual(surface.get_at((1, 1)), (0, 255, 0))
        self.assertEqual(surface.get_at((2, 1)), (0, 0, 255))

    def test_last_player_gets_saved_to_file(self):
        game_util.LastPlayer.set_name("FooBar")
        user_name = None
        with open(game_util.LastPlayer.LAST_PLAYER_FILE) as h:
            user_name = h.readline()
        self.assertEqual(user_name, "FooBar")
        self.assertEqual(game_util.LastPlayer.get_name(), "FooBar")

    def test_media_finds_files_under_media_dir(self):
        self.assertEqual(game_util.media("foo.png"), 
                         os.path.abspath(os.path.join(os.path.dirname(os.path.realpath(__file__)), "..", "media", "foo.png")))
        

if __name__ == '__main__':
    unittest.main()
