import pygame
from util import game_util, actions
import zorder

class Button(pygame.sprite.DirtySprite, actions.ActiveRectangleSubscriber):
    def __init__(self, owner, callback, publisher, **options):
        pygame.sprite.DirtySprite.__init__(self)
        self.layer = (options.has_key('layer') and options.pop('layer')) or zorder.BUTTONS
        actions.ActiveRectangleSubscriber.__init__(self, **options)
        self.image = game_util.load_image('default.png')
        self.source_rect = self.image.get_rect()
        self.__callback = getattr(owner, callback)
        self.__publisher = publisher
        
    def handle(self, event):
        self.__callback()

    def activate(self):
        self.__publisher.register(self)

    def deactivate(self):
        self.__publisher.unregister(self)

        
