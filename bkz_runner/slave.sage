load('../bkz/runbkz.sage')
import zmq
from argparse import ArgumentParser
import json

if __name__ == "__main__":
	parser = ArgumentParser(prog='slave.sage',
                            description='Does some bkz stuff')
	args = parser.parse_args()

	context = zmq.Context()
	receiver = context.socket(zmq.REQ)
	receiver.connect("tcp://127.0.0.1:5599")

	collector = context.socket(zmq.PUSH)
	collector.connect("tcp://127.0.0.1:9880")

	trials = 1

	try:
		while True:
			receiver.send_string("READY!")
			work = receiver.recv_json()

			print "Received!"

			q = ZZ(work['q'])
			x = ZZ(work['x'])
			b = int(work['b'])
			d = int(work['d'])
			logW = int(work['logW'])
			block_size = int(work['block_size'])
			seed = int(work['seed'])

			data = runbkz_nocursor(q, x, b, d, logW, seed, block_size)
			print "Finished(%d)" % trials
			trials += 1
			collector.send_json(data)
	except KeyboardInterrupt:
		print "Stopping..."
	except Exception as e:
		print "Exception"
		print e
	finally:
		receiver.close()

