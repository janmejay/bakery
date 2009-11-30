import unittest
import env
from common import sub_select_dict

class SubSelectDictTest(unittest.TestCase):
    def setUp(self):
        self.base_dict = {'a' : 'b', 'c' : 'd', 'e' : 'f', 'g' : 'h'}
        self.dict = sub_select_dict.SubSelectDict(self.base_dict)
    
    def test_understands_equality_wrt_base_dict(self):
        self.assertEqual(self.dict, self.base_dict)

    def test_understands_subsetting_when_keys_to_be_included_present(self):
        self.assertEqual(self.dict.subset('a', 'e'), {'a' : 'b', 'e' : 'f'})

    def test_understands_subsetting_when_keys_to_be_included_not_present_and_omits_them(self):
        self.assertEqual(self.dict.subset('a', 'n'), {'a' : 'b'})

if __name__ == '__main__':
    unittest.main()
