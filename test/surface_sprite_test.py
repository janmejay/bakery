import unittest
import env
import pygame
from common import surface_sprite

class SurfaceSpriteTest(unittest.TestCase):
    def setUp(self):
        pygame.display.set_mode((10, 10))
        self.dimensions = {'x' : 5, 'y' : 6}

    def test_has_image(self):
        button_instance = surface_sprite.SurfaceSprite(**self.dimensions)
        self.assertTrue(button_instance.image != None)
        self.assertTrue(isinstance(button_instance.image, pygame.Surface))

    def test_honors_image_path_given(self):
        self.dimensions['image_path'] = 'test_rgb.png'
        button_instance = surface_sprite.SurfaceSprite(**self.dimensions)
        self.assertEqual(button_instance.image.get_at((0,0)), (255, 0, 0, 255))
        self.assertEqual(button_instance.image.get_at((1,0)), (0, 255, 0, 255))
        self.assertEqual(button_instance.image.get_at((2,0)), (0, 0, 255, 255))
    
    def test_has_rect(self):
        button_instance = surface_sprite.SurfaceSprite(**self.dimensions)
        self.assertTrue(isinstance(button_instance.rect, pygame.Rect))
        self.assertEqual(button_instance.rect.left, self.dimensions['x'])
        self.assertEqual(button_instance.rect.top, self.dimensions['y'])
        self.assertEqual(button_instance.rect.width, button_instance.image.get_rect().width)
        self.assertEqual(button_instance.rect.height, button_instance.image.get_rect().height)

    def test_is_dirty_sprite(self):
        button_instance = surface_sprite.SurfaceSprite(**self.dimensions)
        self.assertTrue(isinstance(button_instance, pygame.sprite.DirtySprite))

    def test_records_image_file_name_to_help_with_testing(self):
        self.dimensions['image_path'] = 'test_rgb.png'
        button_instance = surface_sprite.SurfaceSprite(**self.dimensions)
        self.assertEqual('test_rgb.png', button_instance.image_path)

if __name__ == '__main__':
    unittest.main()
