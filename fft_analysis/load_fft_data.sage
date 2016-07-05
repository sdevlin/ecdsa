# Expects an open connection the DB and the trial number
# Fetches the data for a single trial
def load_trial_data(trial_num, conn):
	cursor = conn.cursor()
	results = cursor.execute("select * from trials where id = ?", (trial_num,))	
	try:
		(_, q, x, b, C, L, seed, time_elapsed) = results.fetchone()
	except:
		raise Exception("UhOh - Couldn't find the trial with that id ! - FIXME")
	finally:
		cursor.close()

	return (ZZ(q), ZZ(x), b, C, L, seed, time_elapsed)

def load_candidate_data(trial_num, conn):
	cursor = conn.cursor()
	results = cursor.execute("select * from points where trial_id = ?", (trial_num,))
	toret = None

	try:
		toret = [(m,v) for (_,_,m,v) in results.fetchall()]
	except:
		raise Exception("UhOh - Couldn't find the trial with that id ! - FIXME")
	finally:
		cursor.close()
	return toret