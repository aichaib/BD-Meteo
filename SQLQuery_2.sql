

-- 1) Création des tables de dimensions

CREATE TABLE Province (
    id_province    INT IDENTITY(1,1) PRIMARY KEY,
    code           VARCHAR(10)    NOT NULL UNIQUE,
    nom            VARCHAR(100)   NOT NULL
);
GO

CREATE TABLE Station (
    id_station     INT IDENTITY(1,1) PRIMARY KEY,
    nom            VARCHAR(100)   NOT NULL,
    fk_id_province INT            NOT NULL
        CONSTRAINT FK_Station_Province
        REFERENCES Province(id_province)
        ON DELETE NO ACTION  -- équivalent à RESTRICT
);
GO

CREATE TABLE Annee (
    id_annee       INT IDENTITY(1,1) PRIMARY KEY,
    annee          INT            NOT NULL UNIQUE
);
GO

CREATE TABLE Source (
    id_source      INT IDENTITY(1,1) PRIMARY KEY,
    nom            VARCHAR(100)   NOT NULL,
    url            VARCHAR(255)   NULL
);
GO

-- 2) Création de la table de faits unifiée

CREATE TABLE Fait_Meteo (
    id_fait             INT IDENTITY(1,1) PRIMARY KEY,

    fk_id_province      INT            NOT NULL
        CONSTRAINT FK_Fait_Province
        REFERENCES Province(id_province)
        ON DELETE NO ACTION,

    fk_id_station       INT            NOT NULL
        CONSTRAINT FK_Fait_Station
        REFERENCES Station(id_station)
        ON DELETE NO ACTION,

    fk_id_annee         INT            NOT NULL
        CONSTRAINT FK_Fait_Annee
        REFERENCES Annee(id_annee)
        ON DELETE NO ACTION,

    fk_id_source        INT            NOT NULL
        CONSTRAINT FK_Fait_Source
        REFERENCES Source(id_source)
        ON DELETE NO ACTION,

    temperature_moy     DECIMAL(5,2)   NULL,
    co2_moy_mt          DECIMAL(8,2)   NULL,
    precipitation_moy   DECIMAL(6,2)   NULL,

    CONSTRAINT UQ_Fait UNIQUE (
      fk_id_province,
      fk_id_station,
      fk_id_annee,
      fk_id_source
    )
);
GO

-- Provinces (les 13 principales/territoires)
IF NOT EXISTS (SELECT 1 FROM Province WHERE code='NL') INSERT INTO Province (code, nom) VALUES ('NL','Terre-Neuve-et-Labrador');
IF NOT EXISTS (SELECT 1 FROM Province WHERE code='PE') INSERT INTO Province (code, nom) VALUES ('PE','Île-du-Prince-Édouard');
IF NOT EXISTS (SELECT 1 FROM Province WHERE code='NS') INSERT INTO Province (code, nom) VALUES ('NS','Nouvelle-Écosse');
IF NOT EXISTS (SELECT 1 FROM Province WHERE code='NB') INSERT INTO Province (code, nom) VALUES ('NB','Nouveau-Brunswick');
IF NOT EXISTS (SELECT 1 FROM Province WHERE code='QC') INSERT INTO Province (code, nom) VALUES ('QC','Québec');
IF NOT EXISTS (SELECT 1 FROM Province WHERE code='ON') INSERT INTO Province (code, nom) VALUES ('ON','Ontario');
IF NOT EXISTS (SELECT 1 FROM Province WHERE code='MB') INSERT INTO Province (code, nom) VALUES ('MB','Manitoba');
IF NOT EXISTS (SELECT 1 FROM Province WHERE code='SK') INSERT INTO Province (code, nom) VALUES ('SK','Saskatchewan');
IF NOT EXISTS (SELECT 1 FROM Province WHERE code='AB') INSERT INTO Province (code, nom) VALUES ('AB','Alberta');
IF NOT EXISTS (SELECT 1 FROM Province WHERE code='BC') INSERT INTO Province (code, nom) VALUES ('BC','Colombie-Britannique');
IF NOT EXISTS (SELECT 1 FROM Province WHERE code='YT') INSERT INTO Province (code, nom) VALUES ('YT','Yukon');
IF NOT EXISTS (SELECT 1 FROM Province WHERE code='NT') INSERT INTO Province (code, nom) VALUES ('NT','Territoires du Nord-Ouest');
IF NOT EXISTS (SELECT 1 FROM Province WHERE code='NU') INSERT INTO Province (code, nom) VALUES ('NU','Nunavut');

-- Années 2019 à 2024
DECLARE @year INT = 2019;
WHILE @year <= 2024
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Annee WHERE annee = @year)
        INSERT INTO Annee (annee) VALUES (@year);
    SET @year = @year + 1;
END

SELECT * FROM Province ORDER BY code;
SELECT * FROM Annee ORDER BY annee;

-- 1. Stations spécifiques
-- Winnipeg Intl (Manitoba)
IF NOT EXISTS (
    SELECT 1 FROM Station s
    JOIN Province p ON s.fk_id_province = p.id_province
    WHERE s.nom = 'Winnipeg Intl' AND p.code = 'MB'
)
BEGIN
    INSERT INTO Station (nom, fk_id_province)
    VALUES ('Winnipeg Intl', (SELECT id_province FROM Province WHERE code='MB'));
END

-- Saskatoon (Saskatchewan)
IF NOT EXISTS (
    SELECT 1 FROM Station s
    JOIN Province p ON s.fk_id_province = p.id_province
    WHERE s.nom = 'REGINA INTL A' AND p.code = 'SK'
)
BEGIN
    INSERT INTO Station (nom, fk_id_province)
    VALUES ('REGINA INTL A', (SELECT id_province FROM Province WHERE code='SK'));
END

-- Québec
IF NOT EXISTS (
    SELECT 1 FROM Station s
    JOIN Province p ON s.fk_id_province = p.id_province
    WHERE s.nom = 'QUEBEC/JEAN LESAGE INTL' AND p.code = 'QC'
)
BEGIN
    INSERT INTO Station (nom, fk_id_province)
    VALUES ('QUEBEC/JEAN LESAGE INTL', (SELECT id_province FROM Province WHERE code='QC'));
END

-- Ontario
IF NOT EXISTS (
    SELECT 1 FROM Station s
    JOIN Province p ON s.fk_id_province = p.id_province
    WHERE s.nom = 'TORONTO INTL Ao' AND p.code = 'ON'
)
BEGIN
    INSERT INTO Station (nom, fk_id_province)
    VALUES ('TORONTO INTL A', (SELECT id_province FROM Province WHERE code='ON'));
END

-- Nouveau-Brunswick
IF NOT EXISTS (
    SELECT 1 FROM Station s
    JOIN Province p ON s.fk_id_province = p.id_province
    WHERE s.nom = 'FREDERICTON CDA CS' AND p.code = 'NB'
)
BEGIN
    INSERT INTO Station (nom, fk_id_province)
    VALUES ('FREDERICTON CDA CS', (SELECT id_province FROM Province WHERE code='NB'));
END

-- Nouvelle-Écosse
IF NOT EXISTS (
    SELECT 1 FROM Station s
    JOIN Province p ON s.fk_id_province = p.id_province
    WHERE s.nom = 'HALIFAX STANFIELD INT L A' AND p.code = 'NS'
)
BEGIN
    INSERT INTO Station (nom, fk_id_province)
    VALUES ('HALIFAX STANFIELD INT L A', (SELECT id_province FROM Province WHERE code='NS'));
END

-- Terre-Neuve-et-Labrador
IF NOT EXISTS (
    SELECT 1 FROM Station s
    JOIN Province p ON s.fk_id_province = p.id_province
    WHERE s.nom = 'ST JOHNS WEST CLIMATE' AND p.code = 'NL'
)
BEGIN
    INSERT INTO Station (nom, fk_id_province)
    VALUES ('ST JOHNS WEST CLIMATE', (SELECT id_province FROM Province WHERE code='NL'));
END

-- Île-du-Prince-Édouard
IF NOT EXISTS (
    SELECT 1 FROM Station s
    JOIN Province p ON s.fk_id_province = p.id_province
    WHERE s.nom = 'CHARLOTTETOWN A' AND p.code = 'PE'
)
BEGIN
    INSERT INTO Station (nom, fk_id_province)
    VALUES ('CHARLOTTETOWN A', (SELECT id_province FROM Province WHERE code='PE'));
END

-- Alberta
IF NOT EXISTS (
    SELECT 1 FROM Station s
    JOIN Province p ON s.fk_id_province = p.id_province
    WHERE s.nom = 'EDMONTON INTERNATIONAL CS' AND p.code = 'AB'
)
BEGIN
    INSERT INTO Station (nom, fk_id_province)
    VALUES ('EDMONTON INTERNATIONAL CS', (SELECT id_province FROM Province WHERE code='AB'));
END

-- Colombie-Britannique
IF NOT EXISTS (
    SELECT 1 FROM Station s
    JOIN Province p ON s.fk_id_province = p.id_province
    WHERE s.nom = 'VANCOUVER INTL A' AND p.code = 'BC'
)
BEGIN
    INSERT INTO Station (nom, fk_id_province)
    VALUES ('VANCOUVER INTL A', (SELECT id_province FROM Province WHERE code='BC'));
END

-- Territoires du Nord-Ouest
IF NOT EXISTS (
    SELECT 1 FROM Station s
    JOIN Province p ON s.fk_id_province = p.id_province
    WHERE s.nom = 'YELLOWKNIFE A' AND p.code = 'NT'
)
BEGIN
    INSERT INTO Station (nom, fk_id_province)
    VALUES ('YELLOWKNIFE A', (SELECT id_province FROM Province WHERE code='NT'));
END

-- Yukon (déjà inséré Whitehorse mais on peut avoir une générique aussi)
IF NOT EXISTS (
    SELECT 1 FROM Station s
    JOIN Province p ON s.fk_id_province = p.id_province
    WHERE s.nom = 'WHITEHORSE AUTO' AND p.code = 'YT'
)
BEGIN
    INSERT INTO Station (nom, fk_id_province)
    VALUES ('WHITEHORSE AUTO', (SELECT id_province FROM Province WHERE code='YT'));
END

-- Nunavut (générique en plus de ce qui viendra)
IF NOT EXISTS (
    SELECT 1 FROM Station s
    JOIN Province p ON s.fk_id_province = p.id_province
    WHERE s.nom = 'NIQALUIT CLIMATE' AND p.code = 'NU'
)
BEGIN
    INSERT INTO Station (nom, fk_id_province)
    VALUES ('IQALUIT CLIMATE', (SELECT id_province FROM Province WHERE code='NU'));
END

GO

-- Insère la source si elle n'existe pas encore
IF NOT EXISTS (SELECT 1 FROM Source WHERE nom = 'Environnement Canada - données historiques' )
    INSERT INTO Source (nom, url)
    VALUES (
        'Environnement Canada - données historiques',
        'https://climate.weather.gc.ca/historical_data/search_historic_data_e.html'
    );

SELECT * FROM Source;

-- 2. Afficher toutes les stations avec leur province
SELECT 
    s.id_station, 
    s.nom AS station, 
    p.code AS province_code, 
    p.nom AS province_nom
FROM Station s
JOIN Province p ON s.fk_id_province = p.id_province
ORDER BY p.code, s.nom;

---Alberta
INSERT INTO Fait_Meteo (
    fk_id_province,
    fk_id_station,
    fk_id_annee,
    fk_id_source,
    temperature_moy,
    precipitation_moy
)
VALUES
(
    -- 2019
    (SELECT id_province FROM Province WHERE code = 'AB'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'EDMONTON INTERNATIONAL CS' AND p.code = 'AB'),
    (SELECT id_annee FROM Annee WHERE annee = 2019),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    1.54, 1.34
),
(
    -- 2020
    (SELECT id_province FROM Province WHERE code = 'AB'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'EDMONTON INTERNATIONAL CS' AND p.code = 'AB'),
    (SELECT id_annee FROM Annee WHERE annee = 2020),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    1.85, 1.17
),
(
    -- 2021
    (SELECT id_province FROM Province WHERE code = 'AB'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'EDMONTON INTERNATIONAL CS' AND p.code = 'AB'),
    (SELECT id_annee FROM Annee WHERE annee = 2021),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    1.07, 0.98
),
(
    -- 2022
    (SELECT id_province FROM Province WHERE code = 'AB'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'EDMONTON INTERNATIONAL CS' AND p.code = 'AB'),
    (SELECT id_annee FROM Annee WHERE annee = 2022),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    3.00, 0.96
),
(
    -- 2023
    (SELECT id_province FROM Province WHERE code = 'AB'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'EDMONTON INTERNATIONAL CS' AND p.code = 'AB'),
    (SELECT id_annee FROM Annee WHERE annee = 2023),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    4.57, 1.13
),
(
    (SELECT id_province FROM Province WHERE code = 'AB'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'EDMONTON INTERNATIONAL CS' AND p.code = 'AB'),
    (SELECT id_annee FROM Annee WHERE annee = 2024),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    3.02, 0.86
);

---Colombie
INSERT INTO Fait_Meteo (
    fk_id_province,
    fk_id_station,
    fk_id_annee,
    fk_id_source,
    temperature_moy,
    precipitation_moy
)
VALUES
(
    -- 2019
    (SELECT id_province FROM Province WHERE code = 'BC'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'VANCOUVER INTL A' AND p.code = 'BC'),
    (SELECT id_annee FROM Annee WHERE annee = 2019),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    10.41, 2.65
),
(
    -- 2020
    (SELECT id_province FROM Province WHERE code = 'BC'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'VANCOUVER INTL A' AND p.code = 'BC'),
    (SELECT id_annee FROM Annee WHERE annee = 2020),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    10.68, 3.12
),
(
    -- 2021
    (SELECT id_province FROM Province WHERE code = 'BC'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'VANCOUVER INTL A' AND p.code = 'BC'),
    (SELECT id_annee FROM Annee WHERE annee = 2021),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    10.49, 3.17
),
(
    -- 2022
    (SELECT id_province FROM Province WHERE code = 'BC'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'VANCOUVER INTL A' AND p.code = 'BC'),
    (SELECT id_annee FROM Annee WHERE annee = 2022),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    10.13, 2.88
),
(
    -- 2023
    (SELECT id_province FROM Province WHERE code = 'BC'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'VANCOUVER INTL A' AND p.code = 'BC'),
    (SELECT id_annee FROM Annee WHERE annee = 2023),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    11.04, 2.42
),
(
    -- 2024
    (SELECT id_province FROM Province WHERE code = 'BC'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'VANCOUVER INTL A' AND p.code = 'BC'),
    (SELECT id_annee FROM Annee WHERE annee = 2024),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    10.74, 3.75
);
--Manitoba
INSERT INTO Fait_Meteo (
    fk_id_province,
    fk_id_station,
    fk_id_annee,
    fk_id_source,
    temperature_moy,
    precipitation_moy
)
VALUES
(
    -- 2019
    (SELECT id_province FROM Province WHERE code = 'MB'),
    (SELECT id_station FROM Station s
       JOIN Province p ON s.fk_id_province = p.id_province
       WHERE s.nom = 'Winnipeg Intl' AND p.code = 'MB'),
    (SELECT id_annee FROM Annee WHERE annee = 2019),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    1.83, NULL
),
(
    -- 2020
    (SELECT id_province FROM Province WHERE code = 'MB'),
    (SELECT id_station FROM Station s
       JOIN Province p ON s.fk_id_province = p.id_province
       WHERE s.nom = 'Winnipeg Intl' AND p.code = 'MB'),
    (SELECT id_annee FROM Annee WHERE annee = 2020),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    3.52, NULL
),
(
    -- 2021
    (SELECT id_province FROM Province WHERE code = 'MB'),
    (SELECT id_station FROM Station s
       JOIN Province p ON s.fk_id_province = p.id_province
       WHERE s.nom = 'Winnipeg Intl' AND p.code = 'MB'),
    (SELECT id_annee FROM Annee WHERE annee = 2021),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    4.60, NULL
),
(
    -- 2022
    (SELECT id_province FROM Province WHERE code = 'MB'),
    (SELECT id_station FROM Station s
       JOIN Province p ON s.fk_id_province = p.id_province
       WHERE s.nom = 'Winnipeg Intl' AND p.code = 'MB'),
    (SELECT id_annee FROM Annee WHERE annee = 2022),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    2.10, NULL
),
(
    -- 2023
    (SELECT id_province FROM Province WHERE code = 'MB'),
    (SELECT id_station FROM Station s
       JOIN Province p ON s.fk_id_province = p.id_province
       WHERE s.nom = 'Winnipeg Intl' AND p.code = 'MB'),
    (SELECT id_annee FROM Annee WHERE annee = 2023),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    4.21, NULL
),
(
    -- 2024
    (SELECT id_province FROM Province WHERE code = 'MB'),
    (SELECT id_station FROM Station s
       JOIN Province p ON s.fk_id_province = p.id_province
       WHERE s.nom = 'Winnipeg Intl' AND p.code = 'MB'),
    (SELECT id_annee FROM Annee WHERE annee = 2024),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    5.21, NULL
);

--New brunswick
INSERT INTO Fait_Meteo (
    fk_id_province,
    fk_id_station,
    fk_id_annee,
    fk_id_source,
    temperature_moy,
    precipitation_moy
)
VALUES
(
    -- 2019
    (SELECT id_province FROM Province WHERE code = 'NB'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'FREDERICTON CDA CS' AND p.code = 'NB'),
    (SELECT id_annee FROM Annee WHERE annee = 2019),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    5.25, 3.68
),
(
    -- 2020
    (SELECT id_province FROM Province WHERE code = 'NB'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'FREDERICTON CDA CS' AND p.code = 'NB'),
    (SELECT id_annee FROM Annee WHERE annee = 2020),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    6.93, 2.41
),
(
    -- 2021
    (SELECT id_province FROM Province WHERE code = 'NB'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'FREDERICTON CDA CS' AND p.code = 'NB'),
    (SELECT id_annee FROM Annee WHERE annee = 2021),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    7.40, 2.84
),
(
    -- 2022
    (SELECT id_province FROM Province WHERE code = 'NB'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'FREDERICTON CDA CS' AND p.code = 'NB'),
    (SELECT id_annee FROM Annee WHERE annee = 2022),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    6.84, 3.42
),
(
    -- 2023
    (SELECT id_province FROM Province WHERE code = 'NB'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'FREDERICTON CDA CS' AND p.code = 'NB'),
    (SELECT id_annee FROM Annee WHERE annee = 2023),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    7.26, 3.73
),
(
    -- 2024
    (SELECT id_province FROM Province WHERE code = 'NB'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'FREDERICTON CDA CS' AND p.code = 'NB'),
    (SELECT id_annee FROM Annee WHERE annee = 2024),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    7.68, 2.58
);

---Labrador
INSERT INTO Fait_Meteo (
    fk_id_province,
    fk_id_station,
    fk_id_annee,
    fk_id_source,
    temperature_moy,
    precipitation_moy
)
VALUES
(
    -- 2019
    (SELECT id_province FROM Province WHERE code = 'NL'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'ST JOHNS WEST CLIMATE' AND p.code = 'NL'),
    (SELECT id_annee FROM Annee WHERE annee = 2019),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    4.85, 3.36
),
(
    -- 2020
    (SELECT id_province FROM Province WHERE code = 'NL'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'ST JOHNS WEST CLIMATE' AND p.code = 'NL'),
    (SELECT id_annee FROM Annee WHERE annee = 2020),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    5.77, 4.29
),
(
    -- 2021
    (SELECT id_province FROM Province WHERE code = 'NL'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'ST JOHNS WEST CLIMATE' AND p.code = 'NL'),
    (SELECT id_annee FROM Annee WHERE annee = 2021),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    6.38, 3.93
),
(
    -- 2022
    (SELECT id_province FROM Province WHERE code = 'NL'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'ST JOHNS WEST CLIMATE' AND p.code = 'NL'),
    (SELECT id_annee FROM Annee WHERE annee = 2022),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    7.01, 4.43
),
(
    -- 2023
    (SELECT id_province FROM Province WHERE code = 'NL'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'ST JOHNS WEST CLIMATE' AND p.code = 'NL'),
    (SELECT id_annee FROM Annee WHERE annee = 2023),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    6.10, 3.44
),
(
    -- 2024
    (SELECT id_province FROM Province WHERE code = 'NL'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'ST JOHNS WEST CLIMATE' AND p.code = 'NL'),
    (SELECT id_annee FROM Annee WHERE annee = 2024),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    7.00, 4.35
);

---Northwest territories
INSERT INTO Fait_Meteo (
    fk_id_province,
    fk_id_station,
    fk_id_annee,
    fk_id_source,
    temperature_moy,
    precipitation_moy
)
VALUES
(
    -- 2019
    (SELECT id_province FROM Province WHERE code = 'NT'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'YELLOWKNIFE A' AND p.code = 'NT'),
    (SELECT id_annee FROM Annee WHERE annee = 2019),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    -4.64, 0.79
),
(
    -- 2020
    (SELECT id_province FROM Province WHERE code = 'NT'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'YELLOWKNIFE A' AND p.code = 'NT'),
    (SELECT id_annee FROM Annee WHERE annee = 2020),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    -4.91, 0.77
),
(
    -- 2021
    (SELECT id_province FROM Province WHERE code = 'NT'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'YELLOWKNIFE A' AND p.code = 'NT'),
    (SELECT id_annee FROM Annee WHERE annee = 2021),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    -4.57, 0.56
),
(
    -- 2022
    (SELECT id_province FROM Province WHERE code = 'NT'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'YELLOWKNIFE A' AND p.code = 'NT'),
    (SELECT id_annee FROM Annee WHERE annee = 2022),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    -4.28, 0.51
),
(
    -- 2023
    (SELECT id_province FROM Province WHERE code = 'NT'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'YELLOWKNIFE A' AND p.code = 'NT'),
    (SELECT id_annee FROM Annee WHERE annee = 2023),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    -1.81, 0.40
),
(
    -- 2024
    (SELECT id_province FROM Province WHERE code = 'NT'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'YELLOWKNIFE A' AND p.code = 'NT'),
    (SELECT id_annee FROM Annee WHERE annee = 2024),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    -2.79, 0.49
);

---Nova scotia
INSERT INTO Fait_Meteo (
    fk_id_province,
    fk_id_station,
    fk_id_annee,
    fk_id_source,
    temperature_moy,
    precipitation_moy
)
VALUES
(
    -- 2019
    (SELECT id_province FROM Province WHERE code = 'NS'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'HALIFAX STANFIELD INT L A' AND p.code = 'NS'),
    (SELECT id_annee FROM Annee WHERE annee = 2019),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    6.76, 4.09
),
(
    -- 2020
    (SELECT id_province FROM Province WHERE code = 'NS'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'HALIFAX STANFIELD INT L A' AND p.code = 'NS'),
    (SELECT id_annee FROM Annee WHERE annee = 2020),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    7.85, 3.74
),
(
    -- 2021
    (SELECT id_province FROM Province WHERE code = 'NS'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'HALIFAX STANFIELD INT L A' AND p.code = 'NS'),
    (SELECT id_annee FROM Annee WHERE annee = 2021),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    8.47, 4.23
),
(
    -- 2022
    (SELECT id_province FROM Province WHERE code = 'NS'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'HALIFAX STANFIELD INT L A' AND p.code = 'NS'),
    (SELECT id_annee FROM Annee WHERE annee = 2022),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    8.17, 4.05
),
(
    -- 2023
    (SELECT id_province FROM Province WHERE code = 'NS'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'HALIFAX STANFIELD INT L A' AND p.code = 'NS'),
    (SELECT id_annee FROM Annee WHERE annee = 2023),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    7.98, 4.33
),
(
    -- 2024
    (SELECT id_province FROM Province WHERE code = 'NS'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'HALIFAX STANFIELD INT L A' AND p.code = 'NS'),
    (SELECT id_annee FROM Annee WHERE annee = 2024),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    8.18, 3.67
);

--Nuvanut
INSERT INTO Fait_Meteo (
    fk_id_province,
    fk_id_station,
    fk_id_annee,
    fk_id_source,
    temperature_moy,
    precipitation_moy
)
VALUES
(
    -- 2019
    (SELECT id_province FROM Province WHERE code = 'NU'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'IQALUIT CLIMATE' AND p.code = 'NU'),
    (SELECT id_annee FROM Annee WHERE annee = 2019),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    -6.78, 0.74
),
(
    -- 2020
    (SELECT id_province FROM Province WHERE code = 'NU'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'IQALUIT CLIMATE' AND p.code = 'NU'),
    (SELECT id_annee FROM Annee WHERE annee = 2020),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    -7.71, 0.91
),
(
    -- 2021
    (SELECT id_province FROM Province WHERE code = 'NU'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'IQALUIT CLIMATE' AND p.code = 'NU'),
    (SELECT id_annee FROM Annee WHERE annee = 2021),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    -5.47, 0.79
),
(
    -- 2022
    (SELECT id_province FROM Province WHERE code = 'NU'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'IQALUIT CLIMATE' AND p.code = 'NU'),
    (SELECT id_annee FROM Annee WHERE annee = 2022),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    -8.09, 0.97
),
(
    -- 2023
    (SELECT id_province FROM Province WHERE code = 'NU'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'IQALUIT CLIMATE' AND p.code = 'NU'),
    (SELECT id_annee FROM Annee WHERE annee = 2023),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    -8.23, 0.97
),
(
    -- 2024
    (SELECT id_province FROM Province WHERE code = 'NU'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'IQALUIT CLIMATE' AND p.code = 'NU'),
    (SELECT id_annee FROM Annee WHERE annee = 2024),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    -7.24, 0.88
);

---Ontario
INSERT INTO Fait_Meteo (
    fk_id_province,
    fk_id_station,
    fk_id_annee,
    fk_id_source,
    temperature_moy,
    precipitation_moy
)
VALUES
(
    -- 2019
    (SELECT id_province FROM Province WHERE code = 'ON'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'TORONTO INTL A' AND p.code = 'ON'),
    (SELECT id_annee FROM Annee WHERE annee = 2019),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    8.18, 2.60
),
(
    -- 2020
    (SELECT id_province FROM Province WHERE code = 'ON'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'TORONTO INTL A' AND p.code = 'ON'),
    (SELECT id_annee FROM Annee WHERE annee = 2020),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    9.76, 2.08
),
(
    -- 2021
    (SELECT id_province FROM Province WHERE code = 'ON'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'TORONTO INTL A' AND p.code = 'ON'),
    (SELECT id_annee FROM Annee WHERE annee = 2021),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    10.32, 2.28
),
(
    -- 2022
    (SELECT id_province FROM Province WHERE code = 'ON'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'TORONTO INTL A' AND p.code = 'ON'),
    (SELECT id_annee FROM Annee WHERE annee = 2022),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    9.28, 1.85
),
(
    -- 2023
    (SELECT id_province FROM Province WHERE code = 'ON'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'TORONTO INTL A' AND p.code = 'ON'),
    (SELECT id_annee FROM Annee WHERE annee = 2023),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    10.11, 2.36
),
(
    -- 2024
    (SELECT id_province FROM Province WHERE code = 'ON'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'TORONTO INTL A' AND p.code = 'ON'),
    (SELECT id_annee FROM Annee WHERE annee = 2024),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    10.54, 3.13
);

---Prince Edward
INSERT INTO Fait_Meteo (
    fk_id_province,
    fk_id_station,
    fk_id_annee,
    fk_id_source,
    temperature_moy,
    precipitation_moy
)
VALUES
(
    -- 2019
    (SELECT id_province FROM Province WHERE code = 'PE'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'CHARLOTTETOWN A' AND p.code = 'PE'),
    (SELECT id_annee FROM Annee WHERE annee = 2019),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    5.39, 3.34
),
(
    -- 2020
    (SELECT id_province FROM Province WHERE code = 'PE'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'CHARLOTTETOWN A' AND p.code = 'PE'),
    (SELECT id_annee FROM Annee WHERE annee = 2020),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    6.87, 2.70
),
(
    -- 2021
    (SELECT id_province FROM Province WHERE code = 'PE'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'CHARLOTTETOWN A' AND p.code = 'PE'),
    (SELECT id_annee FROM Annee WHERE annee = 2021),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    7.42, 3.46
),
(
    -- 2022
    (SELECT id_province FROM Province WHERE code = 'PE'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'CHARLOTTETOWN A' AND p.code = 'PE'),
    (SELECT id_annee FROM Annee WHERE annee = 2022),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    7.22, 3.41
),
(
    -- 2023
    (SELECT id_province FROM Province WHERE code = 'PE'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'CHARLOTTETOWN A' AND p.code = 'PE'),
    (SELECT id_annee FROM Annee WHERE annee = 2023),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    7.27, 3.34
),
(
    -- 2024
    (SELECT id_province FROM Province WHERE code = 'PE'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'CHARLOTTETOWN A' AND p.code = 'PE'),
    (SELECT id_annee FROM Annee WHERE annee = 2024),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    7.63, 2.65
);

---Quebec 
INSERT INTO Fait_Meteo (
    fk_id_province,
    fk_id_station,
    fk_id_annee,
    fk_id_source,
    temperature_moy,
    precipitation_moy
)
VALUES
(
    -- 2019
    (SELECT id_province FROM Province WHERE code = 'QC'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'QUEBEC/JEAN LESAGE INTL' AND p.code = 'QC'),
    (SELECT id_annee FROM Annee WHERE annee = 2019),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    3.52, 3.46
),
(
    -- 2020
    (SELECT id_province FROM Province WHERE code = 'QC'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'QUEBEC/JEAN LESAGE INTL' AND p.code = 'QC'),
    (SELECT id_annee FROM Annee WHERE annee = 2020),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    5.03, 3.57
),
(
    -- 2021
    (SELECT id_province FROM Province WHERE code = 'QC'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'QUEBEC/JEAN LESAGE INTL' AND p.code = 'QC'),
    (SELECT id_annee FROM Annee WHERE annee = 2021),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    5.65, 2.72
),
(
    -- 2022
    (SELECT id_province FROM Province WHERE code = 'QC'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'QUEBEC/JEAN LESAGE INTL' AND p.code = 'QC'),
    (SELECT id_annee FROM Annee WHERE annee = 2022),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    4.66, 3.60
),
(
    -- 2023
    (SELECT id_province FROM Province WHERE code = 'QC'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'QUEBEC/JEAN LESAGE INTL' AND p.code = 'QC'),
    (SELECT id_annee FROM Annee WHERE annee = 2023),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    5.79, 3.47
),
(
    -- 2024
    (SELECT id_province FROM Province WHERE code = 'QC'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'QUEBEC/JEAN LESAGE INTL' AND p.code = 'QC'),
    (SELECT id_annee FROM Annee WHERE annee = 2024),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    6.46, 2.86
);

---Saskatchewan
INSERT INTO Fait_Meteo (
    fk_id_province,
    fk_id_station,
    fk_id_annee,
    fk_id_source,
    temperature_moy,
    precipitation_moy
)
VALUES
(
    -- 2019
    (SELECT id_province FROM Province WHERE code = 'SK'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'REGINA INTL A' AND p.code = 'SK'),
    (SELECT id_annee FROM Annee WHERE annee = 2019),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    1.83, NULL
),
(
    -- 2020
    (SELECT id_province FROM Province WHERE code = 'SK'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'REGINA INTL A' AND p.code = 'SK'),
    (SELECT id_annee FROM Annee WHERE annee = 2020),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    3.52, NULL
),
(
    -- 2021
    (SELECT id_province FROM Province WHERE code = 'SK'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'REGINA INTL A' AND p.code = 'SK'),
    (SELECT id_annee FROM Annee WHERE annee = 2021),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    4.60, NULL
),
(
    -- 2022
    (SELECT id_province FROM Province WHERE code = 'SK'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'REGINA INTL A' AND p.code = 'SK'),
    (SELECT id_annee FROM Annee WHERE annee = 2022),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    2.10, NULL
),
(
    -- 2023
    (SELECT id_province FROM Province WHERE code = 'SK'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'REGINA INTL A' AND p.code = 'SK'),
    (SELECT id_annee FROM Annee WHERE annee = 2023),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    4.21, NULL
),
(
    -- 2024
    (SELECT id_province FROM Province WHERE code = 'SK'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'REGINA INTL A' AND p.code = 'SK'),
    (SELECT id_annee FROM Annee WHERE annee = 2024),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    5.21, NULL
);

---Yukon
INSERT INTO Fait_Meteo (
    fk_id_province,
    fk_id_station,
    fk_id_annee,
    fk_id_source,
    temperature_moy,
    precipitation_moy
)
VALUES
(
    -- 2019
    (SELECT id_province FROM Province WHERE code = 'YT'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'WHITEHORSE AUTO' AND p.code = 'YT'),
    (SELECT id_annee FROM Annee WHERE annee = 2019),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    1.59, 249.3
),
(
    -- 2020
    (SELECT id_province FROM Province WHERE code = 'YT'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'WHITEHORSE AUTO' AND p.code = 'YT'),
    (SELECT id_annee FROM Annee WHERE annee = 2020),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    -0.75, 377.4
),
(
    -- 2021
    (SELECT id_province FROM Province WHERE code = 'YT'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'WHITEHORSE AUTO' AND p.code = 'YT'),
    (SELECT id_annee FROM Annee WHERE annee = 2021),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    -0.76, 328.0
),
(
    -- 2022
    (SELECT id_province FROM Province WHERE code = 'YT'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'WHITEHORSE AUTO' AND p.code = 'YT'),
    (SELECT id_annee FROM Annee WHERE annee = 2022),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    0.81, 304.6
),
(
    -- 2023
    (SELECT id_province FROM Province WHERE code = 'YT'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'WHITEHORSE AUTO' AND p.code = 'YT'),
    (SELECT id_annee FROM Annee WHERE annee = 2023),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    2.35, 261.7
),
(
    -- 2024
    (SELECT id_province FROM Province WHERE code = 'YT'),
    (SELECT s.id_station
     FROM Station s
     JOIN Province p ON s.fk_id_province = p.id_province
     WHERE s.nom = 'WHITEHORSE AUTO' AND p.code = 'YT'),
    (SELECT id_annee FROM Annee WHERE annee = 2024),
    (SELECT id_source FROM Source WHERE nom = 'Environnement Canada - données historiques'),
    0.69, 261.0
);

SELECT
    f.id_fait,
    p.code         AS province_code,
    p.nom          AS province_nom,
    s.nom          AS station,
    a.annee        AS annee,
    src.nom        AS source,
    f.temperature_moy,
    f.precipitation_moy
FROM Fait_Meteo f
JOIN Province    p   ON f.fk_id_province = p.id_province
JOIN Station     s   ON f.fk_id_station  = s.id_station
JOIN Annee       a   ON f.fk_id_annee    = a.id_annee
JOIN Source      src ON f.fk_id_source   = src.id_source
ORDER BY
    p.code,
    a.annee;
