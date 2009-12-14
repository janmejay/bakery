import bakery_wizard
from util import game_util
from common import text_button

class WelcomeMenu(bakery_wizard.BaseWindow):
    def __init__(self):
        bakery_wizard.BaseWindow.__init__(self)

    def load(self, screen):
        self.bg = game_util.load_image('game_loader_bg.png')
        bakery_wizard.BaseWindow.load(self, screen)
        self.initialize_buttons()

    def initialize_buttons(self):
        self.initialize_button('resume_game_action', 'Resume Game', 400, 200)
        self.initialize_button('new_game_action', 'New Game', 400, 300)
        self.initialize_button('load_save_action', 'Load or Save Game', 400, 400)
        self.initialize_button('credits_action', 'Credits', 400, 500)
        self.initialize_button('about_action', 'About', 400, 600)
        self.initialize_button('go_back_action', 'Go Back', 400, 700)
        self.initialize_button('exit_action', 'Exit', 400, 800)

    def initialize_button(self, action_method, label, x, y):
        button = text_button.TextButton(self, action_method, self, label = label, x = x, y = y, image_path = 'game_loader_button.png', size = 30)
        self.sprites.add(button)
        self.register(button)

    def resume_game_action(self):
        pass

    def new_game_action(self):
        pass

    def credits_action(self):
        pass

    def about_action(self):
        pass

    def go_back_action(self):
        pass

    def exit_action(self):
        pass


