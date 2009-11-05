from util import game_util
import bakery_wizard
import pygame

class PlayerLoader(bakery_wizard.BaseWindow):
    
    def __init__(self):
        bakery_wizard.BaseWindow.__init__(self)
        
    def load(self, screen):
        bakery_wizard.BaseWindow.load(self, screen)
        self.__bg_center = game_util.load_image('loading-cake.png')
        self.__bg_center_coordinates = self.center_xy(self.__bg_center)
        
    def draw(self):
        bakery_wizard.BaseWindow.draw(self)
        self.screen.blit(self.__bg_center, self.__bg_center_coordinates)
        
        
