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
    password_hash VARCHAR(255) NULL,
    is_admin TINYINT(1) DEFAULT 0, -- Opcionális: 1, ha adminisztrátor, 0 ha sima olvasó
    UNIQUE KEY uq_olvasok_elerhetoseg (elerhetoseg)
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
INSERT INTO olvasok (nev, szuletesi_datum, elerhetoseg, password_hash, is_admin) VALUES
('Kovács Anna', '1995-05-12', 'anna.kovacs@email.com', 'scrypt$8256a28432e9ac52460151a41d3c7472$8190293b1abbfe09daee302bb973ae387e5cfd25ed4770b5c0c2f46d50d18ac1b2776eb1dbe409e5bcebbf08fb46e8d0c162b34ac2bb2d0b0b5785e1403372e3', 0),
('Nagy Péter', '2010-08-20', 'peter.nagy@email.com', 'scrypt$6789cebc4ce54eef38519efd0d2af146$493a546a3353958d6830ca26b73b18ce02d7ec1eec83be99708bc591caf7e51818ec00dd7f84e78bd2273d4735319734b4d6656a38d55ceff98e9089dee776fa', 0),       -- 16 éves (2026-ban) -> Kiskorú
('Szabó Eszter', '1988-03-15', 'eszter.szabo@email.com', 'scrypt$1fed562ce33ac1424858c2b06bbe288d$845422ed1b772be8e88dc2ceca8bc8f85e392fdc837b8fb303ecde3aa9c083105ec326b2928c1755e1b77e7395486845bdd2da5f0757d64d09fe24511814ec54', 0),
('Tóth Bence', '2012-11-05', 'bence.toth@email.com', 'scrypt$3ed639a53b5760b0c901fd22eb6d854d$87db2596918dd09ed27830852e62412c3ac44b50f15b1dbc84e04fc63837f1c509ca3adc91801f79960199033ed5f1cfe2415e80446ee2ad657c3752cd6dae33', 0),        -- 14 éves (2026-ban) -> Kiskorú
('Adminisztrátor', '1980-01-01', 'admin@konyvtar.hu', 'scrypt$8699a5f155220df27d4f24f4c70c6d09$1b07288ada91c8f30b974e6af297fa61341dd1f035cf6fa5767ede5ab1ec0fd8ff575a89525b0d84deebef7e2200b7f04e8a6a2c258c98278c9263868a2ddba0', 1);       -- Admin fiók

-- Minden mintaolvasó kezdeti jelszava: KonyvtarDemo2026! (csak teszteléshez).
-- Csak a hiányzó hash-eket töltjük ki, a meglévő jelszavak megmaradnak.
UPDATE olvasok SET password_hash = 'scrypt$8256a28432e9ac52460151a41d3c7472$8190293b1abbfe09daee302bb973ae387e5cfd25ed4770b5c0c2f46d50d18ac1b2776eb1dbe409e5bcebbf08fb46e8d0c162b34ac2bb2d0b0b5785e1403372e3' WHERE elerhetoseg = 'anna.kovacs@email.com' AND password_hash IS NULL;
UPDATE olvasok SET password_hash = 'scrypt$6789cebc4ce54eef38519efd0d2af146$493a546a3353958d6830ca26b73b18ce02d7ec1eec83be99708bc591caf7e51818ec00dd7f84e78bd2273d4735319734b4d6656a38d55ceff98e9089dee776fa' WHERE elerhetoseg = 'peter.nagy@email.com' AND password_hash IS NULL;
UPDATE olvasok SET password_hash = 'scrypt$1fed562ce33ac1424858c2b06bbe288d$845422ed1b772be8e88dc2ceca8bc8f85e392fdc837b8fb303ecde3aa9c083105ec326b2928c1755e1b77e7395486845bdd2da5f0757d64d09fe24511814ec54' WHERE elerhetoseg = 'eszter.szabo@email.com' AND password_hash IS NULL;
UPDATE olvasok SET password_hash = 'scrypt$3ed639a53b5760b0c901fd22eb6d854d$87db2596918dd09ed27830852e62412c3ac44b50f15b1dbc84e04fc63837f1c509ca3adc91801f79960199033ed5f1cfe2415e80446ee2ad657c3752cd6dae33' WHERE elerhetoseg = 'bence.toth@email.com' AND password_hash IS NULL;
UPDATE olvasok SET password_hash = 'scrypt$8699a5f155220df27d4f24f4c70c6d09$1b07288ada91c8f30b974e6af297fa61341dd1f035cf6fa5767ede5ab1ec0fd8ff575a89525b0d84deebef7e2200b7f04e8a6a2c258c98278c9263868a2ddba0' WHERE elerhetoseg = 'admin@konyvtar.hu' AND password_hash IS NULL;

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
