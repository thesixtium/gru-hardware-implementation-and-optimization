import numpy as np

d = 3
h = 2

with open('testbenchInputs/hd_weights.txt', 'r') as f:
    input_weights = [float(x) for x in f.read().split()]

hd = []
hd_count = 0
for _ in range(h):
    for _ in range(d):
        hd.append( input_weights[ hd_count % len(input_weights) ] )
        hd_count += 1

print(hd)
print()
print( np.reshape(hd, (h,d) ) )