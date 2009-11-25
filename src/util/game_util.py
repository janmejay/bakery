from util import callable
import config
import pygame
from pygame.compat import geterror
from os import path
import logging

logger = logging.getLogger('game_util')
logger.setLevel(logging.DEBUG)

def resource(file_name):
    return path.join(config.BAKERY_HOME, file_name)

def media(file_name):
    return path.join(config.BAKERY_HOME, 'media', file_name)


class LastPlayer:
    LAST_PLAYER_FILE = path.join(config.BAKERY_TMP, "player_name")
    def get_name():
        with open(LastPlayer.LAST_PLAYER_FILE, 'r') as h:
            player = h.readline()
        return player
    
    def set_name(player):
        with open(LastPlayer.LAST_PLAYER_FILE, 'w') as h:
            h.write(player)
    get_name = callable.Callable(get_name)
    set_name = callable.Callable(set_name)

def load_image(name, colorkey=None):
    fullname = media(name)
    try:
        image = pygame.image.load(fullname)
        if image.get_alpha() is None:
            image = image.convert()
        else:
            image = image.convert_alpha()
    except pygame.error, message:
        print 'Cannot load image:', fullname
        raise SystemExit(str(geterror()))
    if colorkey is not None:
        if colorkey is -1:
            colorkey = image.get_at((0,0))
        image.set_colorkey(colorkey, RLEACCEL)
    return image
