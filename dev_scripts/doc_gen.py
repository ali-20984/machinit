import os
import re

SCRIPTS_DIR = os.path.join(os.path.dirname(__file__), '../scripts')
README_PATH = os.path.join(os.path.dirname(__file__), '../README.md')

def get_script_description(filename):
    # Remove number prefix and extension
    name = re.sub(r'^\d+_', '', filename)
    name = name.replace('.sh', '')
    # Replace underscores with spaces and title case
    return name.replace('_', ' ').title()

def update_script_header(filepath, filename, description):
    with open(filepath, 'r') as f:
        content = f.read()
    
    # Fix existing author
    if "# Author: MachInit" in content:
        content = content.replace("# Author: MachInit", "# Author: supermarsx")
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Updated author for {filename}")
        return

    lines = content.splitlines(keepends=True)
    if not lines:
        return

    # Check if header exists
    if len(lines) > 1 and lines[1].startswith('# Script:'):
        return

    # Create header
    header = [
        f"#\n",
        f"# Script: {filename}\n",
        f"# Description: {description}\n",
        f"# Author: supermarsx\n",
        f"#\n"
    ]

    # Insert after shebang
    if lines[0].startswith('#!'):
        new_lines = [lines[0]] + header + lines[1:]
    else:
        new_lines = header + lines

    with open(filepath, 'w') as f:
        f.writelines(new_lines)
    
    print(f"Added header for {filename}")

def generate_readme_table():
    scripts = sorted([f for f in os.listdir(SCRIPTS_DIR) if f.endswith('.sh') and not f.startswith('utils')])
    
    table = []
    table.append("| Script | Description |")
    table.append("|--------|-------------|")
    
    for script in scripts:
        desc = get_script_description(script)
        # Update the file while we are at it
        update_script_header(os.path.join(SCRIPTS_DIR, script), script, desc)
        table.append(f"| `{script}` | {desc} |")
    
    return "\n".join(table)

if __name__ == "__main__":
    print("Updating script headers...")
    table = generate_readme_table()
    print("\nGenerated Table for README:\n")
    print(table)
