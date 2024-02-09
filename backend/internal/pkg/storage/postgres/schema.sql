BEGIN;

/*
-- Drop all tables
DROP TABLE IF EXISTS gender, exercise_type, language, position, user_account, user_list, report, gym, user_account_gym, friends, user_settings, plan, split, exercise, exercise_split, workout, set, best_lifts CASCADE;

or

DROP SCHEMA IF EXISTS public CASCADE;
*/

CREATE SCHEMA IF NOT EXISTS public;

CREATE TABLE gender (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);
--Insert INTO "gender" ("id", "name") VALUES (1, 'male');
--Insert INTO "gender" ("id", "name") VALUES (2, 'female');
--Insert INTO "gender" ("id", "name") VALUES (3, 'diverse');


CREATE TABLE exercise_type (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);
--Insert INTO "exercise_type" ("id", "name") VALUES (1, 'reps');
--Insert INTO "exercise_type" ("id", "name") VALUES (2, 'duration');


CREATE TABLE language (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);
--Insert INTO "language" ("id", "name") VALUES (1, 'english');
--Insert INTO "language" ("id", "name") VALUES (2, 'german');


CREATE TABLE position (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);
--Insert INTO "position" ("id", "name") VALUES (1, 'first');
--Insert INTO "position" ("id", "name") VALUES (2, 'second');
--Insert INTO "position" ("id", "name") VALUES (3, 'third');


CREATE TABLE user_account (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    username VARCHAR(20) NOT NULL,
    name VARCHAR(20) NOT NULL,
    publicKey BYTEA NOT NULL,
    encryptedPrivateKey BYTEA NOT NULL,
    randomSaltOne BYTEA NOT NULL,
    randomSaltTwo BYTEA NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    level INTEGER NOT NULL,
    profile_picture BYTEA,
    bodyweight INTEGER,
    gender_id BIGINT REFERENCES gender(id)
);
--Insert INTO "user_account" ("id", "username", "name", "publicKey", "encryptedPrivateKey", "randomSaltOne", "randomSaltTwo", "level", "created_at", "profile_picture", "bodyweight", "gender_id") VALUES (1, 'dholzwarth', 'Daniel', 'publicKey', 'encryptedPrivateKey', 'randomSaltOne', 'randomSaltTwo', 1, now(), null, 110, 1);
--Insert INTO "user_account" ("id", "username", "name", "publicKey", "encryptedPrivateKey", "randomSaltOne", "randomSaltTwo", "level", "created_at", "profile_picture", "bodyweight", "gender_id") VALUES (2, 'mmustermann', 'Max', 'publicKey', 'encryptedPrivateKey', 'randomSaltOne', 'randomSaltTwo', 1, now(), null, 80, 1);


CREATE TABLE user_list (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    list_id INTEGER NOT NULL,
    creator_id BIGINT REFERENCES user_account(id) NOT NULL,
    member_id BIGINT REFERENCES user_account(id) NOT NULL
);
--Insert INTO "user_list" ("id", "list_id", "creator_id", "member_id") VALUES (1, 1, 1, 2);


CREATE TABLE report (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    reporter_id BIGINT REFERENCES user_account(id) NOT NULL,
    reported_id BIGINT REFERENCES user_account(id) NOT NULL,
    is_offensive_profile_picture BOOLEAN,
    is_offensive_name BOOLEAN,
    is_offensive_username BOOLEAN,
    is_other BOOLEAN   
);
--Insert INTO "report" ("id", "reporter_id", "reported_id", "is_offensive_profile_picture", "is_offensive_name", "is_offensive_username", "is_other") VALUES (1, 1, 2, 'false', 'true', 'false', 'false');


CREATE TABLE gym (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    location POINT NOT NULL
);
--Insert INTO "gym" ("id", "name", "location") VALUES (1, 'Energym Öhringen', POINT(40.7128, -74.0060));


CREATE TABLE user_account_gym (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    user_id BIGINT REFERENCES user_account(id) NOT NULL,
    gym_id BIGINT REFERENCES gym(id) NOT NULL
);
--Insert INTO "user_account_gym" ("id", "user_id", "gym_id") VALUES (1, 1, 1);
--Insert INTO "user_account_gym" ("id", "user_id", "gym_id") VALUES (2, 2, 1);


CREATE TABLE friends (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    requester_id BIGINT REFERENCES user_account(id) NOT NULL,
    requested_id BIGINT REFERENCES user_account(id) NOT NULL,
    is_accepted BOOLEAN NOT NULL
);
--Insert INTO "friends" ("id", "requester_id", "requested_id", "is_accepted")VALUES (1, 1, 2, 'false');


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
--Insert INTO "user_settings" ("id", "user_id", "fontsize", "is_darkmode", "language_id", "is_unlisted", "is_pull_from_everyone", "pull_user_list_id", "is_notify_everyone", "notify_user_list_id") 
VALUES (1, 1, 16, 'false', 1, 'false', 'true', null, 'true', null);
--Insert INTO "user_settings" ("id", "user_id", "fontsize", "is_darkmode", "language_id", "is_unlisted", "is_pull_from_everyone", "pull_user_list_id", "is_notify_everyone", "notify_user_list_id") 
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
--Insert INTO "plan" ("id", "user_id", "part_count", "name", "startdate", "is_weekly", "is_monday_blocked", "is_tuesday_blocked", "is_wednesday_blocked", "is_thursday_blocked", "is_friday_blocked", "is_saturday_blocked", "is_sunday_blocked") 
VALUES (1, 1, 3, 'Daniels Plan', now(), 'false', 'true', 'false', 'false', 'false', 'false', 'false', 'false');


CREATE TABLE split (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    plan_id BIGINT REFERENCES plan(id) NOT NULL,
    name VARCHAR(20) NOT NULL,
    order_in_plan INTEGER NOT NULL
);
--Insert INTO "split" ("id", "plan_id", "name", "order_in_plan") VALUES (1, 1, 'legs', 1);


CREATE TABLE exercise (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    creator_id BIGINT REFERENCES user_account(id),
    name VARCHAR(50) NOT NULL,
    type_id BIGINT REFERENCES exercise_type(id) NOT NULL
);
--Insert INTO "exercise" ("id", "creator_id", "name", "type_id") VALUES (1, 1, 'benchpress', 1);


CREATE TABLE exercise_split (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    split_id BIGINT REFERENCES split(id) NOT NULL,
    exercise_id BIGINT REFERENCES exercise(id) NOT NULL
);
--Insert INTO "exercise_split" ("id", "split_id", "exercise_id") VALUES (1, 1, 1);


CREATE TABLE workout (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    user_id BIGINT REFERENCES user_account(id) NOT NULL,
    plan_id BIGINT REFERENCES plan(id),
    split_id BIGINT REFERENCES split(id),
    starttime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    endtime TIMESTAMP,
    is_archived BOOLEAN NOT NULL
);
--Insert INTO "workout" ("id", "user_id", "plan_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, 1, null, null, now(), null, 'false');


CREATE TABLE set (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    workout_id BIGINT REFERENCES workout(id) NOT NULL,
    exercise_id BIGINT REFERENCES exercise(id) NOT NULL,
    order_number INTEGER NOT NULL,
    measurement VARCHAR(50) NOT NULL
);
--Insert INTO "set" ("id", "workout_id", "exercise_id", "order_number", "measurement") VALUES (1, 1, 1, 1, '8x120');


CREATE TABLE best_lifts (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    user_id BIGINT REFERENCES user_account(id) NOT NULL,
    set_id BIGINT REFERENCES set(id) NOT NULL,
    position_id BIGINT REFERENCES position(id) NOT NULL
);
--Insert INTO "best_lifts" ("id", "user_id", "set_id", "position_id") VALUES (1, 1, 1, 1);

COMMIT;