-- etape de INNER JOIN :
-- On va  lie les 5 tables pour remonter de l'examen jusqu'au titre du cours .

SELECT 
    app.nom AS nom_etudiant, 
    lec.titre AS intitule_cours, 
    epr.date_examen, 
    epr.score
FROM examen AS epr
INNER JOIN inscription AS ins ON epr.inscription_id = ins.id
INNER JOIN etudiant AS app ON ins.etudiant_id = app.id
INNER JOIN enseignement AS ens ON ins.enseignement_id = ens.id
INNER JOIN cours AS lec ON ens.cours_id = lec.id;

--  etape deLEFT JOIN 
-- L'utilisation de COUNT(epr.id) il  permetre  d'afficher 0 pour lesétudiants sans examen .
SELECT 
    app.nom, 
    COUNT(epr.id) AS total_examens_realises
FROM etudiant AS app
LEFT JOIN inscription AS ins ON app.id = ins.etudiant_id
LEFT JOIN examen AS epr ON ins.id = epr.inscription_id
GROUP BY app.id, app.nom;


-- etape de RIGHT JOIN
-- On parti  des cours pour s'assurer que même ceux sans inscrits apparaissent
SELECT 
    lec.titre, 
    COUNT(ins.id) AS nombre_etudiants_inscrits
FROM inscription AS ins
JOIN enseignement AS ens ON ins.enseignement_id = ens.id
RIGHT JOIN cours AS lec ON ens.cours_id = lec.id
GROUP BY lec.id, lec.titre;



-- etape de CROSS JOIN : Matrice Étudiant-Professeur :
SELECT 
    app.nom AS etudiant, 
    prof.nom AS professeur
FROM etudiant AS app
CROSS JOIN professeur AS prof
LIMIT 20;




-- etape de Création de Vue : vue-performances
CREATE OR REPLACE VIEW vue_performances AS
SELECT 
    app.id AS etudiant_id, 
    app.nom, 
    AVG(epr.score) AS moyenne_score
FROM etudiant AS app
LEFT JOIN inscription AS ins ON app.id = ins.etudiant_id
LEFT JOIN examen AS epr ON ins.id = epr.inscription_id
GROUP BY app.id, app.nom;

---------------------------------------
--  etape de Common Table Expression (CTE):
-- des 3 enseignements les mieux notés sont affichage final
WITH top_cours AS (
    SELECT 
        c.id,
        AVG(ex.score) AS score_moyen_global
    FROM cours c
    JOIN enseignement ens ON c.id = ens.cours_id
    JOIN inscription ins ON ens.id = ins.enseignement_id
    JOIN examen ex ON ins.id = ex.inscription_id
    GROUP BY c.id
    ORDER BY score_moyen_global DESC
    LIMIT 3
)
SELECT 
    c.titre, 
    c.credits, 
    tc.score_moyen_global AS moyenne_score
FROM cours c
INNER JOIN top_cours tc ON c.id = tc.id;