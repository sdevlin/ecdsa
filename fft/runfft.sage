from itertools import islice
from random import Random
from fft import FFT
from operator import xor
from subprocess import Popen, PIPE
load('../utils/timeutil.py')

def bitdiff(a, b):
    return sum([0 if x == y else 1 for (x,y) in zip(a,b)])

def normalize_it(x, C):
    blah = ZZ(x)
    the_bits = blah.bits()[-C:][::-1]
    the_bits.extend([0] * (C - len(the_bits)))
    return the_bits

def scoreit(x, guess, C):
    x_normalized = normalize_it(x, C)
    guess_normalized = normalize_it(guess, C)
    return 1 - bitdiff(x_normalized ,guess_normalized) / float(C)

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
        meow = int(round(m * q / n))
        score = scoreit(x, meow, C) #1 - bitdiff(x, meow) / C
        cursor.execute('insert into points (trial_id, m, bias, score) values (?,?,?,?)', (trial_id, int(m), float(val), float(score)))