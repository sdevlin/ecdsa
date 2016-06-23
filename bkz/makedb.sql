PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE trials (id integer primary key autoincrement not null, q string not null, x string not null, b integer not null, d integer not null, logW integer not null, seed integer not null, block_size integer not null);
CREATE TABLE points (id integer primary key autoincrement not null, trial_id integer not null references trials (id), kA integer not null, hA integer not null, cA integer not null, G1 integer not null, Ginf integer not null, C integer not null, logkA float not null, A string not null);
COMMIT;
