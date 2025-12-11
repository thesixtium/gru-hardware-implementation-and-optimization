import sys
import re
import os
from pathlib import Path

def modify_num_parallel_in_file(filepath, new_num_parallel):
    """
    Modify NUM_PARALLEL parameter in a single file.

    Returns:
        True if modifications were made, False otherwise
    """
    try:
        with open(filepath, 'r') as f:
            content = f.read()

        original_content = content
        modified = False

        # Pattern 1: parameter int NUM_PARALLEL = <number>
        pattern1 = r'(parameter\s+int\s+NUM_PARALLEL\s*=\s*)\d+'
        if re.search(pattern1, content):
            content = re.sub(pattern1, rf'\g<1>{new_num_parallel}', content)
            modified = True

        # Pattern 2: localparam int NUM_PARALLEL = <number>
        pattern2 = r'(localparam\s+int\s+NUM_PARALLEL\s*=\s*)\d+'
        if re.search(pattern2, content):
            content = re.sub(pattern2, rf'\g<1>{new_num_parallel}', content)
            modified = True

        # Pattern 3: .NUM_PARALLEL(<number>)
        pattern3 = r'(\.NUM_PARALLEL\s*\(\s*)\d+(\s*\))'
        if re.search(pattern3, content):
            content = re.sub(pattern3, rf'\g<1>{new_num_parallel}\g<2>', content)
            modified = True

        if modified and content != original_content:
            # Create backup
            backup_file = str(filepath) + '.backup'
            with open(backup_file, 'w') as f:
                f.write(original_content)

            # Write modified content
            with open(filepath, 'w') as f:
                f.write(content)

            return True

        return False

    except Exception as e:
        print(f"Error modifying {filepath}: {e}")
        return False


def modify_num_parallel(base_path, new_num_parallel):
    """
    Modify NUM_PARALLEL in both top_level.sv and gru_cell_parallel.sv

    Args:
        base_path: Path to either the directory or one of the .sv files
        new_num_parallel: New value for NUM_PARALLEL
    """
    # Convert to Path object
    base_path = Path(base_path)

    # Determine the directory and files to modify
    if base_path.is_dir():
        directory = base_path
    else:
        directory = base_path.parent

    # Files to modify
    files_to_modify = [
        directory / "top_level.sv",
        directory / "gru_cell_parallel.sv",
        directory / "tb_gru_cell_parallel.sv"
    ]

    print(f"\nModifying NUM_PARALLEL to {new_num_parallel}")
    print("=" * 60)

    success_count = 0
    for filepath in files_to_modify:
        if filepath.exists():
            print(f"\nProcessing: {filepath.name}")
            if modify_num_parallel_in_file(filepath, new_num_parallel):
                print(f"  ✓ Successfully modified {filepath.name}")
                success_count += 1
            else:
                print(f"  ✗ No modifications made to {filepath.name}")
        else:
            print(f"  ⚠ File not found: {filepath}")

    print("\n" + "=" * 60)
    print(f"Modified {success_count} of {len(files_to_modify)} files")
    print("=" * 60 + "\n")

    return success_count > 0

if __name__ == "__main__":
    modify_num_parallel( r"C:\Users\ajrbe\Documents\School\Thesis\BCI\Code\gru_cell_parallel.sv", 10 )