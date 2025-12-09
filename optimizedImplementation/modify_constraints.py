import sys
import re
import os


def modify_clock_period(xdc_file, new_period):
    """
    Modify the clock period in an XDC file.

    Args:
        xdc_file: Path to the XDC constraints file
        new_period: New clock period in nanoseconds (float)
    """
    try:
        # Read the file
        with open(xdc_file, 'r') as f:
            content = f.read()

        # Calculate waveform values (half period for 50% duty cycle)
        half_period = new_period / 2.0

        # Pattern to match create_clock line with period and waveform
        # Matches: create_clock -period X.XXX -name ... -waveform {X.XXX X.XXX} [get_ports ...]
        pattern = r'(create_clock\s+-period\s+)\d+\.?\d*(\s+-name\s+\S+\s+-waveform\s+\{)\d+\.?\d*\s+\d+\.?\d*(\}\s+\[get_ports\s+\S+\])'

        # Replace with new period and waveform values
        replacement = rf'\g<1>{new_period:.3f}\g<2>0.000 {half_period:.3f}\g<3>'

        new_content = re.sub(pattern, replacement, content)

        # Check if replacement was made
        if new_content == content:
            # Try simpler pattern without waveform
            pattern_simple = r'(create_clock\s+-period\s+)\d+\.?\d*'
            new_content = re.sub(pattern_simple, rf'\g<1>{new_period:.3f}', content)

            if new_content == content:
                print(f"Warning: No create_clock statement found in {xdc_file}")
                return False

        # Create backup
        backup_file = xdc_file + '.backup'
        with open(backup_file, 'w') as f:
            f.write(content)
        print(f"Backup created: {backup_file}")

        # Write modified content
        with open(xdc_file, 'w') as f:
            f.write(new_content)

        # Calculate frequency
        freq_mhz = 1000.0 / new_period

        print(f"Successfully updated clock constraint:")
        print(f"  File: {xdc_file}")
        print(f"  New period: {new_period:.3f} ns")
        print(f"  Frequency: {freq_mhz:.3f} MHz")
        print(f"  Waveform: {{0.000 {half_period:.3f}}}")

        return True

    except FileNotFoundError:
        print(f"Error: File '{xdc_file}' not found")
        return False
    except Exception as e:
        print(f"Error: {e}")
        return False


def period_from_frequency(freq_mhz):
    """Convert frequency in MHz to period in nanoseconds."""
    return 1000.0 / freq_mhz

if __name__ == "__main__":
    modify_clock_period( r"C:\Users\ajrbe\Documents\School\Thesis\BCI\Code\constraints.xdc", 20 )