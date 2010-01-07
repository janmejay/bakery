import bakery_wizard, shop
import os
from util import game_util
from common import text_button
import pygame

class StoryPlayer(bakery_wizard.BaseWindow):
    MONTHS = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec']

    def load(self, screen):
        bakery_wizard.BaseWindow.load(self, screen)
        month_dir = os.path.join('stories', '%s') % StoryPlayer.MONTHS[self.bakery_wizard.context['level'] - 1]
        story_file_names = os.listdir(game_util.media(month_dir))
        story_file_names.sort()
        story_file_names.reverse()
        self.story_screens = [ game_util.load_image(os.path.join(month_dir, file_name)) for file_name in story_file_names ]
        self.__assign_next_background()

        go_button = text_button.TextButton(self, 'go', self, 930, 680, label = "GO!!!", size = 35, color = pygame.color.Color(0x42111100), image_path = "arrow_button.png")
        self.sprites.add(go_button)
        self.register(go_button)

    def go(self):
        self.__assign_next_background()
        shop_window = shop.Shop(self.bakery_wizard.screen)
        self.bakery_wizard.show(shop_window)

    def __assign_next_background(self):
        if len(self.story_screens) > 0:
            self.bg = self.story_screens.pop()
        
        
        
        

