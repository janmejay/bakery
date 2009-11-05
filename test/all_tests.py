import unittest
from actions_test import All

class AllTests(unittest.TestSuite):
    def __init__(self):
        self.add(All)

if __name__ == '__main__':
    unittest.main()
