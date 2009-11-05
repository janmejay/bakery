import sys
from os import path
TEST_DIR = path.dirname(path.realpath(__file__))

sys.path.append(path.join(TEST_DIR, "..", "src"))

import init

