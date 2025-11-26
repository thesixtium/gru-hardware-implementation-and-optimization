def float_to_fixed_point(number, intBits, decBits):
    totalBits = intBits + decBits

    # Scale the number by 2^decBits to convert to integer representation
    scaled = int(round(number * (2 ** decBits)))

    # Handle two's complement for negative numbers
    if scaled < 0:
        # Convert to two's complement representation
        scaled = (1 << totalBits) + scaled

    # Convert to binary and pad with zeros
    binary = bin(scaled)[2:].zfill(totalBits)

    # Return only the required number of bits (handle overflow)
    return binary[-totalBits:]


def fixed_point_to_float(binary_string, intBits, decBits):
    totalBits = intBits + decBits

    # Convert binary string to integer
    value = int(binary_string, 2)

    # Check if the number is negative (MSB is 1 in two's complement)
    if binary_string[0] == '1':
        # Convert from two's complement
        value = value - (1 << totalBits)

    # Scale back by dividing by 2^decBits
    return value / (2 ** decBits)


def add_binary_strings(bin1, bin2):
    # Ensure both strings are the same length
    max_len = max(len(bin1), len(bin2))
    bin1 = bin1.zfill(max_len)
    bin2 = bin2.zfill(max_len)

    # Convert to integers, add, then convert back to binary
    val1 = int(bin1, 2)
    val2 = int(bin2, 2)
    result = val1 + val2

    # Convert result to binary and maintain the same bit width (wrap around on overflow)
    binary_result = bin(result & ((1 << max_len) - 1))[2:].zfill(max_len)

    return binary_result

if __name__ == "__main__":
    a = float_to_fixed_point( -1.5, 8, 4 )
    b = float_to_fixed_point( -2.5, 8, 4 )
    print( add_binary_strings(a,b) )
    print( fixed_point_to_float( add_binary_strings(a,b), 4, 4 ) )