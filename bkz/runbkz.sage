from itertools import islice
load('../ecdsa_utils.sage')
load('../utils/timeutil.py')

def transpose(tups, type=list):
    '[[1,2],[3,4]] => [[1,3],[2,4]]'
    return map(type, zip(*tups))

def center(Fq, k):
    k = lift(Fq(k))
    if k > q/2:
        k -= q
    return k

@timeit
def compute_bkz(B, block_size, alg="NTL", fp='fp', use_givens=True):
    return B.BKZ(block_size=block_size, algorithm='NTL', fp='fp', use_givens=True)

def runbkz_nocursor(q, x, b, d, logW, seed, block_size):
    Fq = GF(q)
    x = Fq(x)
    W = 2^logW

    data = list(islice(gendata(Fq, q, x, b, seed), d))
    ks, hs, cs = transpose(data, vector)

    B = matrix(ZZ, d+1)
    for i in range(d):
        B[i,i] = W
        B[i,d] = cs[i]
    B[d,d] = q

    (B, elapsed_time) = compute_bkz(B, block_size = block_size)

    toret = {"q":str(q), "x":str(x), "b":int(b), "d":int(d), "logW":int(logW), "seed":int(seed), "block_size":int(block_size), "elapsed_time":float(elapsed_time)}
    toret["points"] = []
    for v in B:
        A = v[:-1] / W
        cA = v[-1]  #center(Fq, v[-1])
        hA = hs * A #center(Fq, hs * A)
        kA = ks * A #center(Fq, ks * A)

        toret["points"].append({"kA":str(kA), "hA":str(hA), "cA":str(cA), "G1":int(A.norm(1)), "Ginf": int(A.norm(Infinity)), "C":int(cA.nbits()), "logkA":float(log(abs(kA), 2)), "A":str(A)})
    return toret


def runbkz(q, x, b, d, logW, seed, block_size, conn):
    cursor = conn.cursor()
    cursor.execute('insert into trials (q, x, b, d, logW, seed, block_size) values (?, ?, ?, ?, ?, ?, ?)', (str(q), str(x), int(b), int(d), int(logW), int(seed), int(block_size)))
    trial_id = cursor.lastrowid

    Fq = GF(q)
    x = Fq(x)
    W = 2^logW

    data = list(islice(gendata(Fq, q, x, b, seed), d))
    ks, hs, cs = transpose(data, vector)

    B = matrix(ZZ, d+1)
    for i in range(d):
        B[i,i] = W
        B[i,d] = cs[i]
    B[d,d] = q

    #B = B.BKZ(block_size=block_size, algorithm='NTL', fp='fp', use_givens=True)
    (B, elapsed_time) = compute_bkz(B, block_size = block_size)
    cursor.execute('update trials set time_elapsed = ? where id = ?', (float(elapsed_time), trial_id))

    for v in B:
        A = v[:-1] / W
        cA = v[-1]  #center(Fq, v[-1])
        hA = hs * A #center(Fq, hs * A)
        kA = ks * A #center(Fq, ks * A)
        cursor.execute('insert into points (trial_id, kA, hA, cA, G1, Ginf, C, logkA, A) values (?, ?, ?, ?, ?, ?, ?, ?, ?)', (trial_id, str(kA), str(hA), str(cA), int(A.norm(1)), int(A.norm(Infinity)), int(cA.nbits()), float(log(abs(kA), 2)), str(A)))