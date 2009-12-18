import bakery_wizard
from util import game_util
from common import text_button

class WelcomeMenu(bakery_wizard.BaseWindow):

    Y_GAP = 80
    BUTTON_IMAGE_PATH = 'game_loader_button.png'

    def load(self, screen):
        self.bg = game_util.load_image('game_loader_bg.png')
        bakery_wizard.BaseWindow.load(self, screen)
        self.initialize_buttons()

    def initialize_buttons(self):
        image = game_util.load_image(WelcomeMenu.BUTTON_IMAGE_PATH)
        self.initialize_button('resume_game_action', 'Resume Game', self.button_xy(image, -3))
        self.initialize_button('new_game_action', 'New Game', self.button_xy(image, -2))
        self.initialize_button('load_save_action', 'Load or Save Game', self.button_xy(image, -1))
        self.initialize_button('credits_action', 'Credits', self.button_xy(image, 0))
        self.initialize_button('about_action', 'About', self.button_xy(image, 1))
        self.initialize_button('go_back_action', 'Go Back', self.button_xy(image, 2))
        self.initialize_button('exit_action', 'Exit', self.button_xy(image, 3))

    def initialize_button(self, action_method, label, point):
        button = text_button.TextButton(self, action_method, self, label = label, x = point[0], y = point[1], image_path = WelcomeMenu.BUTTON_IMAGE_PATH, size = 30)
        self.sprites.add(button)
        self.register(button)

    def button_xy(self, surface, offset):
        xy = self.center_xy(surface)
        return (xy[0], xy[1] + offset*WelcomeMenu.Y_GAP)

    def resume_game_action(self):
        pass

    def new_game_action(self):
        pass

    def load_save_action(self):
        pass

    def credits_action(self):
        pass

    def about_action(self):
        pass

    def go_back_action(self):
        pass

    def exit_action(self):
        pass


