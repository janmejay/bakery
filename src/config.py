from os import path, makedirs

VERSION = 'in-development'
BAKERY_SRC = path.dirname(path.realpath(__file__))
BAKERY_HOME = path.abspath(path.join(BAKERY_SRC, ".."))
BAKERY_TMP = path.expanduser(path.join("~", ".bakery"))
BAKERY_DATA = path.join(BAKERY_SRC, "..", "data")
LEVELS_FILE = path.abspath(path.join(BAKERY_DATA, "levels.yml"))

path.exists(BAKERY_TMP) or makedirs(BAKERY_TMP)


