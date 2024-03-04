BEGIN;

/*
-- Drop all tables
DROP TABLE IF EXISTS exercise_type, language, position, user_account, user_list, report, gym, user_account_gym, friendship, user_settings, plan, split, exercise, exercise_split, workout, set, best_lifts CASCADE;

or

DROP SCHEMA IF EXISTS public CASCADE;
*/

CREATE SCHEMA IF NOT EXISTS public;

CREATE TABLE exercise_type (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE language (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE position (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE user_account (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    username VARCHAR(20) NOT NULL,
    name VARCHAR(20) NOT NULL,
    password VARCHAR NOT NULL,
    created_at TIMESTAMP NOT NULL,
    level INTEGER NOT NULL,
    profile_picture BYTEA
);

CREATE TABLE user_list (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    list_id INTEGER NOT NULL,
    creator_id BIGINT NOT NULL REFERENCES user_account(id) ON DELETE CASCADE ON UPDATE CASCADE,
    member_id BIGINT NOT NULL REFERENCES user_account(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE report (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    reporter_id BIGINT NOT NULL REFERENCES user_account(id) ON DELETE CASCADE ON UPDATE CASCADE,
    reported_id BIGINT NOT NULL REFERENCES user_account(id) ON DELETE CASCADE ON UPDATE CASCADE,
    is_offensive_profile_picture BOOLEAN NOT NULL,
    is_offensive_name BOOLEAN NOT NULL,
    is_offensive_username BOOLEAN NOT NULL,
    is_other BOOLEAN NOT NULL, 
    message VARCHAR
);

CREATE TABLE gym (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    location POINT NOT NULL
);

CREATE TABLE user_account_gym (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES user_account(id) ON DELETE CASCADE ON UPDATE CASCADE,
    gym_id BIGINT NOT NULL REFERENCES gym(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE friendship (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    created_at TIMESTAMP NOT NULL,
    requestor_id BIGINT NOT NULL REFERENCES user_account(id) ON DELETE CASCADE ON UPDATE CASCADE,
    requested_id BIGINT NOT NULL REFERENCES user_account(id) ON DELETE CASCADE ON UPDATE CASCADE,
    is_accepted BOOLEAN NOT NULL
);

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

CREATE TABLE split (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    plan_id BIGINT NOT NULL REFERENCES plan(id) ON DELETE CASCADE ON UPDATE CASCADE,
    name VARCHAR(20) NOT NULL,
    order_in_plan INTEGER NOT NULL
);

CREATE TABLE exercise (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    creator_id BIGINT REFERENCES user_account(id) ON DELETE CASCADE ON UPDATE CASCADE,
    name VARCHAR(50) NOT NULL,
    type_id BIGINT NOT NULL REFERENCES exercise_type(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE exercise_split (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    split_id BIGINT NOT NULL REFERENCES split(id) ON DELETE CASCADE ON UPDATE CASCADE,
    exercise_id BIGINT NOT NULL REFERENCES exercise(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE workout (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES user_account(id) ON DELETE CASCADE ON UPDATE CASCADE,
    split_id BIGINT REFERENCES split(id) ON DELETE SET NULL ON UPDATE CASCADE,
    starttime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    endtime TIMESTAMP,
    is_archived BOOLEAN NOT NULL
);

CREATE TABLE set (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    workout_id BIGINT NOT NULL REFERENCES workout(id) ON DELETE CASCADE ON UPDATE CASCADE,
    exercise_id BIGINT NOT NULL REFERENCES exercise(id) ON DELETE CASCADE ON UPDATE CASCADE,
    order_number INTEGER NOT NULL,
    repetitions INTEGER,
    weight DECIMAL,
    duration DECIMAL
);

CREATE TABLE best_lifts (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES user_account(id) ON DELETE CASCADE ON UPDATE CASCADE,
    set_id BIGINT NOT NULL REFERENCES set(id) ON DELETE CASCADE ON UPDATE CASCADE,
    position_id BIGINT NOT NULL REFERENCES position(id) ON DELETE CASCADE ON UPDATE CASCADE
);


--INSERTS
Insert INTO "exercise_type" ("name") VALUES ('reps');
Insert INTO "exercise_type" ("name") VALUES ('duration');

Insert INTO "language" ("name") VALUES ('english');
Insert INTO "language" ("name") VALUES ('german');

Insert INTO "position" ("name") VALUES ('first');
Insert INTO "position" ("name") VALUES ('second');
Insert INTO "position" ("name") VALUES ('third');

Insert INTO "user_account" ("username", "name", "password", "created_at", "level", "profile_picture") VALUES ('dholzwarth', 'BigD', '$2a$10$98nFaNeDYZ/eWHxQcY9GqOXQBPj/RbcQaW6PaI.UlZCxXdQ80vnq.', now(), 13, null);
INSERT INTO "user_account" ("username", "name", "password", "created_at", "level", "profile_picture") VALUES ('hustler21', 'Karl', '$2a$10$98nFaNeDYZ/eWHxQcY9GqOXQBPj/RbcQaW6PaI.UlZCxXdQ80vnq.', '2023-05-12', 5, null);
INSERT INTO "user_account" ("username", "name", "password", "created_at", "level", "profile_picture") VALUES ('gretchen22', 'Greta', '$2a$10$98nFaNeDYZ/eWHxQcY9GqOXQBPj/RbcQaW6PaI.UlZCxXdQ80vnq.', '2022-11-28', 7, null);
INSERT INTO "user_account" ("username", "name", "password", "created_at", "level", "profile_picture") VALUES ('pellob', 'Pelle', '$2a$10$98nFaNeDYZ/eWHxQcY9GqOXQBPj/RbcQaW6PaI.UlZCxXdQ80vnq.', '2021-08-07', 22, null);
INSERT INTO "user_account" ("username", "name", "password", "created_at", "level", "profile_picture") VALUES ('sapphire88', 'Sophie', '$2a$10$98nFaNeDYZ/eWHxQcY9GqOXQBPj/RbcQaW6PaI.UlZCxXdQ80vnq.', '2020-04-15', 13, null);
INSERT INTO "user_account" ("username", "name", "password", "created_at", "level", "profile_picture") VALUES ('rockstar27', 'Rick', '$2a$10$98nFaNeDYZ/eWHxQcY9GqOXQBPj/RbcQaW6PaI.UlZCxXdQ80vnq.', '2019-09-23', 6, null);
INSERT INTO "user_account" ("username", "name", "password", "created_at", "level", "profile_picture") VALUES ('greenapple12', 'Grace', '$2a$10$98nFaNeDYZ/eWHxQcY9GqOXQBPj/RbcQaW6PaI.UlZCxXdQ80vnq.', '2018-12-07', 14, null);
INSERT INTO "user_account" ("username", "name", "password", "created_at", "level", "profile_picture") VALUES ('thunderbird99', 'Tom', '$2a$10$98nFaNeDYZ/eWHxQcY9GqOXQBPj/RbcQaW6PaI.UlZCxXdQ80vnq.', '2017-07-30', 48, null);
INSERT INTO "user_account" ("username", "name", "password", "created_at", "level", "profile_picture") VALUES ('moonlight21', 'Mia', '$2a$10$98nFaNeDYZ/eWHxQcY9GqOXQBPj/RbcQaW6PaI.UlZCxXdQ80vnq.', '2016-05-12', 95, null);
INSERT INTO "user_account" ("username", "name", "password", "created_at", "level", "profile_picture") VALUES ('firefly88', 'Frank', '$2a$10$98nFaNeDYZ/eWHxQcY9GqOXQBPj/RbcQaW6PaI.UlZCxXdQ80vnq.', '2015-03-18', 7, null);
INSERT INTO "user_account" ("username", "name", "password", "created_at", "level", "profile_picture") VALUES ('bluesky32', 'Bella', '$2a$10$98nFaNeDYZ/eWHxQcY9GqOXQBPj/RbcQaW6PaI.UlZCxXdQ80vnq.', '2014-02-01', 82, null);
INSERT INTO "user_account" ("username", "name", "password", "created_at", "level", "profile_picture") VALUES ('silvershadow11', 'Sam', '$2a$10$98nFaNeDYZ/eWHxQcY9GqOXQBPj/RbcQaW6PaI.UlZCxXdQ80vnq.', '2013-11-22', 6, null);
INSERT INTO "user_account" ("username", "name", "password", "created_at", "level", "profile_picture") VALUES ('whiterabbit99', 'Will', '$2a$10$98nFaNeDYZ/eWHxQcY9GqOXQBPj/RbcQaW6PaI.UlZCxXdQ80vnq.', '2012-08-09', 73, null);
INSERT INTO "user_account" ("username", "name", "password", "created_at", "level", "profile_picture") VALUES ('midnightowl45', 'Molly', '$2a$10$98nFaNeDYZ/eWHxQcY9GqOXQBPj/RbcQaW6PaI.UlZCxXdQ80vnq.', '2011-06-17', 54, null);
INSERT INTO "user_account" ("username", "name", "password", "created_at", "level", "profile_picture") VALUES ('goldenlion22', 'George', '$2a$10$98nFaNeDYZ/eWHxQcY9GqOXQBPj/RbcQaW6PaI.UlZCxXdQ80vnq.', '2010-04-25', 5, null);
INSERT INTO "user_account" ("username", "name", "password", "created_at", "level", "profile_picture") VALUES ('purplepeacock77', 'Peter', '$2a$10$98nFaNeDYZ/eWHxQcY9GqOXQBPj/RbcQaW6PaI.UlZCxXdQ80vnq.', '2009-03-11', 36, null);
INSERT INTO "user_account" ("username", "name", "password", "created_at", "level", "profile_picture") VALUES ('silverdolphin88', 'Sara', '$2a$10$98nFaNeDYZ/eWHxQcY9GqOXQBPj/RbcQaW6PaI.UlZCxXdQ80vnq.', '2008-01-05', 7, null);
INSERT INTO "user_account" ("username", "name", "password", "created_at", "level", "profile_picture") VALUES ('bluewhale99', 'Ben', '$2a$10$98nFaNeDYZ/eWHxQcY9GqOXQBPj/RbcQaW6PaI.UlZCxXdQ80vnq.', '2007-09-28', 8, null);
INSERT INTO "user_account" ("username", "name", "password", "created_at", "level", "profile_picture") VALUES ('greendragon22', 'Grace', '$2a$10$98nFaNeDYZ/eWHxQcY9GqOXQBPj/RbcQaW6PaI.UlZCxXdQ80vnq.', '2006-07-17', 3, null);
INSERT INTO "user_account" ("username", "name", "password", "created_at", "level", "profile_picture") VALUES ('redphoenix77', 'Ron', '$2a$10$98nFaNeDYZ/eWHxQcY9GqOXQBPj/RbcQaW6PaI.UlZCxXdQ80vnq.', '2005-05-01', 15, null);
INSERT INTO "user_account" ("username", "name", "password", "created_at", "level", "profile_picture") VALUES ('silverfox88', 'Samantha', '$2a$10$98nFaNeDYZ/eWHxQcY9GqOXQBPj/RbcQaW6PaI.UlZCxXdQ80vnq.', '2004-03-12', 6, null);
INSERT INTO "user_account" ("username", "name", "password", "created_at", "level", "profile_picture") VALUES ('whiterose99', 'Wendy', '$2a$10$98nFaNeDYZ/eWHxQcY9GqOXQBPj/RbcQaW6PaI.UlZCxXdQ80vnq.', '2003-01-24', 17, null);
INSERT INTO "user_account" ("username", "name", "password", "created_at", "level", "profile_picture") VALUES ('blackpanther22', 'Brad', '$2a$10$98nFaNeDYZ/eWHxQcY9GqOXQBPj/RbcQaW6PaI.UlZCxXdQ80vnq.', '2002-11-09', 24, null);
INSERT INTO "user_account" ("username", "name", "password", "created_at", "level", "profile_picture") VALUES ('pinkflamingo77', 'Pam', '$2a$10$98nFaNeDYZ/eWHxQcY9GqOXQBPj/RbcQaW6PaI.UlZCxXdQ80vnq.', '2001-09-15', 16, null);

Insert INTO "gym" ("name", "location") VALUES ('Energym Öhringen', POINT(40.7128, -74.0060));
Insert INTO "gym" ("name", "location") VALUES ('Cleverfit XYZ', POINT(41.7128, -72.0060));
Insert INTO "gym" ("name", "location") VALUES ('Another Gym', POINT(43.7128, -71.0060));

Insert INTO "user_account_gym" ("user_id", "gym_id") VALUES (1, 1);
Insert INTO "user_account_gym" ("user_id", "gym_id") VALUES (1, 2);
Insert INTO "user_settings" ("user_id", "font_size", "is_dark_mode", "language_id", "is_unlisted", "is_pull_from_everyone", "pull_user_list_id", "is_notify_everyone", "notify_user_list_id") VALUES (1, 15, 'false', 1, 'false', 'true', null, 'true', null);

Insert INTO "plan" ("user_id", "part_count", "name", "startdate", "is_weekly", "is_monday_blocked", "is_tuesday_blocked", "is_wednesday_blocked", "is_thursday_blocked", "is_friday_blocked", "is_saturday_blocked", "is_sunday_blocked") VALUES (1, 3, 'Daniels Plan', now(), 'false', 'true', 'false', 'false', 'false', 'false', 'false', 'false');
Insert INTO "plan" ("user_id", "part_count", "name", "startdate", "is_weekly", "is_monday_blocked", "is_tuesday_blocked", "is_wednesday_blocked", "is_thursday_blocked", "is_friday_blocked", "is_saturday_blocked", "is_sunday_blocked") VALUES (1, 4, 'Daniels 4er', now(), 'true', 'true', 'false', 'true', 'false', 'false', 'true', 'false');

Insert INTO "split" ("plan_id", "name", "order_in_plan") VALUES (1, 'Push', 1);
Insert INTO "split" ("plan_id", "name", "order_in_plan") VALUES (1, 'Pull', 2);
Insert INTO "split" ("plan_id", "name", "order_in_plan") VALUES (1, 'Legs', 3);
Insert INTO "split" ("plan_id", "name", "order_in_plan") VALUES (2, 'Brust Bizeps Bauch', 1);
Insert INTO "split" ("plan_id", "name", "order_in_plan") VALUES (2, 'Beine Po', 2);
Insert INTO "split" ("plan_id", "name", "order_in_plan") VALUES (2, 'Schulter Nacken', 3);
Insert INTO "split" ("plan_id", "name", "order_in_plan") VALUES (2, 'Rücken Trizeps Bauch', 4);

Insert INTO "exercise" ("creator_id", "name", "type_id") VALUES (null, 'Benchpress', 1);
Insert INTO "exercise" ("creator_id", "name", "type_id") VALUES (null, 'Plank', 2);
Insert INTO "exercise" ("creator_id", "name", "type_id") VALUES (null, 'Deadlift', 1);
Insert INTO "exercise" ("creator_id", "name", "type_id") VALUES (null, 'Biceps Curls', 1);

INSERT INTO "workout" ("user_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, 1, '2024-01-05 06:45:00', '2024-01-05 07:40:00', 'false');
INSERT INTO "workout" ("user_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, 2, '2024-01-07 17:30:00', '2024-01-07 18:15:00', 'true');
INSERT INTO "workout" ("user_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, 3, '2024-01-09 08:15:00', '2024-01-09 09:20:00', 'false');
INSERT INTO "workout" ("user_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, 1, '2024-01-11 12:00:00', '2024-01-11 12:45:00', 'false');
INSERT INTO "workout" ("user_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, 2, '2024-01-13 09:30:00', '2024-01-13 10:30:00', 'false');
INSERT INTO "workout" ("user_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, 3, '2024-01-15 07:00:00', '2024-01-15 07:30:00', 'true');
INSERT INTO "workout" ("user_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, null, '2024-01-17 18:00:00', '2024-01-17 19:00:00', 'false');
INSERT INTO "workout" ("user_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, null, '2024-01-19 10:00:00', '2024-01-19 11:15:00', 'false');
INSERT INTO "workout" ("user_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, 4, '2024-01-21 08:30:00', '2024-01-21 09:45:00', 'false');
INSERT INTO "workout" ("user_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, 5, '2024-01-22 17:45:00', '2024-01-22 18:45:00', 'true');
INSERT INTO "workout" ("user_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, 6, '2024-01-23 08:15:00', '2024-01-23 09:10:00', 'false');
INSERT INTO "workout" ("user_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, 7, '2024-01-25 07:45:00', '2024-01-25 08:43:00', 'true');
INSERT INTO "workout" ("user_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, 4, '2024-01-28 18:00:00', '2024-01-28 18:31:00', 'true');
INSERT INTO "workout" ("user_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, 5, '2024-01-30 09:00:00', '2024-01-30 10:19:00', 'true');
INSERT INTO "workout" ("user_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, 6, '2024-02-01 07:30:00', '2024-02-01 08:28:00', 'false');
INSERT INTO "workout" ("user_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, 7, '2024-02-03 08:00:00', '2024-02-03 08:58:00', 'false');
INSERT INTO "workout" ("user_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, 4, '2024-02-05 18:30:00', '2024-02-05 19:03:00', 'true');
INSERT INTO "workout" ("user_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, 5, '2024-02-07 10:30:00', '2024-02-07 11:42:00', 'true');
INSERT INTO "workout" ("user_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, null, '2024-02-09 08:15:00', '2024-02-09 09:10:00', 'false');
INSERT INTO "workout" ("user_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, 6, '2024-02-10 07:45:00', '2024-02-10 08:43:00', 'true');
INSERT INTO "workout" ("user_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, 7, '2024-02-13 08:00:00', '2024-02-13 08:58:00', 'false');
INSERT INTO "workout" ("user_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, 4, '2024-02-14 07:30:00', '2024-02-14 08:34:00', 'false');
INSERT INTO "workout" ("user_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, 5, '2024-02-16 09:00:00', '2024-02-16 10:15:00', 'false');
INSERT INTO "workout" ("user_id", "split_id", "starttime", "endtime", "is_archived") VALUES (1, 6, now(), null, 'false');

Insert INTO "set" ("workout_id", "exercise_id", "order_number", "repetitions", "weight", "duration") VALUES (1, 1, 1, 3, 215.5, null);
Insert INTO "set" ("workout_id", "exercise_id", "order_number", "repetitions", "weight", "duration") VALUES (4, 2, 1, null, null, 203.3);
Insert INTO "set" ("workout_id", "exercise_id", "order_number", "repetitions", "weight", "duration") VALUES (7, 3, 1, 8, 125.5, null);
Insert INTO "set" ("workout_id", "exercise_id", "order_number", "repetitions", "weight", "duration") VALUES (7, 2, 2, null, null, 192.8);

Insert INTO "best_lifts" ("user_id", "set_id", "position_id") VALUES (1, 1, 1);
Insert INTO "best_lifts" ("user_id", "set_id", "position_id") VALUES (1, 2, 2);
Insert INTO "best_lifts" ("user_id", "set_id", "position_id") VALUES (1, 3, 3);


COMMIT;