import pygame
from util import game_util

class Label(pygame.sprite.DirtySprite):
    def __init__(self, font = 'hand.ttf', size = 10, color = (0, 0, 0), text = "", x = 0, y = 0):
        pygame.sprite.DirtySprite.__init__(self)
        self.font = pygame.font.Font(game_util.media(font), size)
        self.color = color
        self.x, self.y = x, y
        self.set_text(text)

    def set_text(self, text):
        self.dirty = 1
        self.image = self.font.render(text, True, self.color)
        self.rect = self.image.get_rect()
        self.rect.move_ip(self.x, self.y)
        
