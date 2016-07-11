load('../fft/runfft.sage')
import zmq
from argparse import ArgumentParser
import json

if __name__ == "__main__":
	parser = ArgumentParser(prog='slave.sage',
                            description='Does some fft stuff')
	parser.add_argument('--db', type=str, required=False, default="../fft/fft.db", help='The location of the db')
	args = parser.parse_args()
	db = args.db

	context = zmq.Context()
	receiver = context.socket(zmq.REQ)
	receiver.connect("tcp://127.0.0.1:5550")

	collector = context.socket(zmq.PUSH)
	collector.bind("tcp://127.0.0.1:9800")

	try:
		while True:
			receiver.send_string("READY!")
			work = receiver.recv_json()
			q = ZZ(work['q'])
			x = ZZ(work['x'])
			b = int(work['b'])
			C = int(work['C'])
			L = int(work['L'])
			ncands = int(work['ncands'])
			seed = int(work['seed'])

			data = runsim_nocursor(q, x, b, C, L, seed, ncands)
			collector.send_json(data)
	except KeyboardInterrupt:
		print "Stopping..."
	except Exception as e:
		print "Exception"
		print e
	finally:
		receiver.close()

