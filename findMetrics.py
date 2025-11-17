import re
import numpy as np


def parse_q_format(binary_str, int_bits, frac_bits):
    """
    Parse a binary string in Q format (signed fixed-point).
    Q format: sign bit + integer bits + fractional bits
    Total bits = 1 (sign) + int_bits + frac_bits
    """
    binary_str = binary_str.strip()
    total_bits = len(binary_str)

    # Convert binary string to integer
    value = int(binary_str, 2)

    # Check if negative (MSB is 1)
    if binary_str[0] == '1':
        # Two's complement: subtract 2^total_bits
        value -= (1 << total_bits)

    # Convert to floating point by dividing by 2^frac_bits
    float_value = value / (2 ** frac_bits)

    return float_value


def extract_format_from_filename(filename):
    """Extract integer and fractional bits from filename like 'output_d4_h4_int4_frac8.txt'."""
    match = re.search(r'int(\d+)_frac(\d+)', filename)
    if match:
        int_bits = int(match.group(1))
        frac_bits = int(match.group(2))
        return int_bits, frac_bits
    else:
        raise ValueError(f"Could not extract int and frac bits from filename: {filename}")


def read_q_format_file(filename, int_bits, frac_bits):
    """Read a file containing Q-format binary numbers and convert to float array."""
    values = []

    with open(filename, 'r') as f:
        content = f.read()
        # Extract all binary numbers (sequences of 0s and 1s)
        binary_numbers = re.findall(r'[01]+', content)

        for binary_str in binary_numbers:
            if binary_str:  # Skip empty strings
                value = parse_q_format(binary_str, int_bits, frac_bits)
                values.append(value)

    return np.array(values)


def calculate_mae(array1, array2):
    """Calculate Mean Absolute Error between two arrays."""
    if len(array1) != len(array2):
        raise ValueError(f"Arrays must have same length. Got {len(array1)} and {len(array2)}")

    for i in range(len(array1)):
        #print(f"{array1[i]} - {array2[i]} = {array1[i] - array2[i]}")
        pass

    return np.mean(np.abs(array1 - array2))


# File list
filenames = [
    'output_d4_h4_int4_frac8.txt',
    'output_d4_h4_int4_frac9.txt',
    'output_d4_h4_int4_frac10.txt']

# Read all files and extract format from filename
data = {}
file_formats = {}

for filename in filenames:
    int_bits, frac_bits = extract_format_from_filename(filename)
    file_formats[filename] = (int_bits, frac_bits)

    print(f"Reading {filename} (Q{int_bits}.{frac_bits})...")
    data[filename] = read_q_format_file(filename, int_bits, frac_bits)
    print(f"  Loaded {len(data[filename])} values")
    print(f"  Range: [{np.min(data[filename]):.6f}, {np.max(data[filename]):.6f}]")
    print()

# Ground truth is the file with most fractional bits
ground_truth_file = max(file_formats.keys(), key=lambda k: file_formats[k][1])
ground_truth = data[ground_truth_file]
gt_int_bits, gt_frac_bits = file_formats[ground_truth_file]

print("=" * 60)
print("Mean Absolute Error (MAE) Comparison")
print("=" * 60)
print(f"Ground Truth: {ground_truth_file} (Q{gt_int_bits}.{gt_frac_bits})")
print()

# Calculate MAE for each file against ground truth
for filename in filenames:
    if filename == ground_truth_file:
        continue

    int_bits, frac_bits = file_formats[filename]
    mae = calculate_mae(data[filename], ground_truth)
    print(f"{filename} (Q{int_bits}.{frac_bits}):")
    print(f"  MAE: {mae:.8f}")
    print(f"  Max Error: {np.max(np.abs(data[filename] - ground_truth)):.8f}")
    print(f"  Min Error: {np.min(np.abs(data[filename] - ground_truth)):.8f}")
    print()