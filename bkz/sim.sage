load('runbkz.sage')
from argparse import ArgumentParser
import sqlite3



if __name__ == "__main__":
    parser = ArgumentParser(prog='sim.sage',
                            description='Simulate a BKZ reduction.')

    parser.add_argument('-q', type=ZZ, required=True, help='the prime modulus')
    parser.add_argument('-x', type=ZZ, required=True, help='the secret key')
    parser.add_argument('-b', type=ZZ, required=True, help='the bias in each k')
    parser.add_argument('-d', type=ZZ, required=True, help='the lattice has dimension d+1')
    parser.add_argument('--logW', type=ZZ, required=True, help='W = 2^logW; used to balance the reduction')
    parser.add_argument('--seed', type=ZZ, required=True, help='used to generate the secret key x and all (c, h, k) tuples')
    parser.add_argument('--block-size', type=ZZ, required=True, help='block size for the reduction')

    args = parser.parse_args()

    q = args.q
    x = args.x
    b = args.b
    d = args.d
    logW = args.logW
    seed = args.seed
    block_size = args.block_size

    conn = sqlite3.connect("bkz.db")
    runbkz(q, x, b, d, logW, seed, block_size, conn)
    conn.commit()
    conn.close()


















