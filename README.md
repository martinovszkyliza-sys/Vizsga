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




Adatbázis??(min 3 tábla)
Könyvek
●	könyvid(p.key)
●	író(string)
●	cím(string)
●	szépirodalom/szakirodalom(lehetne őket külön táblára??)
●	műfaj(string)
●	oldalszám(int)
●	kiadásiév(int?date?)
●	nyelv(string)
●	kiadó(string)
● 	(borítóképek)????(lehet képet mysqlbe rakni????)

Olvasó
●	név(string)
●	születésidátum(date?)
●	elérhetőség(string)
●	törzsszám(p.key)

Kölcsönzések
●	kölcsönid(p.key)
●	könyvid(f.key)
●	törzsszám(f.key)
●	kölcsöndátum(date)
●	kölcsönhatáridő(date)




lehetséges ötlet könyvfelvétel??

index oldalon látható
●	sötét/világos mód beállítása(csuszka/radiobutton?)
●	belépés gomb (átrak másik oldalra)
○	név
○	törzsszám
○	ha bármelyik textbox üres send alert message!!
○	=>belépés után megjelenik a főoldalon egy kikölcsönzött könyvek gomb
■	könyv adatai
■	kölcsöndátum
■	kölcsönhatáridő
●	regisztráció gomb (átrak másik oldalra)
○	név
○	születési dátum
○	elérhetőség
○	ha bármelyik textbox üres send alert message!!
○	(törzsszámot kap valahogy??)
●	író
●	cím
●	műfaj
●	kiadásiév
●	nyelv
●	kiadó
●	csak kölcsönözhető checkbox (alapból az összes könyv kereshető, így csak azok amiket éppen ki lehet kölcsönözni)
●	keresés gomb (átrak a találatok oldalra)-min 1 textbox kitöltése, ha minden textbox üres send alert message!!
●	nap könyve?(random generált)=>főoldalon (jobb oldalt?) nap kiemelt könyve(borító,cím, író,(?link ami átrak a könyv adataihoz?))



admin oldal
●	könyvek adatainak felvétele, törlése, szerkesztése
●	olvasók adatainak felvétele, törlése, szerkesztése
●	könyvek státuszmódosítása(kölcsönzött//kölcsönözhető)? (szerintem lehet automatikusan is?)






regisztráció/bejelentkezés/keresésnél ha üresen hagy textboxot send alert!!

lejárt könyvekről emailt küld????
mobilon is működjön!!!!

tiszta kód elvei szerint !? 





