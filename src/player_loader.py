from util import game_util
import bakery_wizard
import pygame
from common import text_button, text_field

class PlayerLoader(bakery_wizard.BaseWindow):
    
    def __init__(self):
        bakery_wizard.BaseWindow.__init__(self)
        
    def load(self, screen):
        bakery_wizard.BaseWindow.load(self, screen)
        self.bg = game_util.load_image('loading-cake.png')
        self.sprites.add(text_button.TextButton(self, 'load_welcome', self, label = 'Get baking', x = 450, y = 450, dx = 100, dy = 100, image_path = 'get_baking_button.png'))
        self.text_field = text_field.TextField(text_field.Manager(), x = 350, y = 300, dx = 100, value = game_util.LastPlayer.get_name())
        self.sprites.add(self.text_field)

    def draw(self):
        self.text_field.update()
        bakery_wizard.BaseWindow.draw(self)

    def load_welcome(self):
        game_util.LastPlayer.set_name(self.text_field.get_value())
        
