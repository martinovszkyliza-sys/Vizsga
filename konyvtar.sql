-- Adatbázis létrehozása és kiválasztása
CREATE DATABASE IF NOT EXISTS konyvtar_db
DEFAULT CHARACTER SET utf8mb4
DEFAULT COLLATE utf8mb4_hungarian_ci;

USE konyvtar_db;

-- 1. Olvasók (felhasználók) táblája
CREATE TABLE IF NOT EXISTS olvasok (
    torzsszam INT AUTO_INCREMENT PRIMARY KEY,
    nev VARCHAR(150) NOT NULL,
    szuletesi_datum DATE NOT NULL,
    elerhetoseg VARCHAR(255) NOT NULL,
    is_admin TINYINT(1) DEFAULT 0 -- Opcionális: 1, ha adminisztrátor, 0 ha sima olvasó
) ENGINE=InnoDB;

-- 2. Könyvek táblája
CREATE TABLE IF NOT EXISTS konyvek (
    konyvid INT AUTO_INCREMENT PRIMARY KEY,
    cim VARCHAR(255) NOT NULL,
    iro VARCHAR(150) NOT NULL,
    mufaj VARCHAR(100),
    kategoria ENUM('szépirodalom', 'szakirodalom') NOT NULL,
    korhatar INT DEFAULT 0, -- 0 = mindenkié, 18 = csak felnőtteknek
    oldalszam INT,
    kiadasi_ev YEAR,
    nyelv VARCHAR(50) DEFAULT 'Magyar',
    kiado VARCHAR(100),
    statusz ENUM('kölcsönözhető', 'kölcsönzött') DEFAULT 'kölcsönözhető',
    borito_kep VARCHAR(255) -- Bővítéshez: képfájl neve vagy útvonala
) ENGINE=InnoDB;

-- 3. Kölcsönzések táblája (Kapcsolótábla az olvasók és könyvek között)
CREATE TABLE IF NOT EXISTS kolcsonzesek (
    kolcsonid INT AUTO_INCREMENT PRIMARY KEY,
    torzsszam INT NOT NULL,
    konyvid INT NOT NULL,
    kolcson_datum DATE NOT NULL,
    kolcson_hatarido DATE NOT NULL,
    -- Idegen kulcsok beállítása a kapcsolatokhoz
    CONSTRAINT fk_olvaso FOREIGN KEY (torzsszam)
        REFERENCES olvasok(torzsszam)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_konyv FOREIGN KEY (konyvid)
        REFERENCES konyvek(konyvid)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

USE konyvtar_db;

-- PÉLDA ADATOK
-- 1. Olvasók feltöltése (Keverve felnőttek és kiskorúak a korhatár teszteléséhez)
INSERT INTO olvasok (nev, szuletesi_datum, elerhetoseg, is_admin) VALUES
('Kovács Anna', '1995-05-12', 'anna.kovacs@email.com', 0),
('Nagy Péter', '2010-08-20', 'peter.nagy@email.com', 0),       -- 16 éves (2026-ban) -> Kiskorú
('Szabó Eszter', '1988-03-15', 'eszter.szabo@email.com', 0),
('Tóth Bence', '2012-11-05', 'bence.toth@email.com', 0),        -- 14 éves (2026-ban) -> Kiskorú
('Adminisztrátor', '1980-01-01', 'admin@konyvtar.hu', 1);       -- Admin fiók

-- 2. Könyvek feltöltése (Gyerek-, felnőtt, szépirodalmi és szakirodalmi könyvek)
INSERT INTO konyvek (cim, iro, mufaj, kategoria, korhatar, oldalszam, kiadasi_ev, nyelv, kiado, statusz, borito_kep) VALUES
('A Pál utcai fiúk', 'Molnár Ferenc', 'Ifjúsági regény', 'szépirodalom', 0, 250, 1907, 'Magyar', 'Móra Könyvkiadó', 'kölcsönözhető', 'pal_utcai_fiuk.jpg'),
('Egri csillagok', 'Gárdonyi Géza', 'Történelmi regény', 'szépirodalom', 0, 500, 1901, 'Magyar', 'Osiris Kiadó', 'kölcsönzött', 'egri_csillagok.jpg'),
('A sötét ötven árnyalata', 'E. L. James', 'Romantikus / Erotikus', 'szépirodalom', 18, 530, 2011, 'Magyar', 'Ulpius-ház', 'kölcsönözhető', 'sotet_otven.jpg'),
('Python programozás alapjai', 'Kovács János', 'Informatika', 'szakirodalom', 0, 320, 2020, 'Magyar', 'Kiskapu Kiadó', 'kölcsönzött', 'python_alapok.jpg'),
('AZ (It)', 'Stephen King', 'Horror', 'szépirodalom', 18, 1138, 1986, 'Magyar', 'Európa Könyvkiadó', 'kölcsönözhető', 'stephen_king_az.jpg');

-- 3. Kölcsönzések feltöltése (Ahol mutatja, hogy ki, mit, mikor kölcsönzött ki)
INSERT INTO kolcsonzesek (torzsszam, konyvid, kolcson_datum, kolcson_hatarido) VALUES
(1, 4, '2026-05-01', '2026-06-01'), -- Kovács Anna kikölcsönözte a Python könyvet
(3, 2, '2026-05-10', '2026-06-10'); -- Szabó Eszter kikölcsönözte az Egri csillagokat
