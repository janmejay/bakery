import pygame
import init
import zorder
from util import game_util

class SurfaceSprite(pygame.sprite.DirtySprite):
    def __init__(self, x, y, image_path = 'default.png', layer = zorder.BUTTONS):
        pygame.sprite.DirtySprite.__init__(self)
        self.image_path = image_path
        self.layer, self.image = layer, game_util.load_image(self.image_path)
        self.rect = self.image.get_rect()
        self.rect.move_ip(x, y)
