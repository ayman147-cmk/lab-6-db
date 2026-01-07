-- la creation de shema :
CREATE DATABASE IF NOT EXISTS universite 
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE universite;

CREATE TABLE etudiant (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO etudiant (id, nom, email) VALUES (1, 'ayman', 'ayman@gmail.com'),(2, 'ali', 'ali@gmail.com');
select * from etudiant;

CREATE TABLE professeur (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    departement VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO professeur (id, nom, email, departement) VALUES (1, 'Mohammed', 'mohammed@gmail.com', 'IA'),
(2, 'Abdelaali', 'abdelaali@gmail.com', 'Web');
select * from professeur;

CREATE TABLE cours (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titre VARCHAR(200) NOT NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    credits INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO cours (id, titre, code, credits) VALUES (1, 'Oracle', 'mfbk9350', 5),(2, 'uml', 'classe', 7);
select * from cours;
-- 
CREATE TABLE enseignement (
    id INT AUTO_INCREMENT PRIMARY KEY, 
    cours_id INT NOT NULL,
    professeur_id INT, 
    semestre VARCHAR(20),
    CONSTRAINT fk_cours_ref FOREIGN KEY (cours_id) REFERENCES cours(id) ON DELETE CASCADE,
    CONSTRAINT fk_prof_ref FOREIGN KEY (professeur_id) REFERENCES professeur(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO enseignement (id, cours_id, professeur_id, semestre) VALUES (1, 1, 1, 'semestre-1'),(2, 2, 2, 'semestre-2');
select * from enseignement;

CREATE TABLE inscription (
    id INT AUTO_INCREMENT PRIMARY KEY,
    etudiant_id INT NOT NULL,
    enseignement_id INT NOT NULL, 
    date_inscription DATE NOT NULL,
    CONSTRAINT fk_insc_etud FOREIGN KEY (etudiant_id) REFERENCES etudiant(id),
    CONSTRAINT fk_insc_ens FOREIGN KEY (enseignement_id) REFERENCES enseignement(id),
    UNIQUE(etudiant_id, enseignement_id) 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO inscription (etudiant_id, enseignement_id, date_inscription) 
VALUES (1, 1, '2026-01-07'),(2, 2, '2026-07-07');

CREATE TABLE examen (
    id INT AUTO_INCREMENT PRIMARY KEY,
    inscription_id INT,
    date_examen DATE NOT NULL,
    score DECIMAL(4,2),
    CONSTRAINT fk_exam_insc FOREIGN KEY (inscription_id) REFERENCES inscription(id),
    CONSTRAINT check_note_valide CHECK (score BETWEEN 0 AND 20)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO inscription (etudiant_id, enseignement_id, date_inscription) VALUES (1, 1, '2020-06-10'),(1, 1, '2020-06-20');
select * from  inscription;

-- B. Contraintes d’intégrité

ALTER TABLE inscription ADD CONSTRAINT unique_inscription UNIQUE(etudiant_id, enseignement_id);

-- C. Insertion et tests

INSERT INTO examen (inscription_id, date_examen, score) VALUES 
(1, CURDATE(), 14);
INSERT INTO examen (inscription_id, date_examen, score) 
VALUES (2, CURDATE(), 18);

-- D. Sélection et filtrage : 

SELECT e.nom 
FROM etudiant e
JOIN inscription i ON e.id = i.etudiant_id
JOIN enseignement ens ON i.enseignement_id = ens.id
JOIN cours c ON ens.cours_id = c.id
WHERE c.code = 'mfbk9350';


SELECT nom, email 
FROM professeur 
WHERE departement = 'IA';

-- 
SELECT ins.* FROM inscription ins
JOIN etudiant e ON ins.etudiant_id = e.id
WHERE e.nom = 'ayman'
ORDER BY ins.date_inscription DESC;


-- E. Jointures et sous-requêtes :


SELECT 
    etu.nom AS nom_etudiant, 
    crs.titre AS titre_cours, 
    ens.semestre, 
    ins.date_inscription
FROM inscription ins
JOIN etudiant etu ON ins.etudiant_id = etu.id
JOIN enseignement ens ON ins.enseignement_id = ens.id
JOIN cours crs ON ens.cours_id = crs.id;

-- 
SELECT 
    e.nom, 
    (SELECT COUNT(*) 
     FROM inscription i 
     WHERE i.etudiant_id = e.id) AS total_inscriptions
FROM etudiant e;



CREATE OR REPLACE VIEW vu_etudiant_charge AS
SELECT 
    e.nom, 
    COUNT(i.id) AS nb_inscriptions, 
    SUM(c.credits) AS somme_credits
FROM etudiant e
LEFT JOIN inscription i ON e.id = i.etudiant_id
LEFT JOIN enseignement ens ON i.enseignement_id = ens.id
LEFT JOIN cours c ON ens.cours_id = c.id
GROUP BY e.id, e.nom;
SELECT * FROM vu_etudiant_charge;


-- F. Agrégation et rapports :

SELECT 
    c.titre, 
    COUNT(i.id) AS nb_etudiants
FROM cours c
LEFT JOIN enseignement ens ON c.id = ens.cours_id
LEFT JOIN inscription i ON ens.id = i.enseignement_id
GROUP BY c.id, c.titre;


SELECT 
    c.titre, 
    COUNT(i.id) AS total
FROM cours c
JOIN enseignement ens ON c.id = ens.cours_id
JOIN inscription i ON ens.id = i.enseignement_id
GROUP BY c.id
HAVING COUNT(i.id) > 10;


-- G. Maintenance du schéma :
ALTER TABLE examen ADD COLUMN commentaire TEXT; 

-- Remarque : On ne modifie jamais la base de données de production manuellement pour éviter les erreurs humaines et les décalages entre les environnements (Dév,Test....).




