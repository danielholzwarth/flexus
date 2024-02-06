BEGIN;

-- Drop all tables

/*
DROP TABLE IF EXISTS user_account, lobby, file, owner CASCADE;

or

DROP SCHEMA IF EXISTS public CASCADE;
*/

CREATE SCHEMA IF NOT EXISTS public;

CREATE TABLE gender (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);
INSERT INTO "gender" ("id", "name") VALUES (1, 'male');
INSERT INTO "gender" ("id", "name") VALUES (2, 'female');
INSERT INTO "gender" ("id", "name") VALUES (3, 'diverse');


CREATE TABLE exercise_type (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);
INSERT INTO "exercise_type" ("id", "name") VALUES (1, 'reps');
INSERT INTO "exercise_type" ("id", "name") VALUES (2, 'duration');


CREATE TABLE language (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);
INSERT INTO "language" ("id", "name") VALUES (1, 'english');
INSERT INTO "language" ("id", "name") VALUES (2, 'german');


CREATE TABLE position (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);
INSERT INTO "position" ("id", "name") VALUES (1, 'first');
INSERT INTO "position" ("id", "name") VALUES (2, 'second');
INSERT INTO "position" ("id", "name") VALUES (3, 'third');


CREATE TABLE user_account (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    username VARCHAR(20) NOT NULL,
    name VARCHAR(20) NOT NULL,
    password bytea NOT NULL,
    level INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    profile_picture bytea,
    bodyweight INTEGER,
    gender_id BIGINT REFERENCES gender(id)
);
INSERT INTO "user_account" ("id", "username", "name", "password", "level", "created_at", "profile_picture", "bodyweight", "gender_id") VALUES (1, 'dholzwarth', 'Daniel', 'DEFAULT', 1, now(), null, 110, 1);
INSERT INTO "user_account" ("id", "username", "name", "password", "level", "created_at", "profile_picture", "bodyweight", "gender_id") VALUES (2, 'mmustermann', 'Max', 'DEFAULT', 1, now(), null, 80, 1);


CREATE TABLE user_list (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    list_id INTEGER NOT NULL,
    creator_id BIGINT REFERENCES user_account(id) NOT NULL,
    member_id BIGINT REFERENCES user_account(id) NOT NULL
);
INSERT INTO "user_list" ("id", "list_id", "creator_id", "member_id") VALUES (1, 1, 1, 2);


CREATE TABLE report (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    reporter_id BIGINT REFERENCES user_account(id) NOT NULL,
    reported_id BIGINT REFERENCES user_account(id) NOT NULL,
    is_offensive_profile_picture BOOLEAN,
    is_offensive_name BOOLEAN,
    is_offensive_username BOOLEAN,
    is_other BOOLEAN   
);
INSERT INTO "report" ("id", "reporter_id", "reported_id", "is_offensive_profile_picture", "is_offensive_name", "is_offensive_username", "is_other") VALUES (1, 1, 2, 'false', 'true', 'false', 'false');


CREATE TABLE gym (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    location POINT NOT NULL
);
INSERT INTO "gym" ("id", "name", "location") VALUES (1, 'Energym Öhringen', POINT(40.7128, -74.0060));


CREATE TABLE user_account_gym (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    user_id BIGINT REFERENCES user_account(id) NOT NULL,
    gym_id BIGINT REFERENCES gym(id) NOT NULL
);
INSERT INTO "user_account_gym" ("id", "user_id", "gym_id") VALUES (1, 1, 1);
INSERT INTO "user_account_gym" ("id", "user_id", "gym_id") VALUES (2, 2, 1);


CREATE TABLE friends (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    requester_id BIGINT REFERENCES user_account(id) NOT NULL,
    requested_id BIGINT REFERENCES user_account(id) NOT NULL,
    is_accepted BOOLEAN NOT NULL
);
INSERT INTO "friends" ("id", "requester_id", "requested_id", "is_accepted")VALUES (1, 1, 2, 'false');


CREATE TABLE user_settings (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    user_id BIGINT REFERENCES user_account(id) NOT NULL,
    fontsize INTEGER NOT NULL,
    is_darkmode BOOLEAN NOT NULL,
    language_id BIGINT REFERENCES language(id) NOT NULL,
    is_unlisted BOOLEAN NOT NULL,
    is_pull_from_everyone BOOLEAN NOT NULL,
    pull_user_list_id BIGINT REFERENCES user_list(id),
    is_notify_everyone BOOLEAN NOT NULL,
    notify_user_list_id BIGINT REFERENCES user_list(id)
);
INSERT INTO "user_settings" ("id", "user_id", "fontsize", "is_darkmode", "language_id", "is_unlisted", "is_pull_from_everyone", "pull_user_list_id", "is_notify_everyone", "notify_user_list_id") 
VALUES (1, 1, 16, 'false', 1, 'false', 'true', null, 'true', null);
INSERT INTO "user_settings" ("id", "user_id", "fontsize", "is_darkmode", "language_id", "is_unlisted", "is_pull_from_everyone", "pull_user_list_id", "is_notify_everyone", "notify_user_list_id") 
VALUES (2, 2, 22, 'false', 2, 'true', 'false', 1, 'true', null);


CREATE TABLE plan (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    user_id BIGINT REFERENCES user_account(id) NOT NULL,
    part_count INTEGER NOT NULL,
    name VARCHAR(20) NOT NULL,
    startdate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_weekly BOOLEAN NOT NULL,
    is_monday_blocked BOOLEAN NOT NULL,
    is_tuesday_blocked BOOLEAN NOT NULL,
    is_wednesday_blocked BOOLEAN NOT NULL,
    is_thursday_blocked BOOLEAN NOT NULL,
    is_friday_blocked BOOLEAN NOT NULL,
    is_saturday_blocked BOOLEAN NOT NULL,
    is_sunday_blocked BOOLEAN NOT NULL
);
INSERT INTO "plan" ("id", "user_id", "part_count", "name", "startdate", "is_weekly", "is_monday_blocked", "is_tuesday_blocked", "is_wednesday_blocked", "is_thursday_blocked", "is_friday_blocked", "is_saturday_blocked", "is_sunday_blocked") 
VALUES (1, 1, 3, 'Daniels Plan', now(), 'false', 'true', 'false', 'false', 'false', 'false', 'false', 'false');


CREATE TABLE split (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    plan_id BIGINT REFERENCES plan(id) NOT NULL,
    name VARCHAR(20) NOT NULL,
    order_in_plan INTEGER NOT NULL
);
INSERT INTO "split" ("id", "plan_id", "name", "order_in_plan") VALUES (1, 1, 'legs', 1);


CREATE TABLE exercise (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    creator_id BIGINT REFERENCES user_account(id),
    name VARCHAR(50) NOT NULL,
    type_id BIGINT REFERENCES exercise_type(id) NOT NULL
);
INSERT INTO "exercise" ("id", "creator_id", "name", "type_id") VALUES (1, 1, 'benchpress', 1);


CREATE TABLE exercise_split (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    split_id BIGINT REFERENCES split(id) NOT NULL,
    exercise_id BIGINT REFERENCES exercise(id) NOT NULL
);
INSERT INTO "exercise_split" ("id", "split_id", "exercise_id") VALUES (1, 1, 1);


CREATE TABLE workout (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    user_id BIGINT REFERENCES user_account(id) NOT NULL,
    plan_id BIGINT REFERENCES plan(id),
    split_id BIGINT REFERENCES split(id),
    starttime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    endtime TIMESTAMP,
    is_archived BOOLEAN NOT NULL
);
INSERT INTO "workout" ("id", "user_id", "plan_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, 1, null, null, now(), null, 'false');


CREATE TABLE set (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    workout_id BIGINT REFERENCES workout(id) NOT NULL,
    exercise_id BIGINT REFERENCES exercise(id) NOT NULL,
    order_number INTEGER NOT NULL,
    measurement VARCHAR(50) NOT NULL
);
INSERT INTO "set" ("id", "workout_id", "exercise_id", "order_number", "measurement") VALUES (1, 1, 1, 1, '8x120');


CREATE TABLE best_lifts (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    user_id BIGINT REFERENCES user_account(id) NOT NULL,
    set_id BIGINT REFERENCES set(id) NOT NULL,
    position_id BIGINT REFERENCES position(id) NOT NULL
);
INSERT INTO "best_lifts" ("id", "user_id", "set_id", "position_id") VALUES (1, 1, 1, 1);

COMMIT;