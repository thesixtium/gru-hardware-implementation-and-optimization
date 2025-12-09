import sys
import re
import os


def modify_num_parallel(sv_file, new_value):
    """
    Modify the NUM_PARALLEL parameter in a SystemVerilog file.

    Args:
        sv_file: Path to the SystemVerilog file
        new_value: New value for NUM_PARALLEL (integer)
    """
    try:
        # Read the file
        with open(sv_file, 'r') as f:
            content = f.read()

        # Pattern to match: parameter int NUM_PARALLEL = <any_number>
        # This pattern handles various spacing and formatting
        pattern = r'(parameter\s+int\s+NUM_PARALLEL\s*=\s*)\d+'

        # Replace with new value
        new_content = re.sub(pattern, rf'\g<1>{new_value}', content)

        # Check if replacement was made
        if new_content == content:
            print(f"Warning: NUM_PARALLEL parameter not found in {sv_file}")
            print("Looking for pattern: 'parameter int NUM_PARALLEL = <number>'")
            return False

        # Create backup
        backup_file = sv_file + '.backup'
        with open(backup_file, 'w') as f:
            f.write(content)
        print(f"Backup created: {backup_file}")

        # Write modified content
        with open(sv_file, 'w') as f:
            f.write(new_content)

        print(f"Successfully updated NUM_PARALLEL parameter:")
        print(f"  File: {sv_file}")
        print(f"  New value: {new_value}")

        return True

    except FileNotFoundError:
        print(f"Error: File '{sv_file}' not found")
        return False
    except Exception as e:
        print(f"Error: {e}")
        return False

if __name__ == "__main__":
    modify_num_parallel( r"C:\Users\ajrbe\Documents\School\Thesis\BCI\Code\gru_cell_parallel.sv", 10 )