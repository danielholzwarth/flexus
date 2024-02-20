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
Insert INTO "gender" ("name") VALUES ('male');
Insert INTO "gender" ("name") VALUES ('female');
Insert INTO "gender" ("name") VALUES ('diverse');


CREATE TABLE exercise_type (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);
Insert INTO "exercise_type" ("name") VALUES ('reps');
Insert INTO "exercise_type" ("name") VALUES ('duration');


CREATE TABLE language (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);
Insert INTO "language" ("name") VALUES ('english');
Insert INTO "language" ("name") VALUES ('german');


CREATE TABLE position (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);
Insert INTO "position" ("name") VALUES ('first');
Insert INTO "position" ("name") VALUES ('second');
Insert INTO "position" ("name") VALUES ('third');


CREATE TABLE user_account (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    username VARCHAR(20) NOT NULL,
    name VARCHAR(20) NOT NULL,
    password VARCHAR NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    level INTEGER NOT NULL,
    profile_picture BYTEA,
    bodyweight INTEGER,
    gender_id BIGINT REFERENCES gender(id) ON DELETE SET NULL ON UPDATE CASCADE
);
Insert INTO "user_account" ("username", "name", "password", "created_at", "level", "profile_picture", "bodyweight", "gender_id") 
VALUES ('dholzwarth', 'BigD', '$2a$10$98nFaNeDYZ/eWHxQcY9GqOXQBPj/RbcQaW6PaI.UlZCxXdQ80vnq.', now(), 13, null, null, null);
--Insert INTO "user_account" ("username", "name", "password", "created_at", "level", "profile_picture", "bodyweight", "gender_id") VALUES ('mmustermann', 'Max', 'password', now(), 1, null, 80, 1);


CREATE TABLE user_list (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    list_id INTEGER NOT NULL,
    creator_id BIGINT NOT NULL REFERENCES user_account(id) ON DELETE CASCADE ON UPDATE CASCADE,
    member_id BIGINT NOT NULL REFERENCES user_account(id) ON DELETE CASCADE ON UPDATE CASCADE
);
--Insert INTO "user_list" ("list_id", "creator_id", "member_id") VALUES (1, 1, 2);


CREATE TABLE report (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    reporter_id BIGINT NOT NULL REFERENCES user_account(id) ON DELETE CASCADE ON UPDATE CASCADE,
    reported_id BIGINT NOT NULL REFERENCES user_account(id) ON DELETE CASCADE ON UPDATE CASCADE,
    is_offensive_profile_picture BOOLEAN,
    is_offensive_name BOOLEAN,
    is_offensive_username BOOLEAN,
    is_other BOOLEAN   
);
--Insert INTO "report" ("reporter_id", "reported_id", "is_offensive_profile_picture", "is_offensive_name", "is_offensive_username", "is_other") VALUES (1, 2, 'false', 'true', 'false', 'false');


CREATE TABLE gym (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    location POINT NOT NULL
);
--Insert INTO "gym" ("name", "location") VALUES ('Energym Öhringen', POINT(40.7128, -74.0060));


CREATE TABLE user_account_gym (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES user_account(id) ON DELETE CASCADE ON UPDATE CASCADE,
    gym_id BIGINT NOT NULL REFERENCES gym(id) ON DELETE CASCADE ON UPDATE CASCADE
);
--Insert INTO "user_account_gym" ("user_id", "gym_id") VALUES (1, 1);
--Insert INTO "user_account_gym" ("user_id", "gym_id") VALUES (2, 1);


CREATE TABLE friends (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    requester_id BIGINT NOT NULL REFERENCES user_account(id) ON DELETE CASCADE ON UPDATE CASCADE,
    requested_id BIGINT NOT NULL REFERENCES user_account(id) ON DELETE CASCADE ON UPDATE CASCADE,
    is_accepted BOOLEAN NOT NULL
);
--Insert INTO "friends" ("requester_id", "requested_id", "is_accepted")VALUES (1, 2, 'false');


CREATE TABLE user_settings (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES user_account(id) ON DELETE CASCADE ON UPDATE CASCADE,
    font_size DECIMAL NOT NULL,
    is_dark_mode BOOLEAN NOT NULL,
    language_id BIGINT NOT NULL REFERENCES language(id) ON DELETE SET DEFAULT ON UPDATE CASCADE,
    is_unlisted BOOLEAN NOT NULL,
    is_pull_from_everyone BOOLEAN NOT NULL,
    pull_user_list_id BIGINT REFERENCES user_list(id) ON DELETE SET NULL ON UPDATE CASCADE,
    is_notify_everyone BOOLEAN NOT NULL,
    notify_user_list_id BIGINT REFERENCES user_list(id) ON DELETE SET NULL ON UPDATE CASCADE
);
Insert INTO "user_settings" ("user_id", "font_size", "is_dark_mode", "language_id", "is_unlisted", "is_pull_from_everyone", "pull_user_list_id", "is_notify_everyone", "notify_user_list_id") VALUES (1, 15, 'false', 1, 'false', 'true', null, 'true', null);
--Insert INTO "user_settings" ("user_id", "font_size", "is_dark_mode", "language_id", "is_unlisted", "is_pull_from_everyone", "pull_user_list_id", "is_notify_everyone", "notify_user_list_id") VALUES (2, 22, 'false', 2, 'true', 'false', 1, 'true', null);


CREATE TABLE plan (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES user_account(id) ON DELETE CASCADE ON UPDATE CASCADE,
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
Insert INTO "plan" ("user_id", "part_count", "name", "startdate", "is_weekly", "is_monday_blocked", "is_tuesday_blocked", "is_wednesday_blocked", "is_thursday_blocked", "is_friday_blocked", "is_saturday_blocked", "is_sunday_blocked") VALUES (1, 3, 'Daniels Plan', now(), 'false', 'true', 'false', 'false', 'false', 'false', 'false', 'false');
Insert INTO "plan" ("user_id", "part_count", "name", "startdate", "is_weekly", "is_monday_blocked", "is_tuesday_blocked", "is_wednesday_blocked", "is_thursday_blocked", "is_friday_blocked", "is_saturday_blocked", "is_sunday_blocked") VALUES (1, 4, 'Daniels 4er', now(), 'true', 'true', 'false', 'true', 'false', 'false', 'true', 'false');


CREATE TABLE split (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    plan_id BIGINT NOT NULL REFERENCES plan(id) ON DELETE CASCADE ON UPDATE CASCADE,
    name VARCHAR(20) NOT NULL,
    order_in_plan INTEGER NOT NULL
);
--Insert INTO "split" ("plan_id", "name", "order_in_plan") VALUES (1, 'legs', 1);


CREATE TABLE exercise (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    creator_id BIGINT REFERENCES user_account(id) ON DELETE CASCADE ON UPDATE CASCADE,
    name VARCHAR(50) NOT NULL,
    type_id BIGINT NOT NULL REFERENCES exercise_type(id) ON DELETE CASCADE ON UPDATE CASCADE
);
--Insert INTO "exercise" ("creator_id", "name", "type_id") VALUES (1, 'benchpress', 1);


CREATE TABLE exercise_split (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    split_id BIGINT NOT NULL REFERENCES split(id) ON DELETE CASCADE ON UPDATE CASCADE,
    exercise_id BIGINT NOT NULL REFERENCES exercise(id) ON DELETE CASCADE ON UPDATE CASCADE
);
--Insert INTO "exercise_split" ("split_id", "exercise_id") VALUES (1, 1);


CREATE TABLE workout (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES user_account(id) ON DELETE CASCADE ON UPDATE CASCADE,
    plan_id BIGINT REFERENCES plan(id) ON DELETE SET NULL ON UPDATE CASCADE,
    split_id BIGINT REFERENCES split(id) ON DELETE SET NULL ON UPDATE CASCADE,
    starttime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    endtime TIMESTAMP,
    is_archived BOOLEAN NOT NULL
);
INSERT INTO "workout" ("user_id", "plan_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, null, null, '2024-01-05 06:45:00', '2024-01-05 07:40:00', 'false');
INSERT INTO "workout" ("user_id", "plan_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, 1, null, '2024-01-07 17:30:00', '2024-01-07 18:15:00', 'true');
INSERT INTO "workout" ("user_id", "plan_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, null, null, '2024-01-09 08:15:00', '2024-01-09 09:20:00', 'false');
INSERT INTO "workout" ("user_id", "plan_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, 1, null, '2024-01-11 12:00:00', '2024-01-11 12:45:00', 'false');
INSERT INTO "workout" ("user_id", "plan_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, null, null, '2024-01-13 09:30:00', '2024-01-13 10:30:00', 'false');
INSERT INTO "workout" ("user_id", "plan_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, 2, null, '2024-01-15 07:00:00', '2024-01-15 07:30:00', 'true');
INSERT INTO "workout" ("user_id", "plan_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, null, null, '2024-01-17 18:00:00', '2024-01-17 19:00:00', 'false');
INSERT INTO "workout" ("user_id", "plan_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, 1, null, '2024-01-19 10:00:00', '2024-01-19 11:15:00', 'false');
INSERT INTO "workout" ("user_id", "plan_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, null, null, '2024-01-21 08:30:00', '2024-01-21 09:45:00', 'false');
INSERT INTO "workout" ("user_id", "plan_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, 2, null, '2024-01-22 17:45:00', '2024-01-22 18:45:00', 'true');
INSERT INTO "workout" ("user_id", "plan_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, null, null, '2024-01-23 08:15:00', '2024-01-23 09:10:00', 'false');
INSERT INTO "workout" ("user_id", "plan_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, 1, null, '2024-01-25 07:45:00', '2024-01-25 08:43:00', 'true');
INSERT INTO "workout" ("user_id", "plan_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, 1, null, '2024-01-28 18:00:00', '2024-01-28 18:31:00', 'true');
INSERT INTO "workout" ("user_id", "plan_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, 2, null, '2024-01-30 09:00:00', '2024-01-30 10:19:00', 'true');
INSERT INTO "workout" ("user_id", "plan_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, 2, null, '2024-02-01 07:30:00', '2024-02-01 08:28:00', 'false');
INSERT INTO "workout" ("user_id", "plan_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, null, null, '2024-02-03 08:00:00', '2024-02-03 08:58:00', 'false');
INSERT INTO "workout" ("user_id", "plan_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, null, null, '2024-02-05 18:30:00', '2024-02-05 19:03:00', 'true');
INSERT INTO "workout" ("user_id", "plan_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, 1, null, '2024-02-07 10:30:00', '2024-02-07 11:42:00', 'true');
INSERT INTO "workout" ("user_id", "plan_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, null, null, '2024-02-09 08:15:00', '2024-02-09 09:10:00', 'false');
INSERT INTO "workout" ("user_id", "plan_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, null, null, '2024-02-10 07:45:00', '2024-02-10 08:43:00', 'true');
INSERT INTO "workout" ("user_id", "plan_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, 2, null, '2024-02-13 08:00:00', '2024-02-13 08:58:00', 'false');
INSERT INTO "workout" ("user_id", "plan_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, 2, null, '2024-02-14 07:30:00', '2024-02-14 08:34:00', 'false');
INSERT INTO "workout" ("user_id", "plan_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, 1, null, '2024-02-16 09:00:00', '2024-02-16 10:15:00', 'false');
INSERT INTO "workout" ("user_id", "plan_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, null, null, now(), null, 'false');


CREATE TABLE set (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    workout_id BIGINT NOT NULL REFERENCES workout(id) ON DELETE CASCADE ON UPDATE CASCADE,
    exercise_id BIGINT NOT NULL REFERENCES exercise(id) ON DELETE CASCADE ON UPDATE CASCADE,
    order_number INTEGER NOT NULL,
    measurement VARCHAR(50) NOT NULL
);
--Insert INTO "set" ("workout_id", "exercise_id", "order_number", "measurement") VALUES (1, 1, 1, '8x120');


CREATE TABLE best_lifts (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES user_account(id) ON DELETE CASCADE ON UPDATE CASCADE,
    set_id BIGINT NOT NULL REFERENCES set(id) ON DELETE CASCADE ON UPDATE CASCADE,
    position_id BIGINT NOT NULL REFERENCES position(id) ON DELETE CASCADE ON UPDATE CASCADE
);
--Insert INTO "best_lifts" ("user_id", "set_id", "position_id") VALUES (1, 1, 1);

COMMIT;