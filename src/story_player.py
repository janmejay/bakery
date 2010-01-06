import bakery_wizard
import os
from util import game_util

class StoryPlayer(bakery_wizard.BaseWindow):
    MONTHS = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec']

    def load(self, screen):
        bakery_wizard.BaseWindow.load(self, screen)
        month_dir = os.path.join('stories', '%s') % StoryPlayer.MONTHS[self.bakery_wizard.context['level'] - 1]
        story_file_names = os.listdir(game_util.media(month_dir))
        story_file_names.sort()
        self.story_screens = [ game_util.load_image(os.path.join(month_dir, file_name)) for file_name in story_file_names ]
        
        
        
        

