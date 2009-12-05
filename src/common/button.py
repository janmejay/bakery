import pygame
from util import game_util, actions
import zorder

class Button(pygame.sprite.DirtySprite, actions.ActiveRectangleSubscriber):
    def __init__(self, owner, callback, publisher, x, y, image_path = 'default.png', layer = zorder.BUTTONS):
        pygame.sprite.DirtySprite.__init__(self)
        self.layer, self.image = layer, game_util.load_image(image_path)
        self.rect = self.image.get_rect()
        self.rect.move_ip(x, y)
        actions.ActiveRectangleSubscriber.__init__(self, x, y, self.rect.width, self.rect.height)
        self.__callback = getattr(owner, callback)
        self.__publisher = publisher
        
    def handle(self, event):
        self.__callback()

    def activate(self):
        self.__publisher.register(self)

    def deactivate(self):
        self.__publisher.unregister(self)

        
