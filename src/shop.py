import bakery_wizard
from common import surface_sprite
import zorder
import level

class Shop(bakery_wizard.BaseWindow):
    
    def load(self, screen):
        bakery_wizard.BaseWindow.load(self, screen)
        self.level = level.Level(self.bakery_wizard.context['level'])
        self.__set_floor();

    def __set_floor(self):
        floor = surface_sprite.SurfaceSprite(0, 0, self.level.floor_path(), zorder.BACKGROUND)
        self.sprites.add(floor)
