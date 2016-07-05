from argparse import ArgumentParser
from itertools import islice
from random import Random
from fft import FFT
from operator import xor
from subprocess import Popen, PIPE
load('../utils/timeutil.py')

import sqlite3

def bitdiff(a, b):
    t = xor(int(a), int(b))
    count = 0
    while t:
        t = t & (t-1)
        count += 1
    return count

def gendata(Fq, C, q, x, b, seed=None):
    rng = Random(seed)
    qb = round((q-1)/2^(b+1))
    while True:
        k = rng.randrange(q)
        cj = rng.randrange(C)
        kj = rng.randrange(-qb, qb + 1)
        hj = (kj - cj * x)
        yield (k, Fq(hj), Fq(cj))



@timeit
def compute_fft(our_fft):
    return our_fft.inversefft()

def runsim(q, x, b, C, L, seed, ncands, cursor):
    cursor = conn.cursor()
    cursor.execute('insert into trials (q, x, b, C, L, seed) values (?, ?, ?, ?, ?, ?)', (str(q), str(x), int(b), int(C), int(L), int(seed)))
    trial_id = cursor.lastrowid

    Fq = GF(q)
    x = Fq(x)
    bC = 2^C
    n = 2 * bC
    our_fft = FFT(n)

    data = list(islice(gendata(Fq, bC, q, x, b, seed), L))

    for (k, hj, cj) in data:
        bias = CC(e^(2*pi*I*int(hj) / q))
        our_fft.setitem(cj + bC, bias[0], bias[1])
    
    (_, elapsed_time) = compute_fft(our_fft)
    cursor.execute('update trials set time_elapsed = ? where id = ?', (float(elapsed_time), trial_id))

    candidates = our_fft.best_candidates(ncands)
    for (m, val) in reversed(candidates):
        print (m, val)
        if abs(m) > n:
            print "DOING IT ON THE OTHER SHIT"
            p = Popen(['./fft', str(n), str(len(data))], stdin=PIPE, stdout=PIPE)
            for (k, hj, cj) in data:
                bias = tuple(CC(e^(2*pi*I*int(hj) / q)))
                print >>p.stdin, cj + bC
                print >>p.stdin, bias
            for line in p.stdout.readlines():
                print (ZZ(line), ZZ(round(ZZ(line)*q/n)))

        meow = int(round(m * q / n))
        score = 1 - bitdiff(x, meow) / C
        cursor.execute('insert into points (trial_id, m, bias, score) values (?,?,?,?)', (trial_id, int(m), float(val), float(score)))

if __name__ == "__main__":
    parser = ArgumentParser(prog='sim.sage',
                            description='Simulate a FFT round.')

    parser.add_argument('-q', type=ZZ, required=True, help='the prime modulus')
    parser.add_argument('-x', type=ZZ, required=True, help='the secret key')
    parser.add_argument('-b', type=ZZ, required=True, help='the bias in each k')
    parser.add_argument('-C', type=ZZ, required=True, help='the exp of C (2^what), computing 2 * C sized FFT')
    parser.add_argument('-L', type=ZZ, required=True, help='the number of points to use in the calculation')
    parser.add_argument('--seed', type=ZZ, required=True, help='used to generate the secret key x and all (c, h, k) tuples')
    parser.add_argument('--ncands', type=int, required=False, default=5, help='number of resultant candidates to save')

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

















