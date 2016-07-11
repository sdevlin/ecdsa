from argparse import ArgumentParser
load('runfft.sage')

import sqlite3



if __name__ == "__main__":
    parser = ArgumentParser(prog='sim.sage',
                            description='Simulate a FFT round.')

    parser.add_argument('-q', type=ZZ, required=True, help='the prime modulus')
    parser.add_argument('-x', type=ZZ, required=True, help='the secret key')
    parser.add_argument('-b', type=ZZ, required=True, help='the bias in each k')
    parser.add_argument('-C', type=ZZ, required=True, help='the exp of C (2^what), computing 2 * C sized FFT')
    parser.add_argument('-L', type=ZZ, required=True, help='the number of points to use in the calculation')
    parser.add_argument('--seed', type=ZZ, required=True, help='used to generate the secret key x and all (c, h, k) tuples')
    parser.add_argument('--ncands', type=int, required=False, default=10, help='number of resultant candidates to save')

    args = parser.parse_args()

    q = args.q
    x = args.x
    b = args.b
    C = args.C
    L = args.L
    seed = args.seed
    ncands = args.ncands

    conn = sqlite3.connect("fft.db")
    runsim(q, x, b, C, L, seed, ncands, conn)
    conn.commit()
    conn.close()

















