/*
	Author Daan Sneep
	Author Ajob Kustra
*/

--EXECUTE THIS FIRST, THEN EXECUTE THE REST IN THIS NEWLY CREATED DATABASE
-- CREATE DATABASE "Beslisboom"
--     WITH
--     OWNER = postgres -- Owner could be different for you
--     ENCODING = 'UTF8'
--     CONNECTION LIMIT = -1;

---------------------------------------------------------------------------------------------------

-- EXECUTE ALL NEXT STATEMENTS IN ORDER

-- ACCOUNTS ARE REGISTERED IN BACKEND
CREATE TABLE account (
	id SERIAL PRIMARY KEY,
	username TEXT NOT NULL UNIQUE,
	email TEXT NOT NULL UNIQUE,
	pass_hash TEXT NOT NULL,
	registered_date DATE NOT NULL,
	last_logged_in DATE,
	title TEXT,
	phone_number TEXT,
	department TEXT
);

CREATE TABLE question_type (
	id SERIAL PRIMARY KEY,
	type TEXT NOT NULL
);

CREATE TABLE question (
	id SERIAL PRIMARY KEY,
	comment TEXT,
	content TEXT NOT NULL,
	type_id INTEGER NOT NULL,
	prev_answer_id INTEGER,
	tree_id INTEGER NOT NULL,
	CONSTRAINT fk_question_type_id
		FOREIGN KEY(type_id) REFERENCES question_type(id)
);

CREATE TABLE notification (
	id SERIAL PRIMARY KEY,
	title TEXT NOT NULL,
	content TEXT
);

CREATE TABLE answer (
	id SERIAL PRIMARY KEY,
	content TEXT NOT NULL,
	question_id INTEGER NOT NULL,
	notification_id INTEGER,
	CONSTRAINT fk_question_id
		FOREIGN KEY(question_id) REFERENCES question(id) ON DELETE CASCADE,
	CONSTRAINT fk_notification_id
		FOREIGN KEY(notification_id) REFERENCES notification(id) ON DELETE SET NULL
);

CREATE TABLE tree (
	id SERIAL PRIMARY KEY,
	start_question_id INTEGER, -- Has to be NOT NULL for create_tree to work properly
	user_id INTEGER NOT NULL,
	CONSTRAINT fk_start_question_id
		FOREIGN KEY(start_question_id) REFERENCES question(id),
	CONSTRAINT fk_user_id
		FOREIGN KEY(user_id) REFERENCES account(id) ON DELETE CASCADE
);

CREATE TABLE tree_version (
	id INTEGER PRIMARY KEY,
	name TEXT NOT NULL,
	versionnumber INTEGER NOT NULL,
	CONSTRAINT fk_tree_id
		FOREIGN KEY (id) REFERENCES tree(id) ON DELETE CASCADE
);

ALTER TABLE question
ADD CONSTRAINT tree_id_fk FOREIGN KEY(tree_id) REFERENCES tree(id) ON DELETE CASCADE;

ALTER TABLE question
ADD CONSTRAINT fk_type_id FOREIGN KEY (type_id) REFERENCES question_type(id) ON DELETE RESTRICT;

ALTER TABLE question
ADD CONSTRAINT fk_prev_answer_id FOREIGN KEY (prev_answer_id) REFERENCES answer(id) ON DELETE CASCADE;

INSERT INTO question_type (type) VALUES ('Multiple Choice');
INSERT INTO question_type (type) VALUES ('Radio buttons');
---------------------------------------------------------------------------------------------------

-- CREATE A QUESTION
CREATE OR REPLACE FUNCTION create_question (
    tree_id INTEGER,
    q_content TEXT,
    prev_answer_id INTEGER DEFAULT NULL,
    comment TEXT DEFAULT NULL
)
RETURNS INTEGER
LANGUAGE plpgsql
AS
$$
DECLARE
	question_id INTEGER;
BEGIN
	INSERT INTO question (content, tree_id, prev_answer_id, type_id, comment)
	VALUES (q_content, tree_id, prev_answer_id, (
		SELECT id FROM question_type WHERE type = 'Multiple Choice'
	), comment) RETURNING id INTO question_id;

	RETURN question_id;
END;
$$;

-- CREATE AN ANSWER
CREATE OR REPLACE FUNCTION create_answer (a_content TEXT, q_id INTEGER, n_id INTEGER DEFAULT NULL)
RETURNS INTEGER
LANGUAGE plpgsql
AS
$$
DECLARE
temp_id INTEGER;
BEGIN
	INSERT INTO answer (content, question_id, notification_id) VALUES (a_content, q_id, n_id) RETURNING id INTO temp_id;
	RETURN temp_id;
END;
$$;

-- CREATE A NEW TREE WITH THE FIRST QUESTION
CREATE OR REPLACE FUNCTION create_tree (q_content TEXT, name TEXT, u_id INTEGER)
RETURNS INTEGER
LANGUAGE plpgsql
AS
$$
DECLARE
	temp_id INTEGER;
	temp_tree_id INTEGER;
BEGIN
    INSERT INTO tree (user_id) VALUES (u_id) RETURNING id INTO temp_tree_id;
	INSERT INTO question (type_id, content, tree_id) VALUES ((
		SELECT id FROM question_type WHERE type = 'Multiple Choice'
	), q_content, temp_tree_id) RETURNING id INTO temp_id;
	UPDATE tree SET start_question_id = temp_id WHERE id = temp_tree_id;
	INSERT INTO tree_version (id, name, versionnumber) VALUES (temp_tree_id, name, 1);
	RETURN temp_id;
END;
$$;

-- CREATE A NOTIFICATION
CREATE OR REPLACE FUNCTION create_notification (n_title TEXT, n_content TEXT DEFAULT NULL)
RETURNS INTEGER
LANGUAGE plpgsql
AS
$$
DECLARE
temp_id INTEGER;
BEGIN
	IF n_title IS NOT NULL THEN
		IF n_content IS NOT NULL THEN
			INSERT INTO notification (title, content) VALUES (n_title, n_content) RETURNING id INTO temp_id;
		END IF;
		IF n_content IS NULL THEN
			INSERT INTO notification (title) VALUES (n_title) RETURNING id INTO temp_id;
		END IF;
	END IF;

	RETURN temp_id;
END;
$$;

---------------------------------------------------------------------------------------------------

-- GIVE ANSWER A NOTIFICATION
CREATE OR REPLACE FUNCTION couple_notification_to_answer (a_id INTEGER, n_id INTEGER)
RETURNS void
LANGUAGE plpgsql
AS
$$
BEGIN
	UPDATE answer SET notification_id = n_id WHERE id = a_id;
END;
$$;

-- EDIT QUESTION
CREATE OR REPLACE FUNCTION change_question (
	q_id INTEGER,
	q_comment TEXT DEFAULT NULL,
	q_content TEXT DEFAULT NULL,
	q_type INTEGER DEFAULT NULL,
	prev_a_id INTEGER DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
AS
$$
BEGIN
	IF q_content IS NOT NULL THEN
	 	UPDATE question SET content = q_content WHERE id = q_id;
	END IF;
	IF prev_a_id IS NOT NULL THEN
		UPDATE question SET prev_answer_id = prev_a_id WHERE id = q_id;
	END IF;
	IF q_comment IS NOT NULL THEN
		UPDATE question SET comment = q_comment WHERE id = q_id;
	END IF;
	IF q_type IS NOT NULL THEN
		UPDATE question SET type_id = q_type WHERE id = q_id;
	END IF;
END;
$$;

-- EDIT ANSWER CONTENT
CREATE OR REPLACE FUNCTION change_answer (a_id INTEGER, a_content TEXT, a_notification_id INTEGER)
RETURNS void
LANGUAGE plpgsql
AS
$$
BEGIN
	IF a_content IS NOT NULL THEN
	 	UPDATE answer SET content = a_content WHERE id = a_id;
	END IF;
	IF a_notification_id IS NOT NULL THEN
		UPDATE answer SET notification_id = a_notification_id WHERE id = a_id;
	END IF;
END;
$$;

-- EDIT NOTIFICATION CONTENT
CREATE OR REPLACE FUNCTION change_notification (n_id INTEGER, n_title TEXT DEFAULT NULL, n_content TEXT DEFAULT NULL)
RETURNS void
LANGUAGE plpgsql
AS
$$
BEGIN
	IF n_title IS NOT NULL THEN
		UPDATE notification SET title = n_title WHERE id = n_id;
	END IF;
	IF n_content IS NOT NULL THEN
		UPDATE notification SET content = n_content WHERE id = n_id;
	END IF;
END;
$$;

---------------------------------------------------------------------------------------------------
-- admin@gmail.com:admin
INSERT INTO account (username, email, pass_hash, registered_date, title, department)
VALUES ('admin', 'admin@gmail.com', '$2b$12$yoeGJYu4Id42RmvDUBuLa.nRFY.1.jguGVUmkvJ1FSyth0UwCgHqS', '2020-10-29', 'Administrator', 'Administration');

-- wendy@arag.nl:persoon
INSERT INTO account (username, email, pass_hash, registered_date, title, department)
VALUES ('Wendy Persoon', 'wendy@arag.nl', '$2b$12$B77a7.fGwigjUtpQC5lcve9Pzb0LwWGm0EWUmgpewpmCC8Adr1MDW', '2020-10-29', 'Innovation Manager', 'Innovation');

-- kaj@arag.nl:westerling
INSERT INTO account (username, email, pass_hash, registered_date, title, department)
VALUES ('Kaj Westerling', 'kaj@arag.nl', '$2b$12$S7XAu27uny0cCa56tY5DkuK3ODNpu9uuMpCC6awUe7ruBIQlmhMui', '2020-10-29', 'Stagiair', 'Stage Afdeling');

-- eray@arag.nl:akdeniz
INSERT INTO account (username, email, pass_hash, registered_date, title, department)
VALUES ('Eray', 'eray@arag.nl', '$2b$12$/fgBRBbzaVavdtAerMIL7ejlv5xZKQvEZhb20LC8p1BLTvO/whIYO', '2020-10-29', 'Stagiair', 'Stage Afdeling');

-- boere.m@hsleiden.nl:shinkendo
INSERT INTO account (username, email, pass_hash, registered_date, title, department)
VALUES ('Michiel Boere', 'boere.m@hsleiden.nl', '$2b$12$R8KK.oKwa0EVAkh4bhJIJugHoT37zTg/6W7SFPC2X2tRBH7YftHYm', '2020-10-29', 'Zen Docent', 'De beste afdeling (SE)');

-- admiraal.f@hsleiden.nl:karmapunten
INSERT INTO account (username, email, pass_hash, registered_date, title, department)
VALUES ('Floris Admiraal', 'admiraal.f@hsleiden.nl', '$2b$12$PXFugRtk8LYvl.qfAWvlxO/diP5zJ07Uu.3UYrqVUf72OUNPGMW8W', '2020-10-29', 'Jazz DJ', 'De beste afdeling (SE)');

-- verduin.e@hsleiden.nl:palmboom
INSERT INTO account (username, email, pass_hash, registered_date, title, department)
VALUES ('Evert Verduin', 'verduin.e@hsleiden.nl', '$2b$12$cux3lZuhq6DMAwGjEtqTre1VTcQGGBcd1BnScaqi.rGkUGkV3lJCu', '2020-10-29', 'Palmboom Officier', 'De beste afdeling (SE)');

-- poel.vd.c@hsleiden.nl:summer
INSERT INTO account (username, email, pass_hash, registered_date, title, department)
VALUES ('Carla van der Poel', 'poel.vd.c@hsleiden.nl', '$2b$12$gCI5TVydr/KsOjfvfXDtYOLHlQ/lrAsY/KmMEQ.ce9yw5YgIvBXOG', '2020-10-29', 'Communicatie Guru', 'ICOMMH');

DO
$$
DECLARE
temp_id INTEGER;
temp_id1 INTEGER;
temp_id1_1 INTEGER;
temp_id1_1_1 INTEGER;
temp_id1_1_1_1 INTEGER;
temp_id1_1_1_1_1 INTEGER;
temp_id1_1_1_1_1_1 INTEGER;
BEGIN
	SELECT create_tree('Wat heeft u geboekt?', 'Reisvouchercheck', (SELECT id FROM account WHERE email = 'admin@gmail.com')) INTO temp_id;
	
	SELECT create_question(1, 'Heeft de reisaanbieder u een voucher aangeboden?', (
		SELECT create_answer(
			'Pakketreis (samengestelde reis)', 
			temp_id
	))) INTO temp_id1;
		
		SELECT create_question(1, 'Bij welke reisaanbieder heeft u uw reispakket geboekt?', (
			SELECT create_answer(
				'Ja',
				temp_id1
				)
			)) INTO temp_id1_1;

			SELECT create_question(1, 'Wat wordt uw besluit?', (
				SELECT create_answer(
					'D-reizen',
					temp_id1_1,
					(SELECT create_notification('Nederlandse reisaanbieder', 'U heeft een pakketreis bij een Nederlandse reisaanbieder geboekt. De pakketreisaanbieder heeft u een voucher aangeboden. U heeft nu 2 opties: Optie 1: De voucher accepteren Dit heeft twee voordelen: - Pakketreizen geboekt bij een Nederlandse reisaanbieder zijn beschermd door SGR. U hoeft zich geen zorgen te maken over uw voucher bij een faillissement van de reisaanbieder. - Uw voucher kunt u na 6 maanden omwisselen voor geld. Optie 2: Toch uw geld terugvragen U bent niet verplicht om een voucher te accepteren als de reisaanbieder de reis annuleert. U kunt dus ook uw geld terugvragen. Wel zijn er twee redenen waarom veel reizigers alsnog een voucher accepteren: 1. Indien u een verzoek doet tot omwisselen van de voucher voor geld, dan is op dat moment de overeenkomst formeel ontbonden. Het uitbetalen van de voucher kan maanden duren. Als de reisaanbieder in die periode failliet gaat, staat de SGR niet meer garant, omdat er formeel geen overeenkomst meer was. U zult dan zelf het geld moeten vorderen via een curator. Helaas heeft dit een niet zo grote kans, omdat Nederlands recht formeel andere crediteuren voor laat gaan.2. U zult een procedure moeten starten om uw geld van de reisaanbieder te ontvangen. Onze ervaring is dat deze procedure minimaal 9 maanden duurt voordat u uw geld terugkrijgt. Wilt u al eerder reizen met dezelfde reisaanbieder? Dan kunt u beter toch de voucher accepteren.'))
					)
				)) INTO temp_id1_1_1;

				PERFORM create_answer(
					'Ik accepteer mijn voucher',
					temp_id1_1_1,
					create_notification('Fijne dag eindpunt', 'Goed om te horen, we wensen u nog een prettige dag.')
					);

				SELECT create_question(1, 'Heeft u al contact gehad?', (
					SELECT create_answer(
						'Ik heb een dringende reden om mijn geld terug te vragen',
						temp_id1_1_1
						)
					)) INTO temp_id1_1_1_1;

					PERFORM create_answer(
						'Ik heb mijn kosten al teruggevraagd, maar de reisaanbieder reageert niet.',
						temp_id1_1_1_1,
						(SELECT create_notification('Check verzekerd', 'check verzekerd'))
						);

					PERFORM create_answer(
						'Ik heb mijn kosten al teruggevraagd en ik ben in conflict met de reisaanbieder.',
						temp_id1_1_1_1,
						(SELECT create_notification('Check verzekerd', 'check verzekerd'))
						);

					PERFORM create_answer(
						'Ik heb nog geen contact gehad',
						temp_id1_1_1_1,
						(SELECT create_notification('Contact opnemen', 'Omdat u nog geen contact opgenomen heeft om uw geld terug te eisen, zal u dat eerst moeten doen. Kijk op de website van uw reisaanbieder of er een specifiek e-mailadres staat, stuurt u anders uw e-mail naar de klantenservice van uw reisaanbieder. Een e-mail sturen kunt u heel eenvoudig doen via de onderstaande 3 stappen: Stap 1. Kopieer de onderstaande tekst en plak deze in een nieuw e-mailbericht. Stap 2. Pas deze brief aan naar uw situatie. Stap 3. Stuur de gepersonaliseerde e-mail naar de reisaanbieder. Geachte heer/mevrouw, Op (voeg datum in) heb ik bij u een reis geboekt met vertrek op (voeg datum in) en retour op (voeg datum in). Het boekingsnummer is (voeg boekingsnummer in). Vanwege de onzekerheden rondom deze reis door de coronacrisis heeft u mij een voucher aangeboden ter compensatie. De voucher heeft een waarde van €(voeg bedrag in). Ik wil deze voucher echter niet accepteren, omdat (leg hier uit waarom u uw geld terug wilt). Op basis van de bovenstaande verzoek ik u binnen vier weken de waarde van de voucher naar mijn rekeningnummer (voeg IBAN nr. in) over te maken. Ik ontvang graag binnen 14 dagen uw reactie. Met vriendelijke groet, (voeg naam in)'))
						);

		SELECT create_question(1, 'Wat wordt uw besluit?', (
				SELECT create_answer(
					'Sunweb',
					temp_id1_1,
					(SELECT create_notification('Nederlandse reisaanbieder', 'U heeft een pakketreis bij een Nederlandse reisaanbieder geboekt. De pakketreisaanbieder heeft u een voucher aangeboden. U heeft nu 2 opties: Optie 1: De voucher accepteren Dit heeft twee voordelen: - Pakketreizen geboekt bij een Nederlandse reisaanbieder zijn beschermd door SGR. U hoeft zich geen zorgen te maken over uw voucher bij een faillissement van de reisaanbieder. - Uw voucher kunt u na 6 maanden omwisselen voor geld. Optie 2: Toch uw geld terugvragen U bent niet verplicht om een voucher te accepteren als de reisaanbieder de reis annuleert. U kunt dus ook uw geld terugvragen. Wel zijn er twee redenen waarom veel reizigers alsnog een voucher accepteren: 1. Indien u een verzoek doet tot omwisselen van de voucher voor geld, dan is op dat moment de overeenkomst formeel ontbonden. Het uitbetalen van de voucher kan maanden duren. Als de reisaanbieder in die periode failliet gaat, staat de SGR niet meer garant, omdat er formeel geen overeenkomst meer was. U zult dan zelf het geld moeten vorderen via een curator. Helaas heeft dit een niet zo grote kans, omdat Nederlands recht formeel andere crediteuren voor laat gaan.2. U zult een procedure moeten starten om uw geld van de reisaanbieder te ontvangen. Onze ervaring is dat deze procedure minimaal 9 maanden duurt voordat u uw geld terugkrijgt. Wilt u al eerder reizen met dezelfde reisaanbieder? Dan kunt u beter toch de voucher accepteren.'))
					)
				)) INTO temp_id1_1_1;

				PERFORM create_answer(
					'Ik accepteer mijn voucher',
					temp_id1_1_1,
					create_notification('Fijne dag', 'Goed om te horen, we wensen u nog een prettige dag.')
					);

				SELECT create_question(1, 'Heeft u al contact gehad?', (
					SELECT create_answer(
						'Ik heb een dringende reden om mijn geld terug te vragen',
						temp_id1_1_1
						)
					)) INTO temp_id1_1_1_1;

					PERFORM create_answer(
						'Ik heb mijn kosten al teruggevraagd, maar de reisaanbieder reageert niet.',
						temp_id1_1_1_1,
						(SELECT create_notification('Check verzekerd', 'check verzekerd'))
						);

					PERFORM create_answer(
						'Ik heb mijn kosten al teruggevraagd en ik ben in conflict met de reisaanbieder.',
						temp_id1_1_1_1,
						(SELECT create_notification('Check verzekerd', 'check verzekerd'))
						);

					PERFORM create_answer(
						'Ik heb nog geen contact gehad',
						temp_id1_1_1_1,
						(SELECT create_notification('Contact opnemen', 'Omdat u nog geen contact opgenomen heeft om uw geld terug te eisen, zal u dat eerst moeten doen. Kijk op de website van uw reisaanbieder of er een specifiek e-mailadres staat, stuurt u anders uw e-mail naar de klantenservice van uw reisaanbieder. Een e-mail sturen kunt u heel eenvoudig doen via de onderstaande 3 stappen: Stap 1. Kopieer de onderstaande tekst en plak deze in een nieuw e-mailbericht. Stap 2. Pas deze brief aan naar uw situatie. Stap 3. Stuur de gepersonaliseerde e-mail naar de reisaanbieder. Geachte heer/mevrouw, Op (voeg datum in) heb ik bij u een reis geboekt met vertrek op (voeg datum in) en retour op (voeg datum in). Het boekingsnummer is (voeg boekingsnummer in). Vanwege de onzekerheden rondom deze reis door de coronacrisis heeft u mij een voucher aangeboden ter compensatie. De voucher heeft een waarde van €(voeg bedrag in). Ik wil deze voucher echter niet accepteren, omdat (leg hier uit waarom u uw geld terug wilt). Op basis van de bovenstaande verzoek ik u binnen vier weken de waarde van de voucher naar mijn rekeningnummer (voeg IBAN nr. in) over te maken. Ik ontvang graag binnen 14 dagen uw reactie. Met vriendelijke groet, (voeg naam in)'))
						);

		SELECT create_question(1, 'Wat wordt uw besluit?', (
				SELECT create_answer(
					'TUI',
					temp_id1_1,
					(SELECT create_notification('Nederlandse reisaanbieder', 'U heeft een pakketreis bij een Nederlandse reisaanbieder geboekt. De pakketreisaanbieder heeft u een voucher aangeboden. U heeft nu 2 opties: Optie 1: De voucher accepteren Dit heeft twee voordelen: - Pakketreizen geboekt bij een Nederlandse reisaanbieder zijn beschermd door SGR. U hoeft zich geen zorgen te maken over uw voucher bij een faillissement van de reisaanbieder. - Uw voucher kunt u na 6 maanden omwisselen voor geld. Optie 2: Toch uw geld terugvragen U bent niet verplicht om een voucher te accepteren als de reisaanbieder de reis annuleert. U kunt dus ook uw geld terugvragen. Wel zijn er twee redenen waarom veel reizigers alsnog een voucher accepteren: 1. Indien u een verzoek doet tot omwisselen van de voucher voor geld, dan is op dat moment de overeenkomst formeel ontbonden. Het uitbetalen van de voucher kan maanden duren. Als de reisaanbieder in die periode failliet gaat, staat de SGR niet meer garant, omdat er formeel geen overeenkomst meer was. U zult dan zelf het geld moeten vorderen via een curator. Helaas heeft dit een niet zo grote kans, omdat Nederlands recht formeel andere crediteuren voor laat gaan.2. U zult een procedure moeten starten om uw geld van de reisaanbieder te ontvangen. Onze ervaring is dat deze procedure minimaal 9 maanden duurt voordat u uw geld terugkrijgt. Wilt u al eerder reizen met dezelfde reisaanbieder? Dan kunt u beter toch de voucher accepteren.'))
					)
				)) INTO temp_id1_1_1;

				PERFORM create_answer(
					'Ik accepteer mijn voucher',
					temp_id1_1_1,
					create_notification('Fijne dag', 'Goed om te horen, we wensen u nog een prettige dag.')
					);

				SELECT create_question(1, 'Heeft u al contact gehad?', (
					SELECT create_answer(
						'Ik heb een dringende reden om mijn geld terug te vragen',
						temp_id1_1_1
						)
					)) INTO temp_id1_1_1_1;

					PERFORM create_answer(
						'Ik heb mijn kosten al teruggevraagd, maar de reisaanbieder reageert niet.',
						temp_id1_1_1_1,
						(SELECT create_notification('Check verzekerd', 'check verzekerd'))
						);

					PERFORM create_answer(
						'Ik heb mijn kosten al teruggevraagd en ik ben in conflict met de reisaanbieder.',
						temp_id1_1_1_1,
						(SELECT create_notification('Check verzekerd', 'check verzekerd'))
						);

					PERFORM create_answer(
						'Ik heb nog geen contact gehad',
						temp_id1_1_1_1,
						(SELECT create_notification('Contact opnemen', 'Omdat u nog geen contact opgenomen heeft om uw geld terug te eisen, zal u dat eerst moeten doen. Kijk op de website van uw reisaanbieder of er een specifiek e-mailadres staat, stuurt u anders uw e-mail naar de klantenservice van uw reisaanbieder. Een e-mail sturen kunt u heel eenvoudig doen via de onderstaande 3 stappen: Stap 1. Kopieer de onderstaande tekst en plak deze in een nieuw e-mailbericht. Stap 2. Pas deze brief aan naar uw situatie. Stap 3. Stuur de gepersonaliseerde e-mail naar de reisaanbieder. Geachte heer/mevrouw, Op (voeg datum in) heb ik bij u een reis geboekt met vertrek op (voeg datum in) en retour op (voeg datum in). Het boekingsnummer is (voeg boekingsnummer in). Vanwege de onzekerheden rondom deze reis door de coronacrisis heeft u mij een voucher aangeboden ter compensatie. De voucher heeft een waarde van €(voeg bedrag in). Ik wil deze voucher echter niet accepteren, omdat (leg hier uit waarom u uw geld terug wilt). Op basis van de bovenstaande verzoek ik u binnen vier weken de waarde van de voucher naar mijn rekeningnummer (voeg IBAN nr. in) over te maken. Ik ontvang graag binnen 14 dagen uw reactie. Met vriendelijke groet, (voeg naam in)'))
						);

		SELECT create_question(1, 'Wat wordt uw besluit?', (
				SELECT create_answer(
					'Kras',
					temp_id1_1,
					(SELECT create_notification('Nederlandse reisaanbieder', 'U heeft een pakketreis bij een Nederlandse reisaanbieder geboekt. De pakketreisaanbieder heeft u een voucher aangeboden. U heeft nu 2 opties: Optie 1: De voucher accepteren Dit heeft twee voordelen: - Pakketreizen geboekt bij een Nederlandse reisaanbieder zijn beschermd door SGR. U hoeft zich geen zorgen te maken over uw voucher bij een faillissement van de reisaanbieder. - Uw voucher kunt u na 6 maanden omwisselen voor geld. Optie 2: Toch uw geld terugvragen U bent niet verplicht om een voucher te accepteren als de reisaanbieder de reis annuleert. U kunt dus ook uw geld terugvragen. Wel zijn er twee redenen waarom veel reizigers alsnog een voucher accepteren: 1. Indien u een verzoek doet tot omwisselen van de voucher voor geld, dan is op dat moment de overeenkomst formeel ontbonden. Het uitbetalen van de voucher kan maanden duren. Als de reisaanbieder in die periode failliet gaat, staat de SGR niet meer garant, omdat er formeel geen overeenkomst meer was. U zult dan zelf het geld moeten vorderen via een curator. Helaas heeft dit een niet zo grote kans, omdat Nederlands recht formeel andere crediteuren voor laat gaan.2. U zult een procedure moeten starten om uw geld van de reisaanbieder te ontvangen. Onze ervaring is dat deze procedure minimaal 9 maanden duurt voordat u uw geld terugkrijgt. Wilt u al eerder reizen met dezelfde reisaanbieder? Dan kunt u beter toch de voucher accepteren.'))
					)
				)) INTO temp_id1_1_1;

				PERFORM create_answer(
					'Ik accepteer mijn voucher',
					temp_id1_1_1,
					create_notification('Fijne dag', 'Goed om te horen, we wensen u nog een prettige dag.')
					);

				SELECT create_question(1, 'Heeft u al contact gehad?', (
					SELECT create_answer(
						'Ik heb een dringende reden om mijn geld terug te vragen',
						temp_id1_1_1
						)
					)) INTO temp_id1_1_1_1;

					PERFORM create_answer(
						'Ik heb mijn kosten al teruggevraagd, maar de reisaanbieder reageert niet.',
						temp_id1_1_1_1,
						(SELECT create_notification('Check verzekerd', 'check verzekerd'))
						);

					PERFORM create_answer(
						'Ik heb mijn kosten al teruggevraagd en ik ben in conflict met de reisaanbieder.',
						temp_id1_1_1_1,
						(SELECT create_notification('Check verzekerd', 'check verzekerd'))
						);

					PERFORM create_answer(
						'Ik heb nog geen contact gehad',
						temp_id1_1_1_1,
						(SELECT create_notification('Contact opnemen', 'Omdat u nog geen contact opgenomen heeft om uw geld terug te eisen, zal u dat eerst moeten doen. Kijk op de website van uw reisaanbieder of er een specifiek e-mailadres staat, stuurt u anders uw e-mail naar de klantenservice van uw reisaanbieder. Een e-mail sturen kunt u heel eenvoudig doen via de onderstaande 3 stappen: Stap 1. Kopieer de onderstaande tekst en plak deze in een nieuw e-mailbericht. Stap 2. Pas deze brief aan naar uw situatie. Stap 3. Stuur de gepersonaliseerde e-mail naar de reisaanbieder. Geachte heer/mevrouw, Op (voeg datum in) heb ik bij u een reis geboekt met vertrek op (voeg datum in) en retour op (voeg datum in). Het boekingsnummer is (voeg boekingsnummer in). Vanwege de onzekerheden rondom deze reis door de coronacrisis heeft u mij een voucher aangeboden ter compensatie. De voucher heeft een waarde van €(voeg bedrag in). Ik wil deze voucher echter niet accepteren, omdat (leg hier uit waarom u uw geld terug wilt). Op basis van de bovenstaande verzoek ik u binnen vier weken de waarde van de voucher naar mijn rekeningnummer (voeg IBAN nr. in) over te maken. Ik ontvang graag binnen 14 dagen uw reactie. Met vriendelijke groet, (voeg naam in)'))
						);

		SELECT create_question(1, 'Wat wordt uw besluit?', (
				SELECT create_answer(
					'De Vakantie discounter',
					temp_id1_1,
					(SELECT create_notification('Nederlandse reisaanbieder', 'U heeft een pakketreis bij een Nederlandse reisaanbieder geboekt. De pakketreisaanbieder heeft u een voucher aangeboden. U heeft nu 2 opties: Optie 1: De voucher accepteren Dit heeft twee voordelen: - Pakketreizen geboekt bij een Nederlandse reisaanbieder zijn beschermd door SGR. U hoeft zich geen zorgen te maken over uw voucher bij een faillissement van de reisaanbieder. - Uw voucher kunt u na 6 maanden omwisselen voor geld. Optie 2: Toch uw geld terugvragen U bent niet verplicht om een voucher te accepteren als de reisaanbieder de reis annuleert. U kunt dus ook uw geld terugvragen. Wel zijn er twee redenen waarom veel reizigers alsnog een voucher accepteren: 1. Indien u een verzoek doet tot omwisselen van de voucher voor geld, dan is op dat moment de overeenkomst formeel ontbonden. Het uitbetalen van de voucher kan maanden duren. Als de reisaanbieder in die periode failliet gaat, staat de SGR niet meer garant, omdat er formeel geen overeenkomst meer was. U zult dan zelf het geld moeten vorderen via een curator. Helaas heeft dit een niet zo grote kans, omdat Nederlands recht formeel andere crediteuren voor laat gaan.2. U zult een procedure moeten starten om uw geld van de reisaanbieder te ontvangen. Onze ervaring is dat deze procedure minimaal 9 maanden duurt voordat u uw geld terugkrijgt. Wilt u al eerder reizen met dezelfde reisaanbieder? Dan kunt u beter toch de voucher accepteren.'))
					)
				)) INTO temp_id1_1_1;

				PERFORM create_answer(
					'Ik accepteer mijn voucher',
					temp_id1_1_1,
					create_notification('Fijne dag', 'Goed om te horen, we wensen u nog een prettige dag.')
					);

				SELECT create_question(1, 'Heeft u al contact gehad?', (
					SELECT create_answer(
						'Ik heb een dringende reden om mijn geld terug te vragen',
						temp_id1_1_1
						)
					)) INTO temp_id1_1_1_1;

					PERFORM create_answer(
						'Ik heb mijn kosten al teruggevraagd, maar de reisaanbieder reageert niet.',
						temp_id1_1_1_1,
						(SELECT create_notification('Check verzekerd', 'check verzekerd'))
						);

					PERFORM create_answer(
						'Ik heb mijn kosten al teruggevraagd en ik ben in conflict met de reisaanbieder.',
						temp_id1_1_1_1,
						(SELECT create_notification('Check verzekerd', 'check verzekerd'))
						);

					PERFORM create_answer(
						'Ik heb nog geen contact gehad',
						temp_id1_1_1_1,
						(SELECT create_notification('Contact opnemen', 'Omdat u nog geen contact opgenomen heeft om uw geld terug te eisen, zal u dat eerst moeten doen. Kijk op de website van uw reisaanbieder of er een specifiek e-mailadres staat, stuurt u anders uw e-mail naar de klantenservice van uw reisaanbieder. Een e-mail sturen kunt u heel eenvoudig doen via de onderstaande 3 stappen: Stap 1. Kopieer de onderstaande tekst en plak deze in een nieuw e-mailbericht. Stap 2. Pas deze brief aan naar uw situatie. Stap 3. Stuur de gepersonaliseerde e-mail naar de reisaanbieder. Geachte heer/mevrouw, Op (voeg datum in) heb ik bij u een reis geboekt met vertrek op (voeg datum in) en retour op (voeg datum in). Het boekingsnummer is (voeg boekingsnummer in). Vanwege de onzekerheden rondom deze reis door de coronacrisis heeft u mij een voucher aangeboden ter compensatie. De voucher heeft een waarde van €(voeg bedrag in). Ik wil deze voucher echter niet accepteren, omdat (leg hier uit waarom u uw geld terug wilt). Op basis van de bovenstaande verzoek ik u binnen vier weken de waarde van de voucher naar mijn rekeningnummer (voeg IBAN nr. in) over te maken. Ik ontvang graag binnen 14 dagen uw reactie. Met vriendelijke groet, (voeg naam in)'))
						);

		SELECT create_question(1, 'Wat wordt uw besluit?', (
				SELECT create_answer(
					'Corendon',
					temp_id1_1,
					(SELECT create_notification('Nederlandse reisaanbieder', 'U heeft een pakketreis bij een Nederlandse reisaanbieder geboekt. De pakketreisaanbieder heeft u een voucher aangeboden. U heeft nu 2 opties: Optie 1: De voucher accepteren Dit heeft twee voordelen: - Pakketreizen geboekt bij een Nederlandse reisaanbieder zijn beschermd door SGR. U hoeft zich geen zorgen te maken over uw voucher bij een faillissement van de reisaanbieder. - Uw voucher kunt u na 6 maanden omwisselen voor geld. Optie 2: Toch uw geld terugvragen U bent niet verplicht om een voucher te accepteren als de reisaanbieder de reis annuleert. U kunt dus ook uw geld terugvragen. Wel zijn er twee redenen waarom veel reizigers alsnog een voucher accepteren: 1. Indien u een verzoek doet tot omwisselen van de voucher voor geld, dan is op dat moment de overeenkomst formeel ontbonden. Het uitbetalen van de voucher kan maanden duren. Als de reisaanbieder in die periode failliet gaat, staat de SGR niet meer garant, omdat er formeel geen overeenkomst meer was. U zult dan zelf het geld moeten vorderen via een curator. Helaas heeft dit een niet zo grote kans, omdat Nederlands recht formeel andere crediteuren voor laat gaan.2. U zult een procedure moeten starten om uw geld van de reisaanbieder te ontvangen. Onze ervaring is dat deze procedure minimaal 9 maanden duurt voordat u uw geld terugkrijgt. Wilt u al eerder reizen met dezelfde reisaanbieder? Dan kunt u beter toch de voucher accepteren.'))
					)
				)) INTO temp_id1_1_1;

				PERFORM create_answer(
					'Ik accepteer mijn voucher',
					temp_id1_1_1,
					(SELECT create_notification('Fijne dag', 'Goed om te horen, we wensen u nog een prettige dag.'))
					);

				SELECT create_question(1, 'Heeft u al contact gehad?', (
					SELECT create_answer(
						'Ik heb een dringende reden om mijn geld terug te vragen',
						temp_id1_1_1
						)
					)) INTO temp_id1_1_1_1;

					PERFORM create_answer(
						'Ik heb mijn kosten al teruggevraagd, maar de reisaanbieder reageert niet.',
						temp_id1_1_1_1,
						(SELECT create_notification('Check verzekerd', 'check verzekerd'))
						);

					PERFORM create_answer(
						'Ik heb mijn kosten al teruggevraagd en ik ben in conflict met de reisaanbieder.',
						temp_id1_1_1_1,
						(SELECT create_notification('Check verzekerd', 'check verzekerd'))
						);

					PERFORM create_answer(
						'Ik heb nog geen contact gehad',
						temp_id1_1_1_1,
						(SELECT create_notification('Contact opnemen', 'Omdat u nog geen contact opgenomen heeft om uw geld terug te eisen, zal u dat eerst moeten doen. Kijk op de website van uw reisaanbieder of er een specifiek e-mailadres staat, stuurt u anders uw e-mail naar de klantenservice van uw reisaanbieder. Een e-mail sturen kunt u heel eenvoudig doen via de onderstaande 3 stappen: Stap 1. Kopieer de onderstaande tekst en plak deze in een nieuw e-mailbericht. Stap 2. Pas deze brief aan naar uw situatie. Stap 3. Stuur de gepersonaliseerde e-mail naar de reisaanbieder. Geachte heer/mevrouw, Op (voeg datum in) heb ik bij u een reis geboekt met vertrek op (voeg datum in) en retour op (voeg datum in). Het boekingsnummer is (voeg boekingsnummer in). Vanwege de onzekerheden rondom deze reis door de coronacrisis heeft u mij een voucher aangeboden ter compensatie. De voucher heeft een waarde van €(voeg bedrag in). Ik wil deze voucher echter niet accepteren, omdat (leg hier uit waarom u uw geld terug wilt). Op basis van de bovenstaande verzoek ik u binnen vier weken de waarde van de voucher naar mijn rekeningnummer (voeg IBAN nr. in) over te maken. Ik ontvang graag binnen 14 dagen uw reactie. Met vriendelijke groet, (voeg naam in)'))
						);

		SELECT create_question(1, 'Wat wordt uw besluit?', (
				SELECT create_answer(
					'Prijsvrij.nl',
					temp_id1_1,
					(SELECT create_notification('Nederlandse reisaanbieder', 'U heeft een pakketreis bij een Nederlandse reisaanbieder geboekt. De pakketreisaanbieder heeft u een voucher aangeboden. U heeft nu 2 opties: Optie 1: De voucher accepteren Dit heeft twee voordelen: - Pakketreizen geboekt bij een Nederlandse reisaanbieder zijn beschermd door SGR. U hoeft zich geen zorgen te maken over uw voucher bij een faillissement van de reisaanbieder. - Uw voucher kunt u na 6 maanden omwisselen voor geld. Optie 2: Toch uw geld terugvragen U bent niet verplicht om een voucher te accepteren als de reisaanbieder de reis annuleert. U kunt dus ook uw geld terugvragen. Wel zijn er twee redenen waarom veel reizigers alsnog een voucher accepteren: 1. Indien u een verzoek doet tot omwisselen van de voucher voor geld, dan is op dat moment de overeenkomst formeel ontbonden. Het uitbetalen van de voucher kan maanden duren. Als de reisaanbieder in die periode failliet gaat, staat de SGR niet meer garant, omdat er formeel geen overeenkomst meer was. U zult dan zelf het geld moeten vorderen via een curator. Helaas heeft dit een niet zo grote kans, omdat Nederlands recht formeel andere crediteuren voor laat gaan.2. U zult een procedure moeten starten om uw geld van de reisaanbieder te ontvangen. Onze ervaring is dat deze procedure minimaal 9 maanden duurt voordat u uw geld terugkrijgt. Wilt u al eerder reizen met dezelfde reisaanbieder? Dan kunt u beter toch de voucher accepteren.'))
					)
				)) INTO temp_id1_1_1;

				PERFORM create_answer(
					'Ik accepteer mijn voucher',
					temp_id1_1_1,
					(SELECT create_notification('Fijne dag', 'Goed om te horen, we wensen u nog een prettige dag.'))
					);

				SELECT create_question(1, 'Heeft u al contact gehad?', (
					SELECT create_answer(
						'Ik heb een dringende reden om mijn geld terug te vragen',
						temp_id1_1_1
						)
					)) INTO temp_id1_1_1_1;

					PERFORM create_answer(
						'Ik heb mijn kosten al teruggevraagd, maar de reisaanbieder reageert niet.',
						temp_id1_1_1_1,
						(SELECT create_notification('Check verzekerd', 'check verzekerd'))
						);

					PERFORM create_answer(
						'Ik heb mijn kosten al teruggevraagd en ik ben in conflict met de reisaanbieder.',
						temp_id1_1_1_1,
						(SELECT create_notification('Check verzekerd', 'check verzekerd'))
						);

					PERFORM create_answer(
						'Ik heb nog geen contact gehad',
						temp_id1_1_1_1,
						(SELECT create_notification('Contact opnemen', 'Omdat u nog geen contact opgenomen heeft om uw geld terug te eisen, zal u dat eerst moeten doen. Kijk op de website van uw reisaanbieder of er een specifiek e-mailadres staat, stuurt u anders uw e-mail naar de klantenservice van uw reisaanbieder. Een e-mail sturen kunt u heel eenvoudig doen via de onderstaande 3 stappen: Stap 1. Kopieer de onderstaande tekst en plak deze in een nieuw e-mailbericht. Stap 2. Pas deze brief aan naar uw situatie. Stap 3. Stuur de gepersonaliseerde e-mail naar de reisaanbieder. Geachte heer/mevrouw, Op (voeg datum in) heb ik bij u een reis geboekt met vertrek op (voeg datum in) en retour op (voeg datum in). Het boekingsnummer is (voeg boekingsnummer in). Vanwege de onzekerheden rondom deze reis door de coronacrisis heeft u mij een voucher aangeboden ter compensatie. De voucher heeft een waarde van €(voeg bedrag in). Ik wil deze voucher echter niet accepteren, omdat (leg hier uit waarom u uw geld terug wilt). Op basis van de bovenstaande verzoek ik u binnen vier weken de waarde van de voucher naar mijn rekeningnummer (voeg IBAN nr. in) over te maken. Ik ontvang graag binnen 14 dagen uw reactie. Met vriendelijke groet, (voeg naam in)'))
						);

		SELECT create_question(1, 'Wat wordt uw besluit?', (
				SELECT create_answer(
					'VakantieXperts',
					temp_id1_1,
					(SELECT create_notification('Nederlandse reisaanbieder', 'U heeft een pakketreis bij een Nederlandse reisaanbieder geboekt. De pakketreisaanbieder heeft u een voucher aangeboden. U heeft nu 2 opties: Optie 1: De voucher accepteren Dit heeft twee voordelen: - Pakketreizen geboekt bij een Nederlandse reisaanbieder zijn beschermd door SGR. U hoeft zich geen zorgen te maken over uw voucher bij een faillissement van de reisaanbieder. - Uw voucher kunt u na 6 maanden omwisselen voor geld. Optie 2: Toch uw geld terugvragen U bent niet verplicht om een voucher te accepteren als de reisaanbieder de reis annuleert. U kunt dus ook uw geld terugvragen. Wel zijn er twee redenen waarom veel reizigers alsnog een voucher accepteren: 1. Indien u een verzoek doet tot omwisselen van de voucher voor geld, dan is op dat moment de overeenkomst formeel ontbonden. Het uitbetalen van de voucher kan maanden duren. Als de reisaanbieder in die periode failliet gaat, staat de SGR niet meer garant, omdat er formeel geen overeenkomst meer was. U zult dan zelf het geld moeten vorderen via een curator. Helaas heeft dit een niet zo grote kans, omdat Nederlands recht formeel andere crediteuren voor laat gaan.2. U zult een procedure moeten starten om uw geld van de reisaanbieder te ontvangen. Onze ervaring is dat deze procedure minimaal 9 maanden duurt voordat u uw geld terugkrijgt. Wilt u al eerder reizen met dezelfde reisaanbieder? Dan kunt u beter toch de voucher accepteren.'))
					)
				)) INTO temp_id1_1_1;

				PERFORM create_answer(
					'Ik accepteer mijn voucher',
					temp_id1_1_1,
					(SELECT create_notification('Fijne dag', 'Goed om te horen, we wensen u nog een prettige dag.'))
					);

				SELECT create_question(1, 'Heeft u al contact gehad?', (
					SELECT create_answer(
						'Ik heb een dringende reden om mijn geld terug te vragen',
						temp_id1_1_1
						)
					)) INTO temp_id1_1_1_1;

					PERFORM create_answer(
						'Ik heb mijn kosten al teruggevraagd, maar de reisaanbieder reageert niet.',
						temp_id1_1_1_1,
						(SELECT create_notification('Check verzekerd', 'check verzekerd'))
						);

					PERFORM create_answer(
						'Ik heb mijn kosten al teruggevraagd en ik ben in conflict met de reisaanbieder.',
						temp_id1_1_1_1,
						(SELECT create_notification('Check verzekerd', 'check verzekerd'))
						);

					PERFORM create_answer(
						'Ik heb nog geen contact gehad',
						temp_id1_1_1_1,
						(SELECT create_notification('Contact opnemen', 'Omdat u nog geen contact opgenomen heeft om uw geld terug te eisen, zal u dat eerst moeten doen. Kijk op de website van uw reisaanbieder of er een specifiek e-mailadres staat, stuurt u anders uw e-mail naar de klantenservice van uw reisaanbieder. Een e-mail sturen kunt u heel eenvoudig doen via de onderstaande 3 stappen: Stap 1. Kopieer de onderstaande tekst en plak deze in een nieuw e-mailbericht. Stap 2. Pas deze brief aan naar uw situatie. Stap 3. Stuur de gepersonaliseerde e-mail naar de reisaanbieder. Geachte heer/mevrouw, Op (voeg datum in) heb ik bij u een reis geboekt met vertrek op (voeg datum in) en retour op (voeg datum in). Het boekingsnummer is (voeg boekingsnummer in). Vanwege de onzekerheden rondom deze reis door de coronacrisis heeft u mij een voucher aangeboden ter compensatie. De voucher heeft een waarde van €(voeg bedrag in). Ik wil deze voucher echter niet accepteren, omdat (leg hier uit waarom u uw geld terug wilt). Op basis van de bovenstaande verzoek ik u binnen vier weken de waarde van de voucher naar mijn rekeningnummer (voeg IBAN nr. in) over te maken. Ik ontvang graag binnen 14 dagen uw reactie. Met vriendelijke groet, (voeg naam in)'))
						);

		SELECT create_question(1, 'Wat wordt uw besluit?', (
			SELECT create_answer(
				'Vacansoleil',
				temp_id1_1,
				(SELECT create_notification('Buitenlandse reisaanbieder', 'U heeft een pakketreis bij een Buitenlandse reisaanbieder geboekt die zich richt op de Nederlandse markt. De pakketreisaanbieder heeft u een voucher aangeboden. U heeft nu 2 opties: Optie 1: De voucher accepteren Dit heeft als voordeel dat een pakketreis geboekt bij een Nederlandse reisaanbieder beschermd is door SGR. U hoeft zich geen zorgen te maken over uw voucher bij een faillissement van de reisaanbieder. Optie 2: Uw geld terugvragen U bent niet verplicht om een voucher te accepteren als de reisaanbieder de reis annuleert. U kunt dus ook uw geld terugvragen. Wel is er een reden waarom veel reizigers alsnog een voucher accepteren: Na het annuleren van de reis bestaat er geen overeenkomst meer tussen u en de reisaanbieder. Als de reisaanbieder vervolgens failliet gaat omdat te veel mensen hun geld terug willen, staat SGR niet meer garant en komt uw vordering op de grote stapel terecht. Voor beide opties geldt: Autoriteit Consument & Markt heeft 25 maart 2020 bepaald dat reizigers in principe pas vanaf 6 maanden na ontvangst van de voucher kunnen verzoeken om teruggave van hun geld. Dit wordt op de website vermeld: "Als de consument uiteindelijk besluit geen gebruik te maken van de voucher, is de reisaanbieder die de voucher heeft verstrekt verplicht de volledige waarde terug te betalen uiterlijk aan het eind van de SGR-dekkingstermijn van één jaar na uitgifte, maar niet eerder dan na 6 maanden na de uitgifte van de voucher. De reisorganisatie mag hiervan in het voordeel van de consument afwijken.'))
				)
			)) INTO temp_id1_1_1;

			PERFORM create_answer(
				'Ik accepteer mijn voucher',
				temp_id1_1_1,
				(SELECT create_notification('Fijne dag', 'Goed om te horen, we wensen u nog een prettige dag'))
			);

			SELECT create_question(1, 'Heeft u al contact met de reisaanbieder gehad', (
				SELECT create_answer(
					'Ik begrijp het maar ik heb een dringende reden om toch mijn geld terug te vragen',
					temp_id1_1_1
					)
				)) INTO temp_id1_1_1_1;

				PERFORM create_answer(
					'Ik heb mijn kosten al teruggevraagd en maar de reisaanbieder reageert niet.',
					temp_id1_1_1_1,
					(SELECT create_notification('Check verzekerd', 'check verzekerd'))
					);

				PERFORM create_answer(
					'Ik heb mijn kosten al teruggevraagd en ik ben in conflict met de reisaanbieder.',
					temp_id1_1_1_1,
					(SELECT create_notification('Check verzekerd', 'check verzekerd'))
					);

				PERFORM create_answer(
					'Ik heb nog geen contact gehad',
					temp_id1_1_1_1,
					(SELECT create_notification('Contact opnemen', 'Omdat u nog geen contact opgenomen heeft om uw geld terug te eisen, zal u dat eerst moeten doen. Kijk op de website van uw reisaanbieder of er een specifiek e-mailadres staat, stuurt u anders uw e-mail naar de klantenservice van uw reisaanbieder. Een e-mail sturen kunt u heel eenvoudig doen via de onderstaande 3 stappen: Stap 1.Kopieer de onderstaande tekst en plak deze in een nieuw e-mailbericht. Stap 2. Pas deze brief aan naar uw situatie. Stap 3. Stuur de gepersonaliseerde e-mail naar de reisaanbieder. Geachte heer/mevrouw, Op (voeg datum in) heb ik bij u een reis geboekt met vertrek op (voeg datum in) en retour op (voeg datum in). Het boekingsnummer is (voeg boekingsnummer in). Vanwege de onzekerheden rondom deze reis door de coronacrisis heeft u mij een voucher aangeboden ter compensatie. De voucher heeft een waarde van €(voeg bedrag in). Ik wil deze voucher echter niet accepteren, omdat (leg hier uit waarom u uw geld terug wilt). Op basis van de bovenstaande verzoek ik u binnen vier weken de waarde van de voucher naar mijn rekeningnummer (voeg IBAN nr. in) over te maken. Ik ontvang graag binnen 14 dagen uw reactie. Met vriendelijke groet, (voeg naam in)'))
					);

		SELECT create_question(1, 'Wat wordt uw besluit?', (
			SELECT create_answer(
				'Alltours',
				temp_id1_1,
				(SELECT create_notification('Buitenlandse reisaanbieder', 'U heeft een pakketreis bij een Buitenlandse reisaanbieder geboekt die zich richt op de Nederlandse markt. De pakketreisaanbieder heeft u een voucher aangeboden. U heeft nu 2 opties: Optie 1: De voucher accepteren Dit heeft als voordeel dat een pakketreis geboekt bij een Nederlandse reisaanbieder beschermd is door SGR. U hoeft zich geen zorgen te maken over uw voucher bij een faillissement van de reisaanbieder. Optie 2: Uw geld terugvragen U bent niet verplicht om een voucher te accepteren als de reisaanbieder de reis annuleert. U kunt dus ook uw geld terugvragen. Wel is er een reden waarom veel reizigers alsnog een voucher accepteren: Na het annuleren van de reis bestaat er geen overeenkomst meer tussen u en de reisaanbieder. Als de reisaanbieder vervolgens failliet gaat omdat te veel mensen hun geld terug willen, staat SGR niet meer garant en komt uw vordering op de grote stapel terecht. Voor beide opties geldt: Autoriteit Consument & Markt heeft 25 maart 2020 bepaald dat reizigers in principe pas vanaf 6 maanden na ontvangst van de voucher kunnen verzoeken om teruggave van hun geld. Dit wordt op de website vermeld: "Als de consument uiteindelijk besluit geen gebruik te maken van de voucher, is de reisaanbieder die de voucher heeft verstrekt verplicht de volledige waarde terug te betalen uiterlijk aan het eind van de SGR-dekkingstermijn van één jaar na uitgifte, maar niet eerder dan na 6 maanden na de uitgifte van de voucher. De reisorganisatie mag hiervan in het voordeel van de consument afwijken.'))
				)
			)) INTO temp_id1_1_1;

			PERFORM create_answer(
				'Ik accepteer mijn voucher',
				temp_id1_1_1,
				(SELECT create_notification('Fijne dag', 'Goed om te horen, we wensen u nog een prettige dag'))
			);

			SELECT create_question(1, 'Heeft u al contact met de reisaanbieder gehad', (
				SELECT create_answer(
					'Ik begrijp het maar ik heb een dringende reden om toch mijn geld terug te vragen',
					temp_id1_1_1
					)
				)) INTO temp_id1_1_1_1;

				PERFORM create_answer(
					'Ik heb mijn kosten al teruggevraagd en maar de reisaanbieder reageert niet.',
					temp_id1_1_1_1,
					(SELECT create_notification('Check verzekerd', 'check verzekerd'))
					);

				PERFORM create_answer(
					'Ik heb mijn kosten al teruggevraagd en ik ben in conflict met de reisaanbieder.',
					temp_id1_1_1_1,
					(SELECT create_notification('Check verzekerd', 'check verzekerd'))
					);

				PERFORM create_answer(
					'Ik heb nog geen contact gehad',
					temp_id1_1_1_1,
					(SELECT create_notification('Contact opnemen', 'Omdat u nog geen contact opgenomen heeft om uw geld terug te eisen, zal u dat eerst moeten doen. Kijk op de website van uw reisaanbieder of er een specifiek e-mailadres staat, stuurt u anders uw e-mail naar de klantenservice van uw reisaanbieder. Een e-mail sturen kunt u heel eenvoudig doen via de onderstaande 3 stappen: Stap 1.Kopieer de onderstaande tekst en plak deze in een nieuw e-mailbericht. Stap 2. Pas deze brief aan naar uw situatie. Stap 3. Stuur de gepersonaliseerde e-mail naar de reisaanbieder. Geachte heer/mevrouw, Op (voeg datum in) heb ik bij u een reis geboekt met vertrek op (voeg datum in) en retour op (voeg datum in). Het boekingsnummer is (voeg boekingsnummer in). Vanwege de onzekerheden rondom deze reis door de coronacrisis heeft u mij een voucher aangeboden ter compensatie. De voucher heeft een waarde van €(voeg bedrag in). Ik wil deze voucher echter niet accepteren, omdat (leg hier uit waarom u uw geld terug wilt). Op basis van de bovenstaande verzoek ik u binnen vier weken de waarde van de voucher naar mijn rekeningnummer (voeg IBAN nr. in) over te maken. Ik ontvang graag binnen 14 dagen uw reactie. Met vriendelijke groet, (voeg naam in)'))
					);

		SELECT create_question(1, 'Wat wordt uw besluit?', (
			SELECT create_answer(
				'Novasol',
				temp_id1_1,
				(SELECT create_notification('Buitenlandse reisaanbieder', 'U heeft een pakketreis bij een Buitenlandse reisaanbieder geboekt die zich richt op de Nederlandse markt. De pakketreisaanbieder heeft u een voucher aangeboden. U heeft nu 2 opties: Optie 1: De voucher accepteren Dit heeft als voordeel dat een pakketreis geboekt bij een Nederlandse reisaanbieder beschermd is door SGR. U hoeft zich geen zorgen te maken over uw voucher bij een faillissement van de reisaanbieder. Optie 2: Uw geld terugvragen U bent niet verplicht om een voucher te accepteren als de reisaanbieder de reis annuleert. U kunt dus ook uw geld terugvragen. Wel is er een reden waarom veel reizigers alsnog een voucher accepteren: Na het annuleren van de reis bestaat er geen overeenkomst meer tussen u en de reisaanbieder. Als de reisaanbieder vervolgens failliet gaat omdat te veel mensen hun geld terug willen, staat SGR niet meer garant en komt uw vordering op de grote stapel terecht. Voor beide opties geldt: Autoriteit Consument & Markt heeft 25 maart 2020 bepaald dat reizigers in principe pas vanaf 6 maanden na ontvangst van de voucher kunnen verzoeken om teruggave van hun geld. Dit wordt op de website vermeld: "Als de consument uiteindelijk besluit geen gebruik te maken van de voucher, is de reisaanbieder die de voucher heeft verstrekt verplicht de volledige waarde terug te betalen uiterlijk aan het eind van de SGR-dekkingstermijn van één jaar na uitgifte, maar niet eerder dan na 6 maanden na de uitgifte van de voucher. De reisorganisatie mag hiervan in het voordeel van de consument afwijken.'))
				)
			)) INTO temp_id1_1_1;

			PERFORM create_answer(
				'Ik accepteer mijn voucher',
				temp_id1_1_1,
				(SELECT create_notification('Fijne dag', 'Goed om te horen, we wensen u nog een prettige dag'))
			);

			SELECT create_question(1, 'Heeft u al contact met de reisaanbieder gehad', (
				SELECT create_answer(
					'Ik begrijp het maar ik heb een dringende reden om toch mijn geld terug te vragen',
					temp_id1_1_1
					)
				)) INTO temp_id1_1_1_1;

				PERFORM create_answer(
					'Ik heb mijn kosten al teruggevraagd en maar de reisaanbieder reageert niet.',
					temp_id1_1_1_1,
					(SELECT create_notification('Check verzekerd', 'check verzekerd'))
					);

				PERFORM create_answer(
					'Ik heb mijn kosten al teruggevraagd en ik ben in conflict met de reisaanbieder.',
					temp_id1_1_1_1,
					(SELECT create_notification('Check verzekerd', 'check verzekerd'))
					);

				PERFORM create_answer(
					'Ik heb nog geen contact gehad',
					temp_id1_1_1_1,
					(SELECT create_notification('Contact opnemen', 'Omdat u nog geen contact opgenomen heeft om uw geld terug te eisen, zal u dat eerst moeten doen. Kijk op de website van uw reisaanbieder of er een specifiek e-mailadres staat, stuurt u anders uw e-mail naar de klantenservice van uw reisaanbieder. Een e-mail sturen kunt u heel eenvoudig doen via de onderstaande 3 stappen: Stap 1.Kopieer de onderstaande tekst en plak deze in een nieuw e-mailbericht. Stap 2. Pas deze brief aan naar uw situatie. Stap 3. Stuur de gepersonaliseerde e-mail naar de reisaanbieder. Geachte heer/mevrouw, Op (voeg datum in) heb ik bij u een reis geboekt met vertrek op (voeg datum in) en retour op (voeg datum in). Het boekingsnummer is (voeg boekingsnummer in). Vanwege de onzekerheden rondom deze reis door de coronacrisis heeft u mij een voucher aangeboden ter compensatie. De voucher heeft een waarde van €(voeg bedrag in). Ik wil deze voucher echter niet accepteren, omdat (leg hier uit waarom u uw geld terug wilt). Op basis van de bovenstaande verzoek ik u binnen vier weken de waarde van de voucher naar mijn rekeningnummer (voeg IBAN nr. in) over te maken. Ik ontvang graag binnen 14 dagen uw reactie. Met vriendelijke groet, (voeg naam in)'))
					);

		SELECT create_question(1, 'Wat wordt uw besluit?', (
			SELECT create_answer(
				'eDreams',
				temp_id1_1,
				(SELECT create_notification('Buitenlandse reisaanbieder', 'U heeft een pakketreis bij een Buitenlandse reisaanbieder geboekt die zich richt op de Nederlandse markt. De pakketreisaanbieder heeft u een voucher aangeboden. U heeft nu 2 opties: Optie 1: De voucher accepteren Dit heeft als voordeel dat een pakketreis geboekt bij een Nederlandse reisaanbieder beschermd is door SGR. U hoeft zich geen zorgen te maken over uw voucher bij een faillissement van de reisaanbieder. Optie 2: Uw geld terugvragen U bent niet verplicht om een voucher te accepteren als de reisaanbieder de reis annuleert. U kunt dus ook uw geld terugvragen. Wel is er een reden waarom veel reizigers alsnog een voucher accepteren: Na het annuleren van de reis bestaat er geen overeenkomst meer tussen u en de reisaanbieder. Als de reisaanbieder vervolgens failliet gaat omdat te veel mensen hun geld terug willen, staat SGR niet meer garant en komt uw vordering op de grote stapel terecht. Voor beide opties geldt: Autoriteit Consument & Markt heeft 25 maart 2020 bepaald dat reizigers in principe pas vanaf 6 maanden na ontvangst van de voucher kunnen verzoeken om teruggave van hun geld. Dit wordt op de website vermeld: "Als de consument uiteindelijk besluit geen gebruik te maken van de voucher, is de reisaanbieder die de voucher heeft verstrekt verplicht de volledige waarde terug te betalen uiterlijk aan het eind van de SGR-dekkingstermijn van één jaar na uitgifte, maar niet eerder dan na 6 maanden na de uitgifte van de voucher. De reisorganisatie mag hiervan in het voordeel van de consument afwijken.'))
				)
			)) INTO temp_id1_1_1;

			PERFORM create_answer(
				'Ik accepteer mijn voucher',
				temp_id1_1_1,
				(SELECT create_notification('Fijne dag', 'Goed om te horen, we wensen u nog een prettige dag'))
			);

			SELECT create_question(1, 'Heeft u al contact met de reisaanbieder gehad', (
				SELECT create_answer(
					'Ik begrijp het maar ik heb een dringende reden om toch mijn geld terug te vragen',
					temp_id1_1_1
					)
				)) INTO temp_id1_1_1_1;

				PERFORM create_answer(
					'Ik heb mijn kosten al teruggevraagd en maar de reisaanbieder reageert niet.',
					temp_id1_1_1_1,
					(SELECT create_notification('Check verzekerd', 'check verzekerd'))
					);

				PERFORM create_answer(
					'Ik heb mijn kosten al teruggevraagd en ik ben in conflict met de reisaanbieder.',
					temp_id1_1_1_1,
					(SELECT create_notification('Check verzekerd', 'check verzekerd'))
					);

				PERFORM create_answer(
					'Ik heb nog geen contact gehad',
					temp_id1_1_1_1,
					(SELECT create_notification('Contact opnemen', 'Omdat u nog geen contact opgenomen heeft om uw geld terug te eisen, zal u dat eerst moeten doen. Kijk op de website van uw reisaanbieder of er een specifiek e-mailadres staat, stuurt u anders uw e-mail naar de klantenservice van uw reisaanbieder. Een e-mail sturen kunt u heel eenvoudig doen via de onderstaande 3 stappen: Stap 1.Kopieer de onderstaande tekst en plak deze in een nieuw e-mailbericht. Stap 2. Pas deze brief aan naar uw situatie. Stap 3. Stuur de gepersonaliseerde e-mail naar de reisaanbieder. Geachte heer/mevrouw, Op (voeg datum in) heb ik bij u een reis geboekt met vertrek op (voeg datum in) en retour op (voeg datum in). Het boekingsnummer is (voeg boekingsnummer in). Vanwege de onzekerheden rondom deze reis door de coronacrisis heeft u mij een voucher aangeboden ter compensatie. De voucher heeft een waarde van €(voeg bedrag in). Ik wil deze voucher echter niet accepteren, omdat (leg hier uit waarom u uw geld terug wilt). Op basis van de bovenstaande verzoek ik u binnen vier weken de waarde van de voucher naar mijn rekeningnummer (voeg IBAN nr. in) over te maken. Ik ontvang graag binnen 14 dagen uw reactie. Met vriendelijke groet, (voeg naam in)'))
					);

		SELECT create_question(1, 'Is het een Nederlandse reisaanbieder', (
			SELECT create_answer(
				'Anders',
				temp_id1_1)
			)) INTO temp_id1_1_1;

			SELECT create_question(1, 'Wat wordt uw besluit?', (
				SELECT create_answer(
					'Ja',
					temp_id1_1_1,
					(SELECT create_notification('Nederlandse reisaanbieder', 'U heeft een pakketreis bij een Nederlandse reisaanbieder geboekt. De pakketreisaanbieder heeft u een voucher aangeboden. U heeft nu 2 opties: Optie 1: De voucher accepteren Dit heeft twee voordelen: - Pakketreizen geboekt bij een Nederlandse reisaanbieder zijn beschermd door SGR. U hoeft zich geen zorgen te maken over uw voucher bij een faillissement van de reisaanbieder. - Uw voucher kunt u na 6 maanden omwisselen voor geld. Optie 2: Toch uw geld terugvragen U bent niet verplicht om een voucher te accepteren als de reisaanbieder de reis annuleert. U kunt dus ook uw geld terugvragen. Wel zijn er twee redenen waarom veel reizigers alsnog een voucher accepteren: 1. Indien u een verzoek doet tot omwisselen van de voucher voor geld, dan is op dat moment de overeenkomst formeel ontbonden. Het uitbetalen van de voucher kan maanden duren. Als de reisaanbieder in die periode failliet gaat, staat de SGR niet meer garant, omdat er formeel geen overeenkomst meer was. U zult dan zelf het geld moeten vorderen via een curator. Helaas heeft dit een niet zo grote kans, omdat Nederlands recht formeel andere crediteuren voor laat gaan.2. U zult een procedure moeten starten om uw geld van de reisaanbieder te ontvangen. Onze ervaring is dat deze procedure minimaal 9 maanden duurt voordat u uw geld terugkrijgt. Wilt u al eerder reizen met dezelfde reisaanbieder? Dan kunt u beter toch de voucher accepteren.'))
					)
				)) INTO temp_id1_1_1_1;

				PERFORM create_answer(
					'Ik accepteer mijn voucher',
					temp_id1_1_1_1,
					create_notification('Fijne dag', 'Goed om te horen, we wensen u nog een prettige dag.')
					);

				SELECT create_question(1, 'Heeft u al contact gehad?', (
					SELECT create_answer(
						'Ik heb een dringende reden om mijn geld terug te vragen',
						temp_id1_1_1_1
						)
					)) INTO temp_id1_1_1_1_1;

					PERFORM create_answer(
						'Ik heb mijn kosten al teruggevraagd, maar de reisaanbieder reageert niet.',
						temp_id1_1_1_1_1,
						(SELECT create_notification('Check verzekerd', 'check verzekerd'))
						);

					PERFORM create_answer(
						'Ik heb mijn kosten al teruggevraagd en ik ben in conflict met de reisaanbieder.',
						temp_id1_1_1_1_1,
						(SELECT create_notification('Check verzekerd', 'check verzekerd'))
						);

					PERFORM create_answer(
						'Ik heb nog geen contact gehad',
						temp_id1_1_1_1_1,
						(SELECT create_notification('Contact opnemen', 'Omdat u nog geen contact opgenomen heeft om uw geld terug te eisen, zal u dat eerst moeten doen. Kijk op de website van uw reisaanbieder of er een specifiek e-mailadres staat, stuurt u anders uw e-mail naar de klantenservice van uw reisaanbieder. Een e-mail sturen kunt u heel eenvoudig doen via de onderstaande 3 stappen: Stap 1. Kopieer de onderstaande tekst en plak deze in een nieuw e-mailbericht. Stap 2. Pas deze brief aan naar uw situatie. Stap 3. Stuur de gepersonaliseerde e-mail naar de reisaanbieder. Geachte heer/mevrouw, Op (voeg datum in) heb ik bij u een reis geboekt met vertrek op (voeg datum in) en retour op (voeg datum in). Het boekingsnummer is (voeg boekingsnummer in). Vanwege de onzekerheden rondom deze reis door de coronacrisis heeft u mij een voucher aangeboden ter compensatie. De voucher heeft een waarde van €(voeg bedrag in). Ik wil deze voucher echter niet accepteren, omdat (leg hier uit waarom u uw geld terug wilt). Op basis van de bovenstaande verzoek ik u binnen vier weken de waarde van de voucher naar mijn rekeningnummer (voeg IBAN nr. in) over te maken. Ik ontvang graag binnen 14 dagen uw reactie. Met vriendelijke groet, (voeg naam in)'))
						);

			SELECT create_question(1, 'Was de website waarop u de pakketreis boekte Nederlandstalig, had deze een Nederlands adres of e-mailadres?', (
				SELECT create_answer(
					'Nee',
					temp_id1_1_1)
				)) INTO temp_id1_1_1_1;

				SELECT create_question(1, 'Wat wordt uw besluit?', (
			SELECT create_answer(
				'Ja',
				temp_id1_1_1_1,
				(SELECT create_notification('Buitenlandse reisaanbieder', 'U heeft een pakketreis bij een Buitenlandse reisaanbieder geboekt die zich richt op de Nederlandse markt. De pakketreisaanbieder heeft u een voucher aangeboden. U heeft nu 2 opties: Optie 1: De voucher accepteren Dit heeft als voordeel dat een pakketreis geboekt bij een Nederlandse reisaanbieder beschermd is door SGR. U hoeft zich geen zorgen te maken over uw voucher bij een faillissement van de reisaanbieder. Optie 2: Uw geld terugvragen U bent niet verplicht om een voucher te accepteren als de reisaanbieder de reis annuleert. U kunt dus ook uw geld terugvragen. Wel is er een reden waarom veel reizigers alsnog een voucher accepteren: Na het annuleren van de reis bestaat er geen overeenkomst meer tussen u en de reisaanbieder. Als de reisaanbieder vervolgens failliet gaat omdat te veel mensen hun geld terug willen, staat SGR niet meer garant en komt uw vordering op de grote stapel terecht. Voor beide opties geldt: Autoriteit Consument & Markt heeft 25 maart 2020 bepaald dat reizigers in principe pas vanaf 6 maanden na ontvangst van de voucher kunnen verzoeken om teruggave van hun geld. Dit wordt op de website vermeld: "Als de consument uiteindelijk besluit geen gebruik te maken van de voucher, is de reisaanbieder die de voucher heeft verstrekt verplicht de volledige waarde terug te betalen uiterlijk aan het eind van de SGR-dekkingstermijn van één jaar na uitgifte, maar niet eerder dan na 6 maanden na de uitgifte van de voucher. De reisorganisatie mag hiervan in het voordeel van de consument afwijken.'))
				)
			)) INTO temp_id1_1_1_1_1;

			PERFORM create_answer(
				'Ik accepteer mijn voucher',
				temp_id1_1_1,
				(SELECT create_notification('Fijne dag', 'Goed om te horen, we wensen u nog een prettige dag'))
			);

			SELECT create_question(1, 'Heeft u al contact met de reisaanbieder gehad', (
				SELECT create_answer(
					'Ik begrijp het maar ik heb een dringende reden om toch mijn geld terug te vragen',
					temp_id1_1_1_1_1
					)
				)) INTO temp_id1_1_1_1_1_1;

				PERFORM create_answer(
					'Ik heb mijn kosten al teruggevraagd en maar de reisaanbieder reageert niet.',
					temp_id1_1_1_1_1_1,
					(SELECT create_notification('Check verzekerd', 'check verzekerd'))
					);

				PERFORM create_answer(
					'Ik heb mijn kosten al teruggevraagd en ik ben in conflict met de reisaanbieder.',
					temp_id1_1_1_1_1_1,
					(SELECT create_notification('Check verzekerd', 'check verzekerd'))
					);

				PERFORM create_answer(
					'Ik heb nog geen contact gehad',
					temp_id1_1_1_1_1_1,
					(SELECT create_notification('Contact opnemen', 'Omdat u nog geen contact opgenomen heeft om uw geld terug te eisen, zal u dat eerst moeten doen. Kijk op de website van uw reisaanbieder of er een specifiek e-mailadres staat, stuurt u anders uw e-mail naar de klantenservice van uw reisaanbieder. Een e-mail sturen kunt u heel eenvoudig doen via de onderstaande 3 stappen: Stap 1.Kopieer de onderstaande tekst en plak deze in een nieuw e-mailbericht. Stap 2. Pas deze brief aan naar uw situatie. Stap 3. Stuur de gepersonaliseerde e-mail naar de reisaanbieder. Geachte heer/mevrouw, Op (voeg datum in) heb ik bij u een reis geboekt met vertrek op (voeg datum in) en retour op (voeg datum in). Het boekingsnummer is (voeg boekingsnummer in). Vanwege de onzekerheden rondom deze reis door de coronacrisis heeft u mij een voucher aangeboden ter compensatie. De voucher heeft een waarde van €(voeg bedrag in). Ik wil deze voucher echter niet accepteren, omdat (leg hier uit waarom u uw geld terug wilt). Op basis van de bovenstaande verzoek ik u binnen vier weken de waarde van de voucher naar mijn rekeningnummer (voeg IBAN nr. in) over te maken. Ik ontvang graag binnen 14 dagen uw reactie. Met vriendelijke groet, (voeg naam in)'))
					);

				PERFORM create_answer(
					'Nee',
					temp_id1_1_1_1_1_1,
					(SELECT create_notification('Check verzekerd', 'check verzekerd'))
				);

		SELECT create_question(1, 'Wat is uw situatie?', (
			SELECT create_answer(
				'Nee',
				temp_id1
				)
			 )) INTO temp_id1_1;
	
	
	
	SELECT create_question(1, 'Heeft u uw vliegtickets rechtstreeks bij een luchtvaartmaatschappij geboekt?', (	
		SELECT create_answer(
			'Vliegtickets (los geboekte vliegtickets)', 
			temp_id
			)
	)) INTO temp_id1;
	
	
	
	
	SELECT create_question(1, 'Wat is uw situatie?', (	
		SELECT create_answer(
			'Accommodatie en entertainment', 
			temp_id
	))) INTO temp_id1;
		
		PERFORM create_answer(
			'ik heb een voucher aangeboden gekregen maar ik wil mijn geld terug',
			temp_id1,
			(SELECT create_notification('Geld direct terug', 'U wilt uw geld terugvragen? Dat kan natuurlijk. Wel zijn er 2 redenen waarom veel klanten besluiten om alsnog de voucher te accepteren: 1. Om uw geld terug te vragen zult een procedure moeten starten. Dat is een langdurig traject. In onze ervaring kan het zeker 9 maanden duren voordat u uw geld terugkrijgt. Wilt u al eerder reizen met dezelfde reisorganisatie? Dan is het voor u gemakkelijker daar de voucher voor te gebruiken. 2. De voucher is na 12 maanden om te wisselen voor geld. Als u deze termijn afwacht, bespaart u zichzelf veel tijd, energie en eventuele extra proceskosten.'))
		);
		
		PERFORM create_answer(
			'Ik heb een conflict over omboekingskosten',
			temp_id1,
			(SELECT create_notification('Check verzekerd', 'check verzekerd'))
		);
		
		SELECT create_question(1, 'Bent u met dit antwoord geholpen?',
			(SELECT create_answer(
				'ik heb een conflict over het annuleren van de accommodatie',
				temp_id1,
				(SELECT create_notification('Check verzekerd', 'check verzekerd'))
			))) INTO temp_id1_1;
		
			PERFORM create_answer(
				'Ja',
				temp_id1_1,
				(SELECT create_notification('Fijne dag', 'Goed om te horen, we wensen u nog een prettige dag.'))
			);
		
			SELECT create_question(1, 'Heeft u al contact gehad met de reisorganisatie',
				(SELECT create_answer(
					'Nee, ik wil toch mijn geld terugvragen',
					temp_id1_1
				))) INTO temp_id1_1_1;
		
				PERFORM create_answer(
					'Ik heb nog geen contact gehad',
					temp_id1_1_1,
					(SELECT create_notification('Contact opnemen', 'Omdat u nog geen contact opgenomen heeft om uw geld terug te eisen, zal u dat eerst moeten doen. Kijk op de website van uw reisaanbieder of er een specifieke e-mailadres staat, stuurt u anders uw e-mail naar de klantenservice van uw reisaanbieder. Een e-mail sturen kunt u heel eenvoudig doen via de onderstaande 3 stappen: Stap 1. Kopieer de onderstaande tekst en plak deze in een nieuw e-mailbericht. Stap 2. Pas deze brief waar nodig aan naar uw situatie. Stap 3. Stuur de gepersonaliseerde e-mail naar de reisaanbieder. Geachte heer/mevrouw, Op (voeg datum in) heb ik bij u een reis geboekt met vertrek op (voeg datum in) en retour op (voeg datum in). Het boekingsnummer is (voeg boekingsnummer in). Vanwege de onzekerheden rondom deze reis door de coronacrisis heeft u mij een voucher aangeboden ter compensatie. De voucher heeft een waarde van €(voeg bedrag in). Ik wil deze voucher echter niet accepteren, omdat (leg hier uit waarom u uw geld terug wilt). Op basis van de bovenstaande verzoek ik u binnen vier weken de waarde van de voucher naar mijn rekeningnummer (voeg IBAN nr. in) over te maken.'))
				);
				
				PERFORM create_answer(
					'Ik heb mijn kosten al teruggevraagd en ik ben in conflict met de reisaanbieder.',
					temp_id1_1_1,
					(SELECT create_notification('Check verzekerd', 'check verzekerd'))
				);
				
				PERFORM create_answer(
					'Ik heb mijn kosten al teruggevraagd maar de reisaanbieder reageert niet.',
					temp_id1_1_1,
					(SELECT create_notification('Check verzekerd', 'check verzekerd'))
				);
	
		SELECT create_question(1, 'Heeft u al contact met de reisaanbieder gehad',
			(SELECT create_answer(
				'de accommodatie biedt niet alle faciliteiten aan',
				temp_id1
			))) INTO temp_id1_1;
	
			PERFORM create_answer(
				'Ja ik heb contact gehad',
				temp_id1_1,
				(SELECT create_notification('Check verzekerd', 'check verzekerd'))
			);
			
			PERFORM create_answer(
				'Ik heb nog geen contact gehad',
				temp_id1_1,
				(SELECT create_notification('Beleid bij reisaanbieder', 'Om te bepalen welke vervolgstappen u kunt nemen, is het belangrijk om te weten wat het beleid is van uw reisaanbieder. Wij raden u dan ook aan om hierover contact op te nemen. U kunt dit doen via de onderstaande 3 stappen: Stap 1. Kopieer de onderstaande tekst en plak deze in een nieuw e-mailbericht. Stap 2. Pas deze brief aan naar uw situatie. Stap 3. Stuur de gepersonaliseerde e-mail naar de reisaanbieder. Geachte heer/mevrouw, Op (voeg datum in) heb ik bij u een accommodatie geboekt met vertrek op (voeg datum in) en retour op (voeg datum in). Het boekingsnummer is (voeg boekingsnummer in). Vanwege Corona zijn niet alle faciliteiten beschikbaar, waarvoor ik deze accommodatie wel geboekt heb. <kort aangeven welke faciliteiten u bedoeld>Ik wil graag weten welke alternatieven u mij kunt bieden. Of per wanneer de betreffende faciliteiten weer geopend zijn. Graag hoor ik per omgaande van u, zodat ik een keuze kan maken om uw voorstel te accepteren of de reis kosteloos te annuleren. Met vriendelijke groet,(voeg naam in)'))
			);
	
		SELECT create_question(1, 'Heeft u al contact met de reisaanbieder gehad?',
			(SELECT create_answer(
				'Anders',
				temp_id1
			))) INTO temp_id1_1;
	
			PERFORM create_answer(
				'Ja ik heb contact gehad',
				temp_id1_1,
				(SELECT create_notification('Check verzekerd', 'check verzekerd'))
			);
			
			PERFORM create_answer(
				'Ik heb nog geen contact gehad',
				temp_id1_1,
				(SELECT create_notification('Contact stappenplan', 'Heeft u nog geen contact opgenomen? Doe dit dan als eerste. Dit kunt u eenvoudig zelf doen in de volgende 3 stappen: Stap 1. Kopieer de onderstaande tekst en plak deze in een nieuw e-mailbericht. Stap 2. Pas deze brief aan naar uw situatie. Stap 3. Stuur de gepersonaliseerde e-mail naar de reisaanbieder. Geachte heer/mevrouw, Op (voeg datum in) heb ik bij u een accommodatie geboekt met vertrek op (voeg datum in) en retour op (voeg datum in). Het boekingsnummer is (voeg boekingsnummer in). [voeg hier uw vraag voor de organisatie toe] Graag hoor ik van u binnen 14 dagen hoe het beleid van uw organisatie zich tot de huidige coronacrisis verhoudt. Met vriendelijke groet, (voeg naam in)')
			));
			
	
	SELECT create_question(1, 'Heeft u al contact gehad met de reisorganisatie?', (
		SELECT create_answer(
			'Mijn optie staat er niet bij', 
			temp_id
	))) INTO temp_id1;
	
		PERFORM create_answer(
			'Ik heb nog geen contact gehad',
			temp_id1,
			(SELECT create_notification('Voorwaarden reisaanbieder', 'Wilt u uw vakantie annuleren, is er geen negatief reisadvies en bent u niet ziek? Dan kunt u alleen onder de voorwaarden van de reisaanbieder annuleren. De huidige situatie kan natuurlijk nog veranderen. Daarom kunt u indien mogelijk het beste nog even wachten met annuleren, want het is mogelijk dat reisorganisatie zelf alsnog annuleert.U kunt wel alvast de organisatie vragen wat de mogelijkheden zijn en de annuleringsvoorwaarden van uw reisaanbieder controleren.'))
		);
		
		PERFORM create_answer(
			'Ik heb mijn kosten al teruggevraagd en ik ben in conflict met de reisaanbieder.',
			temp_id1,
			(SELECT create_notification('Check verzekerd', 'check verzekerd'))
		);
		
		PERFORM create_answer(
			'Ik heb mijn kosten al teruggevraagd maar de reisaanbieder reageert niet.',
			temp_id1,
			(SELECT create_notification('Check verzekerd', 'check verzekerd'))
		);
	
END;
$$;

UPDATE tree
SET user_id = 1
WHERE id > 0;

UPDATE question
SET type_id = 1,
	tree_id = (SELECT id FROM tree)
WHERE id > 0;

-- TRUNCATE TABLE answer CASCADE;
-- TRUNCATE TABLE notification CASCADE;
-- TRUNCATE TABLE question CASCADE;
-- TRUNCATE TABLE tree CASCADE;
-- TRUNCATE TABLE tree_version CASCADE;

-- SELECT * FROM question;
-- SELECT * FROM answer;
-- SELECT * FROM tree;
-- SELECT * FROM tree_version;

-- DROP TABLE answer CASCADE;
-- DROP TABLE notification CASCADE;
-- DROP TABLE question CASCADE;
-- DROP TABLE tree CASCADE;
-- DROP TABLE tree_version CASCADE;
-- DROP TABLE account CASCADE;
-- DROP TABLE question_type CASCADE;