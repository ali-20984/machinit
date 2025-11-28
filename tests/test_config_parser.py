import unittest
import sys
import os
import tempfile

# Add lib to path
sys.path.append(os.path.join(os.path.dirname(__file__), '../lib'))

# We need to import the parser logic. 
# Since config_parser.py is a script, we might need to refactor it to be importable 
# or just test it via subprocess. 
# Let's assume we can import it if we modify it slightly, but for now let's test via subprocess 
# to avoid modifying the lib structure too much if it's just a script.
# Actually, let's try to import it. If it has `if __name__ == "__main__":`, it's safe.

import subprocess

class TestConfigParser(unittest.TestCase):
    def setUp(self):
        self.parser_script = os.path.join(os.path.dirname(__file__), '../lib/config_parser.py')
        self.test_toml = tempfile.NamedTemporaryFile(mode='w+', delete=False)
        self.test_toml.write('''
[section]
key = "value"
number = 123
bool_true = true
bool_false = false

[scripts]
"001_script.sh" = true
"002_script.sh" = false
''')
        self.test_toml.close()

    def tearDown(self):
        os.unlink(self.test_toml.name)

    def run_parser(self, key):
        result = subprocess.run(
            ['python3', self.parser_script, self.test_toml.name, key],
            capture_output=True,
            text=True
        )
        return result.stdout.strip()

    def test_get_string(self):
        self.assertEqual(self.run_parser('section.key'), 'value')

    def test_get_number(self):
        self.assertEqual(self.run_parser('section.number'), '123')

    def test_get_bool_true(self):
        self.assertEqual(self.run_parser('section.bool_true'), 'true')

    def test_get_bool_false(self):
        self.assertEqual(self.run_parser('section.bool_false'), 'false')

    def test_get_script_config(self):
        # Note: The shell script passes keys with quotes for scripts
        # scripts."001_script.sh"
        self.assertEqual(self.run_parser('scripts."001_script.sh"'), 'true')
        self.assertEqual(self.run_parser('scripts."002_script.sh"'), 'false')

    def test_missing_key(self):
        self.assertEqual(self.run_parser('section.missing'), '')

if __name__ == '__main__':
    unittest.main()
