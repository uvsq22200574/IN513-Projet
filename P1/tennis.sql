
-- Création des tables
CREATE TABLE Joueur(
	nom varchar(30) NOT NULL,
	prenom varchar(30) NOT NULL,
	age int NOT NULL,
	nationalite varchar(30) NOT NULL,
	PRIMARY KEY (nom)
);

CREATE TABLE Rencontre(
	nomgagnant varchar(30) NOT NULL,
	nomperdant varchar(30) NOT NULL,
	tournoi varchar(30) NOT NULL,
	annee int NOT NULL,
	score varchar(30) NOT NULL,
	PRIMARY KEY (nomgagnant, nomperdant, tournoi, annee),
	FOREIGN KEY (nomgagnant) REFERENCES Joueur (nom),
	FOREIGN KEY (nomperdant) REFERENCES Joueur (nom)
);

-- Pour que la contrainte de clé étrangère ait un nom (utile pour la supprimer plus tard avec ALTER TABLE)
-- il faut utiliser CONSTRAINT maCleEtangere FOREIGN KEY (nomgagnant) REFERENCES Joueur(nom)

CREATE TABLE Sponsor(
	nom varchar(30) NOT NULL,
	tournoi varchar(30) NOT NULL,
	annee int NOT NULL,
	montant int NOT NULL,
	PRIMARY KEY (nom, tournoi, annee)
);

CREATE TABLE Gain(
	nomjoueur varchar(30) NOT NULL,
	nomsponsor varchar(30) NOT NULL,
	tournoi varchar(30) NOT NULL,
	annee int NOT NULL,
	rang int NOT NULL,
	prime int NOT NULL,
	PRIMARY KEY(nomjoueur, tournoi, annee),
	FOREIGN KEY(nomjoueur) REFERENCES Joueur(nom),
	FOREIGN KEY(nomsponsor, tournoi, annee) REFERENCES Sponsor(nom, tournoi, annee) 
);

-- Insertions des tuples
INSERT INTO Joueur VALUES ('Federer', 'Roger', 38, 'Suisse');
INSERT INTO Joueur VALUES ('Nadal', 'Rafael', 33, 'Espagnole');
INSERT INTO Joueur VALUES ('Djokovic', 'Novak', 32, 'Serbe');
INSERT INTO Joueur VALUES ('Murray', 'Andy', 32, 'Anglaise');
INSERT INTO Joueur VALUES ('Soederling', 'Robin', 35, 'Suedoise');
INSERT INTO Joueur VALUES ('Berdych', 'Tomas', 34, 'Tcheque');

INSERT INTO Sponsor VALUES ('Peugeot', 'Roland-Garros', 2010, 6000000);
INSERT INTO Sponsor VALUES ('Peugeot', 'Roland-Garros', 2011, 1500000);
INSERT INTO Sponsor VALUES ('Wilson', 'US Open', 2010, 1500000);
INSERT INTO Sponsor VALUES ('Wilson', 'US Open', 2011, 1500000);
INSERT INTO Sponsor VALUES ('IBM', 'Open Australie', 2010, 40000000);
INSERT INTO Sponsor VALUES ('IBM', 'Open Australie', 2011, 1500000);
INSERT INTO Sponsor VALUES ('BNP-Paribas', 'Wimbledon', 2010, 1500000);
INSERT INTO Sponsor VALUES ('BNP-Paribas', 'Wimbledon', 2011, 1500000);

INSERT INTO Rencontre VALUES ('Federer', 'Murray', 'Open Australie', 2010, '6/3-6/4-7/6');
INSERT INTO Rencontre VALUES ('Nadal', 'Soederling', 'Roland-Garros', 2010, '6/4-6/2-6/4');
INSERT INTO Rencontre VALUES ('Nadal', 'Berdych', 'Wimbledon', 2010, '6/3-7/5-6/4');
INSERT INTO Rencontre VALUES ('Nadal', 'Djokovic', 'US Open', 2010, '6/4-5/7-6/4-6/2');
INSERT INTO Rencontre VALUES ('Djokovic', 'Murray', 'Open Australie', 2011, '6/4-6/2-6/3');
INSERT INTO Rencontre VALUES ('Nadal', 'Federer', 'Roland-Garros', 2011, '7/5-7/6-5/7-6/1');
INSERT INTO Rencontre VALUES ('Djokovic', 'Nadal', 'Wimbledon', 2011, '6/4-6/1-1/6-6/3');
INSERT INTO Rencontre VALUES ('Djokovic', 'Nadal', 'US Open', 2011, '6/2-6/4-6/7-6/1');

INSERT INTO Gain VALUES ('Federer', 'IBM', 'Open Australie', 2010, 1, 1000000);
INSERT INTO Gain VALUES('Murray', 'IBM', 'Open Australie', 2010, 2, 500000);
INSERT INTO Gain VALUES('Nadal', 'Peugeot', 'Roland-Garros', 2010, 1, 1000000);
INSERT INTO Gain VALUES('Soederling', 'Peugeot', 'Roland-Garros', 2010, 2, 500000);
INSERT INTO Gain VALUES('Nadal', 'BNP-Paribas', 'Wimbledon', 2010, 1, 1000000);
INSERT INTO Gain VALUES('Berdych', 'BNP-Paribas', 'Wimbledon', 2010, 2, 500000);
INSERT INTO Gain VALUES('Nadal', 'Wilson', 'US Open', 2010, 1, 1000000);
INSERT INTO Gain VALUES('Djokovic', 'Wilson', 'US Open', 2010, 2, 500000);
INSERT INTO Gain VALUES('Djokovic', 'IBM', 'Open Australie', 2011, 1, 1000000);
INSERT INTO Gain VALUES('Murray', 'IBM', 'Open Australie', 2011, 2, 500000);
INSERT INTO Gain VALUES('Nadal', 'Peugeot', 'Roland-Garros', 2011, 1, 1000000);
INSERT INTO Gain VALUES('Federer', 'Peugeot', 'Roland-Garros', 2011, 2, 500000);
INSERT INTO Gain VALUES('Djokovic', 'BNP-Paribas', 'Wimbledon', 2011, 1, 1000000);
INSERT INTO Gain VALUES('Nadal', 'BNP-Paribas', 'Wimbledon', 2011, 2, 500000);
INSERT INTO Gain VALUES('Djokovic', 'Wilson', 'US Open', 2011, 1, 1000000);
INSERT INTO Gain VALUES('Nadal', 'Wilson', 'US Open', 2011, 2, 500000);

-- Requêtes d'interrogation
-- a)
SELECT nom, prenom
FROM Joueur
WHERE prenom='Roger';

-- b)
SELECT distinct annee
FROM Rencontre
WHERE tournoi='Roland-Garros';

-- c)
SELECT distinct nom, age
FROM Joueur JOIN Gain ON nom=nomjoueur
WHERE rang=1 AND tournoi='Roland-Garros';

SELECT distinct nom, age
FROM Joueur, Gain 
WHERE rang=1
AND nom=nomjoueur
AND tournoi='Roland-Garros';
-- d)
SELECT distinct nom
FROM Sponsor
WHERE tournoi='Roland-Garros';

-- e)
SELECT nom, prenom
FROM Gain JOIN Joueur on nomjoueur=nom
WHERE nomsponsor='BNP-Paribas' AND rang=1;

-- f)
SELECT nom
FROM Joueur J
WHERE EXISTS (
	SELECT *
	FROM Rencontre R
	WHERE R.nomgagnant=J.nom OR R.nomperdant=J.nom
);

SELECT distinct nom
FROM Joueur J, Rencontre R
WHERE R.nomgagnant=J.nom OR R.nomperdant=J.nom
);
-- g)
SELECT nom
FROM Joueur J
WHERE EXISTS (
	SELECT *
	FROM Rencontre R
	WHERE (R.nomgagnant=J.nom OR R.nomperdant=J.nom) AND tournoi='Wimbledon'
);

-- h)
SELECT nom
FROM Joueur J
WHERE NOT EXISTS (
	SELECT *
	FROM Rencontre R
	WHERE R.nomperdant=J.nom
);

-- i)
SELECT distinct nom
FROM Joueur J
WHERE NOT EXISTS (
	SELECT *
	FROM Gain G
	WHERE G.nomjoueur=J.nom AND prime < 1000000
);

-- j)
SELECT count(*) as nbmatchs
FROM Rencontre
WHERE tournoi='Open Australie';

-- k)
SELECT nomjoueur, sum(prime) as gaintotal
FROM Gain
WHERE nomjoueur='Nadal';


SELECT nomjoueur, sum(prime) as gaintotal
FROM Gain
group by nomjoueur;

-- l)
SELECT nomjoueur, SUM(prime) as gaintotal
FROM Gain
GROUP BY nomjoueur
HAVING SUM(prime)>2000000;

-- m)
SELECT tournoi, annee
FROM Sponsor S
WHERE montant > (
	SELECT SUM(prime)
	FROM Gain G
	WHERE S.tournoi=G.tournoi AND S.annee=G.annee
);

-- 4.a)
ALTER TABLE Joueur
ADD (taille int);

ALTER TABLE Rencontre
ADD (stade varchar(30));


-- e)

UPDATE Sponsor
SET nom = UPPER(nom);

UPDATE Rencontre
SET tournoi = LOWER(tournoi)
WHERE annee < 2011;
UPDATE Sponsor
SET tournoi = LOWER(tournoi)
WHERE annee < 2011;
UPDATE Gain
SET tournoi = LOWER(tournoi)
WHERE annee < 2011;

UPDATE Joueur
SET age = age + 1;


DELETE FROM Rencontre
WHERE (nomgagnant='Federer' OR nomperdant='Federer') AND tournoi='Open Australie' AND annee = 2010;

-- 5.
CREATE VIEW Joueurs_Francais AS
SELECT nom, prenom, age
FROM Joueur
WHERE nationalite = 'francaise';