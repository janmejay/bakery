import pygame
from util import game_util, actions
import zorder

class Button(pygame.sprite.DirtySprite, actions.ActiveRectangleSubscriber):
    def __init__(self, owner, callback, publisher, x, y, dx, dy, image_path = 'default.png', layer = zorder.BUTTONS):
        pygame.sprite.DirtySprite.__init__(self)
        self.layer, self.image = layer, game_util.load_image(image_path)
        self.source_rect = self.image.get_rect()
        actions.ActiveRectangleSubscriber.__init__(self, x, y, dx, dy)
        self.__callback = getattr(owner, callback)
        self.__publisher = publisher
        
    def handle(self, event):
        self.__callback()

    def activate(self):
        self.__publisher.register(self)

    def deactivate(self):
        self.__publisher.unregister(self)

        
