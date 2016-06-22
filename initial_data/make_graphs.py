import matplotlib.pyplot as plt
import os

CUR_DIR = os.getcwd()
DATA_DIR= "%s/initial_data" % CUR_DIR
IMG_DIR = "%s/img" % CUR_DIR
if not os.path.isdir(IMG_DIR):
	os.makedirs(IMG_DIR)

for root, dirs, filenames in os.walk(DATA_DIR):
    for fname in filenames:
		if fname.startswith("points"): # file with points, not necessary here
			continue
		if "BKZ32" in fname: # too many points to graph...
			continue
		print fname
		f = open(os.path.join(root, fname), "r")
		data = []
		the_max = 0
		for line in f.readlines():
			cd = line.strip("").split(":")
			a,b = int(cd[0]), int(cd[1])
			if abs(a) > the_max:
				the_max = abs(a)
			data.append((int(cd[0]), int(cd[1])))
		f.close()

		bins = range(-the_max, the_max + 1)
		the_data = [0] * len(bins)
		for blah in data:
			the_data[blah[0] + the_max] = blah[1]

		plt.figure()
		fig, ax = plt.subplots()
		rects1 = ax.bar(bins, the_data)
		plt.savefig("%s/%s.png" % (IMG_DIR, fname))
