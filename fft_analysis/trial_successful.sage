# This file determines if a particular trial was successful or not.
from argparse import ArgumentParser
from operator import xor
import sqlite3
load("load_fft_data.sage")

def bitdiff(a,b):
    t = xor(a,b)
    count = 0
    while t:
            t = t & (t-1)
            count += 1
    return count

# Expects q, x, n, b, and data = list[(m1, b1), (m2, b2)....]
def trial_successful(q, x, N, n, b, data, threshold):
    the_val = int(round(data[0][0] * q / n))
    
    diffs = bitdiff(int(x), the_val)

    score = 1 - (diffs / float(N))
    return score > threshold


if __name__ == "__main__":
    parser = ArgumentParser(prog='trial_succesful.sage',
                            description='Determine if a FFT trial was successful')

    parser.add_argument('--trial_num', type=int, required=True, help='the trial number')
    parser.add_argument('--db', type=str, required=False, default="../fft/fft.db", help="the fft DB")
    parser.add_argument('--threshold', type=float, required=False, default=0.9, help="The threshold to judge by")
    parser.add_argument("-v", action="store_true", required=False, default=False)
    args = parser.parse_args()

    trial_num = args.trial_num
    db = args.db
    threshold = args.threshold
    v = args.v

    conn = sqlite3.connect(db)
    (q, x, b, C, L, seed, time_elapsed) = load_trial_data(trial_num, conn)
    n = 2^(C + 1)

    if v:
        print "Trial #%d\n\tq = %d\tL = %d\tb = %d" % (trial_num, q, L, b)

    data = load_candidate_data(trial_num, conn)
    
    result = trial_successful(q, x, C, n, b, data, threshold)

    if v:
        print "The trial was",
        if result:
            print "successful"
        else:
            print "NOT successful"

