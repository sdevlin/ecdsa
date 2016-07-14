from argparse import ArgumentParser
import zmq
import random


if __name__ == "__main__":
    parser = ArgumentParser(prog='master.sage',
                            description='Simulate a BKZ reduction.')

    parser.add_argument('-q', type=ZZ, required=True, help='the prime modulus')
    parser.add_argument('-x', type=ZZ, required=True, help='the secret key')
    parser.add_argument('-b', type=ZZ, required=True, help='the bias in each k')
    parser.add_argument('-d', type=ZZ, required=True, help='the lattice has dimension d+1')
    parser.add_argument('--logW', type=ZZ, required=True, help='W = 2^logW; used to balance the reduction')
    parser.add_argument('--block-size', type=ZZ, required=True, help='block size for the reduction')

    args = parser.parse_args()

    q = args.q
    x = args.x
    b = args.b
    d = args.d
    logW = args.logW
    block_size = args.block_size

    context = zmq.Context()
    zmq_socket = context.socket(zmq.REP)
    zmq_socket.bind("tcp://127.0.0.1:5599")

    try:
        while True:
            got = zmq_socket.recv_string()
            seed = random.randint(0, 1<<32)
            job = {"q": str(q), "x": str(x), "b": str(b), "d": str(d), "logW": str(logW), "block_size": str(block_size), "seed": seed}
            zmq_socket.send_json(job)
    except KeyboardInterrupt:
        print "Stopping..."
    except Exception as e:
        print "Exception"
        print e
    finally:
        zmq_socket.close()

