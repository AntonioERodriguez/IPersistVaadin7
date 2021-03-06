
/* Drop Tables */

DROP TABLE TREAT_GRANTED;
DROP TABLE JOURNAL;
DROP TABLE ACTION;
DROP TABLE ADVISOR;
DROP TABLE BENEFIT;
DROP TABLE EMAIL_LINK;
DROP TABLE TREAT;
DROP TABLE GOAL;
DROP TABLE MEASUREMENT_UNIT;
DROP TABLE PERSON;




/* Create Tables */

CREATE TABLE ACTION
(
	ACTION_ID int NOT NULL UNIQUE,
	GOAL_ID int NOT NULL,
	NAME varchar(50) NOT NULL,
	COMMENTS varchar(255),
	-- how many units of this task need be done periodically (for example, read 30 minutes every day)
	QUANTITY_COMMITTED int NOT NULL,
	-- To allow to create tasks that do not need to occur every single day, but still need to be periodic (for example, go to the gym 3 times every 7 days); a value of zero would mean this task needs to be done only once
	PERIODICITY_IN_DAYS int NOT NULL,
	-- how many units (same type of unit) are estimated to be required to accomplish this goal (for example, read 720 minutes, or about 12 hours)
	REQUIRED_BY_GOAL int NOT NULL,
	-- units in which this task is measured (for example, read for 30 minutes, the unit is minutes); use a unit that will allow to use integer values for the quantities
	UNIT_ID int NOT NULL,
	STATUS tinyint NOT NULL,
	PRIMARY KEY (ACTION_ID),
	UNIQUE (GOAL_ID, NAME)
);


-- advisor relationship between users; with a degree of empathy (how much the main user fears the advisor)
CREATE TABLE ADVISOR
(
	AR_ID int NOT NULL UNIQUE,
	ADVISED_ID int NOT NULL,
	SUPERVISOR_ID int NOT NULL,
	-- External enumeration, describing how much the advisor is feared by the user
	EMPATHY tinyint NOT NULL,
	STATUS tinyint NOT NULL,
	INVITED_DT date NOT NULL,
	START_DT date,
	END_DT date,
	PRIMARY KEY (AR_ID),
	UNIQUE (ADVISED_ID, SUPERVISOR_ID)
);


CREATE TABLE BENEFIT
(
	BENEFIT_ID int NOT NULL UNIQUE,
	GOAL_ID int NOT NULL,
	NAME varchar(50) NOT NULL,
	COMMENTS varchar(255),
	QUANTITY int NOT NULL,
	UNIT_ID int NOT NULL,
	PERIODICITY_IN_YEARS tinyint NOT NULL,
	PRIMARY KEY (BENEFIT_ID),
	UNIQUE (GOAL_ID, NAME)
);


CREATE TABLE EMAIL_LINK
(
	LINK_ID int NOT NULL UNIQUE,
	-- Automatically generated Global Unique ID
	TOKEN varchar(255) NOT NULL UNIQUE,
	TO_EMAIL varchar(255) NOT NULL,
	-- External enumeration: type of email (forgot password, invitation submitted, ...)
	LINK_TYPE tinyint NOT NULL,
	-- In case we need to add some parameters to the email
	ADDITIONAL_INFO varchar(255),
	FROM_PERSON_ID int,
	GENERATED_DT timestamp NOT NULL,
	EXPIRATION_DT timestamp NOT NULL,
	USED_DT timestamp,
	STATUS tinyint,
	PRIMARY KEY (LINK_ID)
);


-- A User's goal. A goal can be split into daily tasks
CREATE TABLE GOAL
(
	GOAL_ID int NOT NULL UNIQUE,
	PERSON_ID int NOT NULL,
	-- Description of the goal
	NAME varchar(50) NOT NULL,
	COMMENTS varchar(255),
	DUE_BY date NOT NULL,
	STATUS tinyint NOT NULL,
	-- External enumeration, trying to group goals by category (financial, health, business, ...)
	CATEGORY tinyint NOT NULL,
	PRIMARY KEY (GOAL_ID),
	UNIQUE (PERSON_ID, NAME)
);


CREATE TABLE JOURNAL
(
	JOURNAL_ID int NOT NULL UNIQUE,
	ACTION_ID int NOT NULL,
	CORRESPONDING_TO date NOT NULL,
	UNITS_ACHIEVED int NOT NULL,
	EFFICIENCY tinyint NOT NULL,
	COMMENTS varchar(255),
	RECORDED date NOT NULL,
	STATUS tinyint NOT NULL,
	PRIMARY KEY (JOURNAL_ID),
	UNIQUE (ACTION_ID, CORRESPONDING_TO)
);


CREATE TABLE MEASUREMENT_UNIT
(
	UNIT_ID int NOT NULL UNIQUE,
	NAME varchar(20) NOT NULL UNIQUE,
	DIMENSION tinyint NOT NULL,
	BASE_UNIT tinyint NOT NULL,
	BASE_MULTIPLIER int NOT NULL,
	PRIMARY KEY (UNIT_ID)
);


-- A sytem's user
CREATE TABLE PERSON
(
	PERSON_ID int NOT NULL UNIQUE,
	EMAIL varchar(255) NOT NULL UNIQUE,
	FIRST_NAMES varchar(100) NOT NULL,
	LAST_NAMES varchar(100) NOT NULL,
	-- External enumeration: male/female (m/f)
	GENDER char(1) NOT NULL,
	PASSWORD varchar(255) NOT NULL,
	-- Number of failed login attempts; reset to zero when a valid login is achieved
	FAILED_LOGINS int NOT NULL,
	PWD_UPDATED timestamp,
	STATUS tinyint NOT NULL,
	-- External enumeration: validated, not-validated
	EMAIL_STATUS tinyint NOT NULL,
	LAST_LOGIN timestamp,
	-- External enumeration: free user, paid user, only advisor
	ROLE tinyint NOT NULL,
	PRIMARY KEY (PERSON_ID)
);


CREATE TABLE TREAT
(
	TREAT_ID int NOT NULL UNIQUE,
	GOAL_ID int NOT NULL,
	NAME varchar(50) NOT NULL,
	COMMENTS varchar(255),
	-- this treat will be earned only after the given percentage of the benefit is achieved, depending on the treat_type
	PCTG_ACHIEVMENT_REQD tinyint NOT NULL,
	-- An enumeration value: daily treat, accumulated effort treat 
	TREAT_TYPE tinyint NOT NULL,
	PRIMARY KEY (TREAT_ID),
	UNIQUE (GOAL_ID, NAME)
);


CREATE TABLE TREAT_GRANTED
(
	TG_ID int NOT NULL UNIQUE,
	TREAT_ID int NOT NULL,
	JOURNAL_ID int NOT NULL,
	STAKEHOLDERS_NOTIFIED tinyint NOT NULL,
	PRIMARY KEY (TG_ID),
	UNIQUE (TREAT_ID, JOURNAL_ID)
);



/* Create Foreign Keys */

ALTER TABLE JOURNAL
	ADD FOREIGN KEY (ACTION_ID)
	REFERENCES ACTION (ACTION_ID)
	ON UPDATE RESTRICT
	ON DELETE RESTRICT
;


ALTER TABLE ACTION
	ADD FOREIGN KEY (GOAL_ID)
	REFERENCES GOAL (GOAL_ID)
	ON UPDATE RESTRICT
	ON DELETE RESTRICT
;


ALTER TABLE TREAT
	ADD FOREIGN KEY (GOAL_ID)
	REFERENCES GOAL (GOAL_ID)
	ON UPDATE RESTRICT
	ON DELETE RESTRICT
;


ALTER TABLE BENEFIT
	ADD FOREIGN KEY (GOAL_ID)
	REFERENCES GOAL (GOAL_ID)
	ON UPDATE RESTRICT
	ON DELETE RESTRICT
;


ALTER TABLE TREAT_GRANTED
	ADD FOREIGN KEY (JOURNAL_ID)
	REFERENCES JOURNAL (JOURNAL_ID)
	ON UPDATE RESTRICT
	ON DELETE RESTRICT
;


ALTER TABLE ACTION
	ADD FOREIGN KEY (UNIT_ID)
	REFERENCES MEASUREMENT_UNIT (UNIT_ID)
	ON UPDATE RESTRICT
	ON DELETE RESTRICT
;


ALTER TABLE BENEFIT
	ADD FOREIGN KEY (UNIT_ID)
	REFERENCES MEASUREMENT_UNIT (UNIT_ID)
	ON UPDATE RESTRICT
	ON DELETE RESTRICT
;


ALTER TABLE ADVISOR
	ADD CONSTRAINT CT_ADVISED FOREIGN KEY (ADVISED_ID)
	REFERENCES PERSON (PERSON_ID)
	ON UPDATE RESTRICT
	ON DELETE RESTRICT
;


ALTER TABLE ADVISOR
	ADD CONSTRAINT CT_SUPERVISOR FOREIGN KEY (SUPERVISOR_ID)
	REFERENCES PERSON (PERSON_ID)
	ON UPDATE RESTRICT
	ON DELETE RESTRICT
;


ALTER TABLE GOAL
	ADD FOREIGN KEY (PERSON_ID)
	REFERENCES PERSON (PERSON_ID)
	ON UPDATE RESTRICT
	ON DELETE RESTRICT
;


ALTER TABLE EMAIL_LINK
	ADD FOREIGN KEY (FROM_PERSON_ID)
	REFERENCES PERSON (PERSON_ID)
	ON UPDATE RESTRICT
	ON DELETE RESTRICT
;


ALTER TABLE TREAT_GRANTED
	ADD FOREIGN KEY (TREAT_ID)
	REFERENCES TREAT (TREAT_ID)
	ON UPDATE RESTRICT
	ON DELETE RESTRICT
;



