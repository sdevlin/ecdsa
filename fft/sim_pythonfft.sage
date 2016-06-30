from itertools import islice
from subprocess import Popen, PIPE
from random import Random
from fft import FFT


load('../ecdsa.sage')

####
# blah = FFT(size)
# blah.set(pos, real, imag)
# blah.inversefft()
# blah.best_candidates(n=10)
####


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
    dofft(data, n)

    return


def dofft(data, n):
    python_fft = FFT(n)

    print "Starting fft.c"
    p = Popen(['./fft', str(n), str(len(data))], stdin=PIPE, stdout=PIPE)
    for h, c in data:
        the_tuple = tuple(CC(e^(2*pi*I*h/q)))
        print >>p.stdin, c
        print >>p.stdin, the_tuple
        python_fft.setitem(c, the_tuple[0], the_tuple[1])
    print "Finished fft.c"

    print "Starting fft.python"
    python_fft.inversefft()
    print "Finished fft.python"

    print "fft.c results"
    for line in p.stdout.readlines():
        print (ZZ(line), ZZ(round(ZZ(line)*q/n)))

    print "fft.python results"
    for (the_index, the_value) in python_fft.best_candidates(10):
        print (the_index, ZZ(round(ZZ(the_index)*q/n)))


x = 3848019252674873111557962765415730003230256936899687699625784298202064411596206096687967007562036777987107623550924
C = 2^25
b = 1

data = list(islice(gendata2(x, C, b), 500))
recover(data, C)
