from argparse import ArgumentParser
import zmq
import random
from  multiprocessing import Process

def pusher_man(port, q, x, b, C, Lmax, ncands):
    context = zmq.Context()
    zmq_socket = context.socket(zmq.PUSH)
    zmq_socket.bind("tcp://127.0.0.1:5557")
    try:
        while True:
            seed = random.randint(0, 1<<32)
            job = {"q": str(q), "x": str(x), "b": str(b), "C": str(C), "L": str(L), "ncands": str(ncands), "seed": seed}
            zmq_socket.send_json(job)
            L += 10
            if L > Lmax:
                L = 10
    except KeyboardInterrupt:
        print "Stopping..."
    except Exception as e:
        print "Exception"
        print e
    finally:
        zmq_socket.close()


if __name__ == "__main__":
    parser = ArgumentParser(prog='master.sage',
                            description='Gives the slaves some things to do. Right now it just iterates over L')

    parser.add_argument('-q', type=ZZ, required=True, help='the prime modulus')
    parser.add_argument('-x', type=ZZ, required=True, help='the secret key')
    parser.add_argument('-b', type=ZZ, required=True, help='the bias in each k')
    parser.add_argument('-C', type=ZZ, required=True, help='the exp of C (2^what), computing 2 * C sized FFT')
    parser.add_argument('-Lmax', type=ZZ, required=True, help='the number of points to use in the calculation')
    parser.add_argument('--ncands', type=int, required=False, default=5, help='number of resultant candidates to save')

    args = parser.parse_args()

    q = args.q
    x = args.x
    b = args.b
    C = args.C
    Lmax = args.Lmax
    ncands = args.ncands
    L = 4000

    context = zmq.Context()
    zmq_socket = context.socket(zmq.REP)
    zmq_socket.bind("tcp://127.0.0.1:5550")
    try:
        while True:
            got = zmq_socket.recv_string()
            seed = random.randint(0, 1<<32)
            job = {"q": str(q), "x": str(x), "b": str(b), "C": str(C), "L": str(L), "ncands": str(ncands), "seed": seed}
            zmq_socket.send_json(job)
            L += 10
            if L > Lmax:
                L = 10
    except KeyboardInterrupt:
        print "Stopping..."
    except Exception as e:
        print "Exception"
        print e
    finally:
        zmq_socket.close()

   






