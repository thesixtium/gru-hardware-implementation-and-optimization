def float_to_fixed_point(value, INT_WIDTH, FRAC_WIDTH):
    """
    Convert a float to a signed fixed-point number.

    Parameters:
    -----------
    value : float
        The floating-point number to convert (can be positive or negative)
    INT_WIDTH : int
        Number of bits for the integer part (including sign bit)
    FRAC_WIDTH : int
        Number of bits for the fractional part

    Returns:
    --------
    int
        The fixed-point representation as a signed integer

    Raises:
    -------
    ValueError
        If the value is out of range for the given bit widths
    """
    # Total bit width
    TOTAL_WIDTH = INT_WIDTH + FRAC_WIDTH

    # Calculate the scaling factor (2^FRAC_WIDTH)
    scale = 2 ** FRAC_WIDTH

    # Calculate min and max representable values
    # For signed numbers: range is [-2^(TOTAL_WIDTH-1), 2^(TOTAL_WIDTH-1) - 1]
    min_value = -(2 ** (TOTAL_WIDTH - 1)) / scale
    max_value = (2 ** (TOTAL_WIDTH - 1) - 1) / scale

    # Check if value is in range
    if value < min_value or value > max_value:
        raise ValueError(
            f"Value {value} is out of range [{min_value}, {max_value}] "
            f"for Q{INT_WIDTH}.{FRAC_WIDTH} fixed-point format"
        )

    # Convert to fixed-point by scaling and rounding
    fixed_point = int(round(value * scale))

    # Handle two's complement representation for negative numbers
    if fixed_point < 0:
        # Convert to two's complement
        fixed_point = (1 << TOTAL_WIDTH) + fixed_point

    return format(fixed_point, f'0{TOTAL_WIDTH}b')
