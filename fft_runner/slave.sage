load('../fft/runfft.sage')
import sqlite3
import zmq
from argparse import ArgumentParser

if __name__ == "__main__":
	parser = ArgumentParser(prog='slave.sage',
                            description='Does some fft stuff')
	parser.add_argument('--db', type=str, required=False, default="../fft/fft.db", help='The location of the db')
	args = parser.parse_args()
	db = args.db

	conn = sqlite3.connect(db)

	context = zmq.Context()
	receiver = context.socket(zmq.PULL)
	receiver.connect("tcp://127.0.0.1:5557")

	try:
		while True:
			work = receiver.recv_json()
			q = ZZ(work['q'])
			x = ZZ(work['x'])
			b = int(work['b'])
			C = int(work['C'])
			L = int(work['L'])
			ncands = int(work['ncands'])
			seed = int(work['seed'])

			runsim(q, x, b, C, L, seed, ncands, conn)
			conn.commit()
	except KeyboardInterrupt:
		print "Stopping..."
	except Exception as e:
		print "Exception"
		print e
	finally:
		conn.close()
		receiver.close()

