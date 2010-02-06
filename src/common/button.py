import pygame
from util import game_util, actions
import zorder
import surface_sprite

class Button(surface_sprite.SurfaceSprite, actions.ActiveRectangleSubscriber):
    def __init__(self, owner, callback, publisher, x, y, image_path = 'default.png', layer = zorder.BUTTONS):
        surface_sprite.SurfaceSprite.__init__(self, x, y, image_path, layer)
        actions.ActiveRectangleSubscriber.__init__(self, x, y, self.rect.width, self.rect.height)
        self.__callback = getattr(owner, callback)
        self.__publisher = publisher
        
    def handle(self, event):
        self.__callback()

    def activate(self):
        self.__publisher.register(self)

    def deactivate(self):
        self.__publisher.unregister(self)

        
