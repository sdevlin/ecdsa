from heapq import nsmallest, nlargest
from subprocess import Popen, PIPE


load('ecdsa.sage')


def loaddata(fname):
    data = []
    with open(fname, 'r') as f:
        for line in f.readlines():
            (h, c), A = eval(line)
            h, c = map(ZZ, [h, c])
            data.append((h, c))
    return data


def recover(data):
    C = 2^28
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


def main():
    from sys import argv

    fname = argv[1]
    data = loaddata(fname)
    print recover(data)


if __name__ == '__main__':
    main()
