import unittest
import env
import level

class LevelTest(unittest.TestCase):
    def test_loads_current_level_data_for_player_context(self):
        lvl = level.Level(1)
        self.assertTrue(lvl.is_first())

    def test_knows_level_floor(self):
        lvl = level.Level(1)
        self.assertEqual("floor.png", lvl.floor_path())
        lvl = level.Level(9)
        self.assertEqual("outdoor_floor.png", lvl.floor_path())

    def test_knows_level_table(self):
        lvl = level.Level(1)
        self.assertEqual("table.png", lvl.table_path())
        lvl = level.Level(9)
        self.assertEqual("table_with_cloth.png", lvl.table_path())

if __name__ == '__main__':
    unittest.main()
