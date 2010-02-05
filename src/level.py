import init
import config
import yaml

levels_file = file(config.LEVELS_FILE)
LEVEL_MAP = yaml.load(levels_file)
levels_file.close()

class Level:
    def __init__(self, level_number):
        self.level_data = LEVEL_MAP[level_number]

    def is_first(self):
        return self.level_data['first']

    def floor_path(self):
        return self.level_data.has_key('floor_path') and self.level_data['floor_path'] or 'floor.png'
        
    def table_path(self):
        return self.level_data.has_key('table_path') and self.level_data['table_path'] or 'table.png'

