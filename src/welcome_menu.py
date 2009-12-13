import bakery_wizard
from util import game_util

class WelcomeMenu(bakery_wizard.BaseWindow):
    def __init__(self):
        bakery_wizard.BaseWindow.__init__(self)

    def load(self, screen):
        self.bg = game_util.load_image('game_loader_bg.png')
        bakery_wizard.BaseWindow.load(self, screen)


