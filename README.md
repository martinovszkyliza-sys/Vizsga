# Vizsga
Martinovszky Liza
Fehér Elizabet Anna

web
Könyvtár/Könyvkölcsönzés (terv)

●	elérhető könyvek 
●	kikölcsönzött könyvek, kölcsönzés dátuma+határideje
●	könyvkeresés cím/író/műfaj szerint
○	csak a kölcsönözhetők (checkbox)
●	felhasználó regisztrál
○	csak név és születési dátum szükséges
○	törzsszám
●	felhasználói bejelentkezés
○	név+törzsszámmal
○	meg tudja nézni a kikölcsönzött könyveit+kölcsönzési dátum+határidő
●	felnőtt könyveket csak felnőttek láthatják
○	alapból nem látszanak, csak bejelentkezés után (ha felnőtt)


●	szépirodalom/szakirodalom külön tábla??

Adatbázis??(min 3 tábla)
Könyvek
●	könyvid(p.key)
●	író
●	cím
●	műfaj
●	oldalszám
●	kiadásiév
●	nyelv
●	kiadó

Olvasó
●	név
●	születésidátum
●	elérhetőség
●	törzsszám(p.key)

Kölcsönzések
●	kölcsönid(p.key)
●	könyvid(f.key)
●	törzsszám(f.key)
●	kölcsöndátum
●	kölcsönhatáridő




lehetséges ötlet könyvfelvétel??

index oldalon látható
●	sötét/világos mód beállítása
●	belépés gomb (átrak másik oldalra)
○	név
○	törzsszám
○	=>belépés után megjelenik a főoldalon egy kikölcsönzött könyvek gomb
■	könyv adatai
■	kölcsöndátum
■	kölcsönhatáridő
●	regisztráció gomb (átrak másik oldalra)
○	név
○	születési dátum
○	elérhetőség
○	(törzsszámot kap valahogy??)
●	író
●	cím
●	műfaj
●	kiadásiév
●	nyelv
●	kiadó
●	csak kölcsönözhető checkbox
●	keresés gomb (átrak a találatok oldalra)



admin oldal
●	felvétel
●	törlés
●	státuszmódosítás
●	szerkesztés






regisztráció/bejelentkezés/keresésnél ha üresen hagy textboxot send alert!!

lejárt könyvekről emailt küld????
mobilon is működjön!!!!

tiszta kód elvei szerint !? 
nap könyve?(random generált)

++borítóképek!!!!
