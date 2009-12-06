import button
import pygame
from util import game_util
import zorder

class TextButton(button.Button):
    def __init__(self, owner, callback, publisher, x, y, label, font = 'hand.ttf', size = 10, color = (255, 255, 255), image_path = "default.png", layer = zorder.BUTTONS):
        font = pygame.font.Font(game_util.media(font), size)
        font = font.render(label, True, color)
        button.Button.__init__(self, owner, callback, publisher, x = x, y = y, image_path = image_path, layer = layer)
        glyph_rect = font.get_rect()
        self.image.blit(font, ((self.rect.width - glyph_rect.width)/2, (self.rect.height - glyph_rect.height)/2))
        
        
