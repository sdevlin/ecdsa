import sqlite3
from itertools import islice
load('../ecdsa_utils.sage')

# computes the bias
def BQV(V):
    return abs(sum([CC(e^(2*pi*I*val / q)) for val in V]) / float(len(V)))

trial_id = 7
conn = sqlite3.connect("../bkz/bkz.db")
cursor = conn.cursor()
results = cursor.execute("select * from trials where id = ?", (int(trial_id),))
trial_data = results.fetchone()

q = ZZ(trial_data[1])
x = ZZ(trial_data[2])
b = int(trial_data[3])
d = int(trial_data[4])
logW = int(trial_data[5])
seed = int(trial_data[6])
block_size = int(trial_data[7])
elapsed_time = float(trial_data[8])

Fq = GF(q)
x = Fq(x)

data = list(islice(gendata(Fq, q, x, b, seed), d))

orig_bias = BQV([int(h + c * x) for (_,h,c) in data])

print "Original bias is: %f" % orig_bias

results = cursor.execute("select hA,cA from points where trial_id = ?", (int(trial_id),))
trial_data = results.fetchall()

# naively do this...
new_data = []
for item in trial_data:
	new_data.append((ZZ(item[0]), ZZ(item[1])))

new_bias = BQV([int(h + c * x) for (h,c) in new_data])
print "New bias is: %f" % new_bias



cursor.close()
conn.close()