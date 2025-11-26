import numpy as np

def sigmoid(x):
    """Sigmoid activation function"""
    return 1 / (1 + np.exp(-np.clip(x, -500, 500)))


def tanh(x):
    """Tanh activation function"""
    return np.tanh(np.clip(x, -500, 500))


def gru_forward(x, h_prev, W_ir, W_iz, W_in, W_hr, W_hz, W_hn,
                b_ir, b_iz, b_in, b_hr, b_hz, b_hn):
    r_t = sigmoid(W_ir @ x + b_ir + W_hr @ h_prev + b_hr)
    z_t = sigmoid(W_iz @ x + b_iz + W_hz @ h_prev + b_hz)
    n_t = tanh(W_in @ x + b_in + r_t * (W_hn @ h_prev + b_hn))
    h_new = (1 - z_t) * n_t + z_t * h_prev

    return h_new


def generate_gru_ground_truth(d=64, h=4, NUM_TEST_VECTORS=100):
    """
    Generate ground truth outputs for GRU testbench
    """

    # Load weights and biases
    with open('testbenchInputs/hd_weights.txt', 'r') as f:
        input_weights = [float(x) for x in f.read().split()]

    with open('testbenchInputs/hh_weights.txt', 'r') as f:
        recurrent_weights = [float(x) for x in f.read().split()]

    with open('testbenchInputs/bias_weights.txt', 'r') as f:
        bias_weights = [float(x) for x in f.read().split()]

    with open('testbenchInputs/input_data.txt', 'r') as f:
        input_data = [[float(x) for x in line.split()] for line in f]


    # Input Weights

    input_count = 0

    W_ir = []
    for _ in range(h):
        for _ in range(d):
            W_ir.append(input_weights[input_count % len(input_weights)])
            input_count += 1
    W_ir = np.reshape( W_ir, (h,d) )

    W_iz = []
    for _ in range(h):
        for _ in range(d):
            W_iz.append(input_weights[input_count % len(input_weights)])
            input_count += 1
    W_iz = np.reshape( W_iz, (h,d) )

    W_in = []
    for _ in range(h):
        for _ in range(d):
            W_in.append(input_weights[input_count % len(input_weights)])
            input_count += 1
    W_in = np.reshape( W_in, (h,d) )


    # Recurrent Weights

    recurrent_count = 0

    W_hr = []
    for _ in range(h):
        for _ in range(h):
            W_hr.append(recurrent_weights[recurrent_count % len(recurrent_weights)])
            recurrent_count += 1
    W_hr = np.reshape( W_hr, (h,h) )

    W_hz = []
    for _ in range(h):
        for _ in range(h):
            W_hz.append(recurrent_weights[recurrent_count % len(recurrent_weights)])
            recurrent_count += 1
    W_hz = np.reshape( W_hz, (h,h) )

    W_hn = []
    for _ in range(h):
        for _ in range(h):
            W_hn.append(recurrent_weights[recurrent_count % len(recurrent_weights)])
            recurrent_count += 1
    W_hn = np.reshape( W_hn, (h,h) )


    # Bias

    bias_count = 0

    b_ir = []
    for _ in range(h):
        b_ir.append(bias_weights[bias_count % len(bias_weights)])
        bias_count += 1
    b_ir = np.reshape( b_ir, (h,1) )

    b_iz = []
    for _ in range(h):
        b_iz.append(bias_weights[bias_count % len(bias_weights)])
        bias_count += 1
    b_iz = np.reshape( b_iz, (h,1) )

    b_in = []
    for _ in range(h):
        b_in.append(bias_weights[bias_count % len(bias_weights)])
        bias_count += 1
    b_in = np.reshape( b_in, (h,1) )

    b_hr = []
    for _ in range(h):
        b_hr.append(bias_weights[bias_count % len(bias_weights)])
        bias_count += 1
    b_hr = np.reshape( b_hr, (h,1) )

    b_hz = []
    for _ in range(h):
        b_hz.append(bias_weights[bias_count % len(bias_weights)])
        bias_count += 1
    b_hz = np.reshape( b_hz, (h,1) )

    b_hn = []
    for _ in range(h):
        b_hn.append(bias_weights[bias_count % len(bias_weights)])
        bias_count += 1
    b_hn = np.reshape( b_hn, (h,1) )

    # Generate outputs
    outputs = []

    for n in range(NUM_TEST_VECTORS):
        # Get input and previous hidden state

        x = []
        for i in range(d):
            x.append( input_data[ n % len(input_data) ][ i % len(input_data[n]) ] )
        x = np.reshape(x, (d, 1))

        h_prev = []
        for i in range(h):
            h_prev.append( input_data[ n % len(input_data) ][ i % len(input_data[n]) ] )
        h_prev = np.reshape(h_prev, (h, 1))


        # Compute new hidden state
        h_new = gru_forward(x, h_prev, W_ir, W_iz, W_in, W_hr, W_hz, W_hn,
                            b_ir, b_iz, b_in, b_hr, b_hz, b_hn)

        outputs.append(h_new)

    # Save ground truth
    output_filename = f'ground_truth_d{d}_h{h}.txt'
    with open(output_filename, 'w') as f:
        for output in outputs:
            f.write(' '.join([f'{val}'[1:-1] for val in output]) + '\n')

    print(f"Ground truth saved to {output_filename}")
    return outputs


if __name__ == "__main__":
    # Generate ground truth for d=3, h=2 (matching your example)
    outputs = generate_gru_ground_truth(d=3, h=7, NUM_TEST_VECTORS=100)

    # Print first few outputs
    print("\nFirst 5 outputs:")
    for i, output in enumerate(outputs[:5]):
        print(f"Vector {i}: {output}")