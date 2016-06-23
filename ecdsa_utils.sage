from random import Random

def gendata(Fq, q, x, b, seed=None):
    rng = Random(seed)
    qb = round((q-1)/2^(b+1))
    while True:
        c = ZZ(rng.randrange(q))
        k = Fq(rng.randrange(q) >> b)
        h = ZZ(k - c*x) - qb
        k = ZZ(k) - qb
        yield (k, h, c)