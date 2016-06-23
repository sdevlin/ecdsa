from itertools import islice
from subprocess import Popen, PIPE
from random import Random


load('../ecdsa.sage')


def gendata(x, C, b, seed=None):
    rng = Random(seed)
    while True:
        c = ZZ(rng.randrange(2*C)) - C
        k = Fq(rng.randrange(q) >> b)
        h = ZZ(k - c*x) - round((q-1)/2^(b+1))
        k = ZZ(k) - round((q-1)/2^(b+1))
        yield (h, c)


def recover(data, C):
    n = 2*C

    for i, (h, c) in enumerate(data):
        data[i] = (h, c % n)

    fft(data, n)

    return


def fft(data, n):
    p = Popen(['./fft', str(n), str(len(data))], stdin=PIPE, stdout=PIPE)
    for h, c in data:
        print >>p.stdin, c
        print >>p.stdin, tuple(CC(e^(2*pi*I*h/q)))

    for line in p.stdout.readlines():
        print ZZ(round(ZZ(line)*q/n))


x = 3848019252674873111557962765415730003230256936899687699625784298202064411596206096687967007562036777987107623550924
C = 2^25
b = 1

data = list(islice(gendata(x, C, b), 500))
recover(data, C)
