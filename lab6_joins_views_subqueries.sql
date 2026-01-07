use bibliotheque; 

 desc emprunt;
SELECT e.ouvrage_id, a.nom, e.date_debut
FROM emprunt e
INNER JOIN abonne a ON e.abonne_id = a.id;

 SELECT * FROM emprunt e 
 INNER JOIN abonne a ON e.abonne_id = a.id 
 LIMIT 10;

SELECT o.titre, MAX(e.date_debut) AS dernier_emprunt
FROM ouvrage o
LEFT JOIN emprunt e 
  ON e.ouvrage_id = o.id
GROUP BY o.id, o.titre;

SELECT a.nom AS abonne, au.nom AS auteur
FROM abonne a
CROSS JOIN auteur au;


CREATE VIEW vue_emprunts_par_abonne AS
SELECT a.id, a.nom, COUNT(e.ouvrage_id) AS total_emprunts
FROM abonne a
LEFT JOIN emprunt e 
  ON e.abonne_id = a.id
GROUP BY a.id, a.nom;


SELECT * 
FROM vue_emprunts_par_abonne
WHERE total_emprunts > 5;

DROP VIEW vue_emprunts_par_abonne;


SELECT 
  titre,
  (SELECT COUNT(*) 
   FROM emprunt e 
   WHERE e.ouvrage_id = o.id
  ) AS nb_emprunts
FROM ouvrage o;


SELECT nom, email
FROM abonne
WHERE id IN (
  SELECT abonne_id
  FROM emprunt
  GROUP BY abonne_id
  HAVING COUNT(*) > 3
);



SELECT a.nom,
  (SELECT o.titre 
   FROM emprunt e2 
   JOIN ouvrage o ON e2.ouvrage_id = o.id
   WHERE e2.abonne_id = a.id
   ORDER BY e2.date_debut
   LIMIT 1
  ) AS premier_titre
FROM abonne a;

CREATE VIEW vue_emprunts_mensuels AS
SELECT 
  YEAR(date_debut) AS annee,
  MONTH(date_debut) AS mois,
  COUNT(*) AS total_emprunts
FROM emprunt
GROUP BY annee, mois;



SELECT v.annee, v.mois, v.total_emprunts
FROM vue_emprunts_mensuels v
WHERE v.total_emprunts = (
  SELECT MAX(total_emprunts)
  FROM vue_emprunts_mensuels
  WHERE annee = v.annee
);

-- Exercice 1 :
select * from auteur;
INSERT INTO auteur (nom) VALUES ('Ayman Sakyoud');

SELECT at.nom AS nom_auteur
FROM auteur AS at
LEFT JOIN ouvrage AS ov ON at.id = ov.auteur_id
WHERE ov.id IS NULL;

-- Exercice 2 :

CREATE OR REPLACE VIEW vue_mensuelle_activite AS
SELECT 
    DATE_FORMAT(emp.date_debut, '%Y-%m') AS mois,
    COUNT(DISTINCT emp.abonne_id) AS nombre_visiteurs
FROM emprunt AS emp
GROUP BY mois;

SELECT * FROM vue_mensuelle_activite;


-- Exerice 3 :

SELECT
livre.titre,
(SELECT abo.nom 
	FROM emprunt AS histo
	JOIN abonne AS abo ON histo.abonne_id = abo.id
	WHERE histo.ouvrage_id = livre.id
	ORDER BY histo.date_debut DESC
	LIMIT 1
    ) AS nom_dernier_lecteur
FROM ouvrage AS livre;