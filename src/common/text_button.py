import button
import pygame
from util import game_util

class TextButton(button.Button):
    def __init__(self, *args, **options):
        font_path = (options.has_key('font') and options.pop('font')) or 'hand.ttf'
        font_size = (options.has_key('size') and options.pop('size')) or 10
        font_color = (options.has_key('color') and options.pop('color')) or (255, 255, 255)
        font = pygame.font.Font(game_util.media(font_path), font_size)
        font = font.render(options.pop('label'), True, font_color)
        button.Button.__init__(self, *args, **options)
        self.image.blit(font, (0, 0))
        
        
