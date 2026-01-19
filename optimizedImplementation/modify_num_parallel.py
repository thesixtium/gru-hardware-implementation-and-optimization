import sys
import re
import os
from pathlib import Path


def modify_num_parallel(sv_file, num_parallel=None, int_bits=None, frac_bits=None, d=None, h=None):
    """
    Modify parameters in a SystemVerilog file.

    Args:
        sv_file: Path to the SystemVerilog file
        num_parallel: New value for NUM_PARALLEL (integer, optional)
        data_width: New value for DATA_WIDTH (integer, optional)
        frac_bits: New value for FRAC_BITS (integer, optional)
        d: New value for D (input dimension, integer, optional)
        h: New value for H (hidden dimension, integer, optional)
    """
    try:
        # Read the file
        with open(sv_file, 'r') as f:
            content = f.read()

        original_content = content
        changes_made = []

        # Update NUM_PARALLEL if provided
        if num_parallel is not None:
            pattern = r'((?:parameter|localparam)\s+int\s+NUM_PARALLEL\s*=\s*)\d+'
            new_content = re.sub(pattern, rf'\g<1>{num_parallel}', content)
            if new_content != content:
                changes_made.append(f"NUM_PARALLEL = {num_parallel}")
                content = new_content

        # Update INT_BITS if provided
        if int_bits is not None:
            pattern = r'((?:parameter|localparam)\s+int\s+INT_BITS\s*=\s*)\d+'
            new_content = re.sub(pattern, rf'\g<1>{int_bits}', content)
            if new_content != content:
                changes_made.append(f"INT_BITS = {int_bits}")
                content = new_content

        # Update FRAC_BITS if provided
        if frac_bits is not None:
            pattern = r'((?:parameter|localparam)\s+int\s+FRAC_BITS\s*=\s*)\d+'
            new_content = re.sub(pattern, rf'\g<1>{frac_bits}', content)
            if new_content != content:
                changes_made.append(f"FRAC_BITS = {frac_bits}")
                content = new_content

        # Update D if provided
        if d is not None:
            pattern = r'((?:parameter|localparam)\s+int\s+D\s*=\s*)\d+'
            new_content = re.sub(pattern, rf'\g<1>{d}', content)
            if new_content != content:
                changes_made.append(f"D = {d}")
                content = new_content

        # Update H if provided
        if h is not None:
            pattern = r'((?:parameter|localparam)\s+int\s+H\s*=\s*)\d+'
            new_content = re.sub(pattern, rf'\g<1>{h}', content)
            if new_content != content:
                changes_made.append(f"H = {h}")
                content = new_content

        # Check if any changes were made
        if content == original_content:
            print(f"Warning: No parameters were modified in {sv_file}")
            if num_parallel is not None:
                print("  - NUM_PARALLEL parameter not found")
            if int_bits is not None:
                print("  - INT_BITS parameter not found")
            if frac_bits is not None:
                print("  - FRAC_BITS parameter not found")
            if d is not None:
                print("  - D parameter not found")
            if h is not None:
                print("  - H parameter not found")
            return False

        # Create backup
        backup_file = sv_file + '.backup'
        with open(backup_file, 'w') as f:
            f.write(original_content)
        print(f"Backup created: {backup_file}")

        # Write modified content
        with open(sv_file, 'w') as f:
            f.write(content)

        print(f"Successfully updated parameters:")
        print(f"  File: {sv_file}")
        for change in changes_made:
            print(f"  - {change}")

        return True

    except FileNotFoundError:
        print(f"Error: File '{sv_file}' not found")
        return False
    except Exception as e:
        print(f"Error: {e}")
        return False


if __name__ == "__main__":
    # Example usage
    modify_num_parallel(
        r"/home/lex/Documents/git/gru-hardware-implementation-and-optimization/optimizedImplementation/top_level.sv",
        num_parallel=15,
        int_bits=15,
        frac_bits=15,
        d=15,
        h=15
    )
    modify_num_parallel(
        r"/home/lex/Documents/git/gru-hardware-implementation-and-optimization/optimizedImplementation/gru_cell_parallel.sv",
        num_parallel=15,
        int_bits=15,
        frac_bits=15,
        d=15,
        h=15
    )