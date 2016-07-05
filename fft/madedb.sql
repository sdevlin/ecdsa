PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE trials (id integer primary key autoincrement not null, q text not null, x text not null, b integer not null, C integer not null, L integer not null, seed integer not null, time_elapsed float);
CREATE TABLE points (id integer primary key autoincrement not null, trial_id integer not null references trials (id), m integer not null, bias float not null);
COMMIT;
