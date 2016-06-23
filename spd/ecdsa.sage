from binascii import hexlify
from hashlib import sha384
from os import urandom
from random import Random
from subprocess import check_output


p = 21659270770119316173069236842332604979796116387017648600081618503821089934025961822236561982844534088440708417973331
Fp = GF(p)

a = 19048979039598244295279281525021548448223459855185222892089532512446337024935426033638342846977861914875721218402342
b = 717131854892629093329172042053689661426642816397448020844407951239049616491589607702456460799758882466071646850065

E = EllipticCurve(Fp, [a, b])
G = E(4480579927441533893329522230328287337018133311029754539518372936441756157459087304048546502931308754738349656551198,
      21354446258743982691371413536748675410974765754620216137225614281636810686961198361153695003859088327367976229294869)

q = 21659270770119316173069236842332604979796116387017648600075645274821611501358515537962695117368903252229601718723941
Fq = GF(q)


assert G*q == E(0)


def genkey(b=0):
    k = int(Fq.random_element())
    mask = 2^b - 1
    k -= k & mask
    return ZZ(k)


def genkeypair():
    d = genkey()
    Q = d*G
    return d, Q


def sign(d, m, k=None):
    if k is None:
        k = genkey()
    u, v = (k*G).xy()
    r = Fq(u)
    s = Fq((m + r*d) / k)
    return lift(r), lift(s)


def verify(Q, m, sig):
    r, s = map(Fq, sig)
    w = s^-1
    u1 = lift(m * w)
    u2 = lift(r * w)
    x = Fq((u1*G + u2*Q)[0])
    return r == x


def gendatum(d, b=0):
    m = lift(Fq.random_element())
    k = genkey(b)
    r, s = sign(d, m, k)
    h = lift(Fq(2^-b * s^-1 * m) - round(q / 2^(b+1)))
    c = lift(Fq(2^-b * s^-1 * r))
    return m, k, r, s, h, c


def bias(b):
    return float(sin(pi * 2^-b) / (pi * 2^-b))
