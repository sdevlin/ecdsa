import time

def timeit(f):
	def fw(*args, **kwargs):
		t1 = time.time()
		return (f(*args, **kwargs), time.time() - t1)
	return fw
