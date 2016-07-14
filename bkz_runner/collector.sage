import sqlite3
import zmq
from argparse import ArgumentParser
from multiprocessing import Process, Queue
import time
import json

def ZeroMQListener(queue):
	context = zmq.Context()
	socket = context.socket(zmq.PULL)
	socket.connect("tcp://127.0.0.1:9880")
	while True:
		message = socket.recv_json()
		queue.put(message)

if __name__ == "__main__":
	parser = ArgumentParser(prog='collectorsage',
                            description='Does some bkz stuff')
	parser.add_argument('--db', type=str, required=False, default="/Users/alexb/Documents/Programming/crypto/ecdsa/bkz/bkz.db", help='The location of the db')
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
			cursor.execute('insert into trials (q, x, b, d, logW, seed, block_size, time_elapsed) values (?, ?, ?, ?, ?, ?, ?, ?)', (str(data['q']), str(data['x']), int(data['b']), int(data['d']), int(data['logW']), int(data['seed']), int(data['block_size']), float(data['elapsed_time'])))
			trial_id = cursor.lastrowid

			for item in data['points']:
				cursor.execute('insert into points (trial_id, kA, hA, cA, G1, Ginf, C, logkA, A) values (?, ?, ?, ?, ?, ?, ?, ?, ?)', (trial_id, str(item['kA']), str(item['hA']), str(item['cA']), int(item['G1']), int(item['Ginf']), int(item['C']), float(item['logkA']), str(item['A'])))
			conn.commit()
	except KeyboardInterrupt:
		print "Stopping..."
	except Exception as e:
		print "Exception"
		print e
	finally:
		print "And finished"
		conn.close()



