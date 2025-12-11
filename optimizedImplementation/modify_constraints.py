import re


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

        # Split content into lines for line-by-line processing
        lines = content.split('\n')
        modified = False

        new_lines = []
        for line in lines:
            # Check if this line contains create_clock
            if 'create_clock' in line and '-period' in line:
                original_line = line

                # Replace period value
                line = re.sub(r'-period\s+\d+\.?\d*', f'-period {new_period:.3f}', line)

                # Replace waveform values if present
                line = re.sub(
                    r'-waveform\s+\{\s*\d+\.?\d*\s+\d+\.?\d*\s*\}',
                    f'-waveform {{0.000 {half_period:.3f}}}',
                    line
                )

                if line != original_line:
                    modified = True
                    print(f"Modified line found:")
                    print(f"  OLD: {original_line.strip()}")
                    print(f"  NEW: {line.strip()}")

            new_lines.append(line)

        new_content = '\n'.join(new_lines)

        # Check if replacement was made
        if not modified:
            print(f"Warning: No create_clock statement found or modified in {xdc_file}")
            print("\nSearching for create_clock statements...")

            # Debug: show what we found
            matches = re.findall(r'.*create_clock.*', content)
            if matches:
                print("Found create_clock line(s):")
                for m in matches:
                    print(f"  {m}")
            else:
                print("No create_clock statements found in file")
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
        import traceback
        traceback.print_exc()
        return False