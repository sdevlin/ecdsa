load('ecdsa.sage')


def harvest(data):
    d = len(data)
    hj = vector([datum[2][0] for datum in data])
    cj = vector([datum[2][1] for datum in data])
    C, G1, Ginf = 2^28, 325, 8
    W = C / 2^3
    B = Matrix(ZZ, d+1)
    for i in range(d):
        B[i,i] = W
        B[i,d] = cj[i]
    B[d,d] = q
    B = B.BKZ(block_size=20, algorithm='NTL', fp='fp', use_givens=True)
    acc = []
    for b in B:
        Aj = b[:-1] / W
        cAj = b[-1]
        assert Fq(cAj) == Fq(Aj * cj)
        if abs(cAj) < C and Aj.norm(1) <= G1 and Aj.norm(Infinity) <= Ginf:
            acc.append(((Fq(Aj * hj), Fq(cAj)), Aj))
    return acc


@parallel
def pharvest(*args, **kwargs):
    return harvest(*args, **kwargs)


def loaddata(fname):
    data = []
    with open(fname, 'r') as f:
        for line in f.readlines():
            m, k, r, s, h, c = map(ZZ, eval(line))
            data.append(((m, k), (r, s), (h, c)))
    return data


def main():
    from sys import argv

    fname = argv[1]
    data = loaddata(fname)

    k = int(argv[2])
    d = 128

    for _, vs in pharvest([sample(data, 128) for _ in range(k)]):
        for v in vs:
            print v


if __name__ == '__main__':
    main()
