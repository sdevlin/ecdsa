from argparse import ArgumentParser
from itertools import islice

import sqlite3


load('../ecdsa.sage')


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
W = 2^logW
seed = args.seed
block_size = args.block_size

conn = sqlite3.connect('bkz.db')
cursor = conn.cursor()

cursor.execute('insert into trials (q, x, b, d, logW, seed, block_size) values (?, ?, ?, ?, ?, ?, ?)', (str(q), str(x), int(b), int(d), int(logW), int(seed), int(block_size)))
trial_id = cursor.lastrowid


Fq = GF(q)
x = Fq(x)


def transpose(tups, type=list):
    '[[1,2],[3,4]] => [[1,3],[2,4]]'
    return map(type, zip(*tups))


data = list(islice(gendata(q, x, b, seed), d))
ks, hs, cs = transpose(data, vector)

B = matrix(ZZ, d+1)
for i in range(d):
    B[i,i] = W
    B[i,d] = cs[i]
B[d,d] = q

B = B.BKZ(block_size=block_size, algorithm='NTL', fp='fp', use_givens=True)


def center(k):
    k = lift(Fq(k))
    if k > q/2:
        k -= q
    return k


for v in B:
    A = v[:-1] / W
    cA = center(v[-1])
    hA = center(hs * A)
    kA = center(ks * A)
    cursor.execute('insert into points (trial_id, kA, hA, cA, G1, Ginf, C, logkA, A) values (?, ?, ?, ?, ?, ?, ?, ?, ?)', (trial_id, int(kA), int(hA), int(cA), int(A.norm(1)), int(A.norm(Infinity)), int(cA.nbits()), float(log(abs(kA), 2)), str(A)))
