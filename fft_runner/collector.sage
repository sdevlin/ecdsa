import sqlite3
import zmq
from argparse import ArgumentParser
from multiprocessing import Process, Queue
import time
import json

def ZeroMQListener(queue):
	context = zmq.Context()
	socket = context.socket(zmq.PULL)
	socket.connect("tcp://127.0.0.1:9800")
	while True:
		message = socket.recv_json()
		queue.put(message)

if __name__ == "__main__":
	parser = ArgumentParser(prog='slave.sage',
                            description='Does some fft stuff')
	parser.add_argument('--db', type=str, required=False, default="/Users/alexb/Documents/Programming/crypto/ecdsa/fft/fft.db", help='The location of the db')
	parser.add_argument('--qsize', type=int ,required=False, default=10, help='Size of ther internal queue size')
	args = parser.parse_args()
	db = args.db
	qsize = args.qsize

	queue = Queue(qsize)

	p_ZeroMQListener = Process(target=ZeroMQListener, args=(queue,))
	p_ZeroMQListener.daemon = True

	
	try:
		p_ZeroMQListener.start()
		conn = sqlite3.connect(db)
		cursor = conn.cursor()
		
		conn.commit()
		while True:
			data = queue.get()
			cursor.execute('insert into trials (q, x, b, C, L, seed, time_elapsed) values (?, ?, ?, ?, ?, ?, ?)', (str(data['q']), str(data['x']), int(data['b']), int(data['C']), int(data['L']), int(data['seed']), float(data['time_elapsed'])))

			trial_id = cursor.lastrowid

			for item in data['points']:
				cursor.execute('insert into points (trial_id, m, bias, score) values (?,?,?,?)', (trial_id, int(item['m']), float(item['bias']), float(item['score'])))
			conn.commit()
	except KeyboardInterrupt:
		print "Stopping..."
	except Exception as e:
		print "Exception"
		print e
	finally:
		print "And finished"
		conn.close()



