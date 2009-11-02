from util import game_util
from pygame import sprite

class PlayerLoader():
    
    def __init__(self):
        self.__sprites = sprite.RenderPlain()
        
    def load(self, screen):
        self.__screen = screen
        self.__bg = game_util.load_image('loading-cake.png')

    def draw(self):
        self.__screen.blit(self.__bg, (100, 100))
        
        
