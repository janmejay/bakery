from util import callable
from os import path
import config

def resource(path):
    path.join(config.BAKERY_HOME, path)

def media(path):
    path.join(config.BAKERY_HOME, 'media')


class LastPlayer():
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
