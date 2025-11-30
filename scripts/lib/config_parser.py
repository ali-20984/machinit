import sys
import tomllib
import os
import re


def get_config_value(config_path, key_path):
    try:
        with open(config_path, "rb") as f:
            data = tomllib.load(f)

        # Split by dot, but respect quotes
        # Regex matches a dot that is NOT followed by an odd number of quotes
        # This handles simple cases like section."key.with.dot".subkey
        keys = re.split(r'\.(?=(?:[^"]*"[^"]*")*[^"]*$)', key_path)

        value = data
        for key in keys:
            # Remove surrounding quotes if present
            if key.startswith('"') and key.endswith('"'):
                key = key[1:-1]

            value = value.get(key)
            if value is None:
                return ""

        if isinstance(value, list):
            print(" ".join(f'"{v}"' for v in value))
        elif isinstance(value, bool):
            print(str(value).lower())
        else:
            print(value)

    except Exception as e:
        # Fail silently or print error to stderr
        sys.stderr.write(f"Error reading config: {e}\n")
        return ""


if __name__ == "__main__":
    if len(sys.argv) < 3:
        sys.exit(1)

    config_path = sys.argv[1]
    key_path = sys.argv[2]

    if not os.path.exists(config_path):
        sys.exit(1)

    get_config_value(config_path, key_path)
