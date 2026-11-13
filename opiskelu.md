# SQL-opiskelumuistiinpanot

Tässä jokaisen tehtävän vastaus selitettynä omin sanoin, jotta ymmärrän miksi se toimii.

## Perusasiat ennen tehtäviä

- **SELECT** valitsee sarakkeet, **FROM** kertoo taulun.
- **WHERE** rajaa rivit.
- **JOIN ... ON** yhdistää kaksi taulua yhteisen id:n avulla.
- **GROUP BY** ryhmittelee rivit, ja SUM, COUNT, MAX ja AVG laskevat jokaiselle ryhmälle.
- **ORDER BY** järjestää: ASC pienin ensin, DESC suurin ensin.
- Tyhjä arvo tarkistetaan **IS NULL**.

## Miten taulut liittyvät toisiinsa

```
Customers -> Orders -> [Order Details] -> Products -> Categories
                |                            |
            Employees                    Suppliers
                |
            Shippers (Orders.ShipVia)
```

---

## Tehtävä 1

**Kysymys:** Hae sen työntekijän nimi, jolla ei ole esimiestä.

```sql
SELECT FirstName, LastName
FROM Employees
WHERE ReportsTo IS NULL;
```

**Miten ajattelin:** Kysytään työntekijää, jolla ei ole pomoa. Pomon id on sarakkeessa ReportsTo, joten jos se on tyhjä, pomoa ei ole.

**Muista:** Tyhjää ei voi verrata merkillä =. Käytä aina IS NULL.

## Tehtävä 2

**Kysymys:** Tulosta kaikki 10-15 hintavälillä olevat tuotteet, jotka ovat kotoisin Ranskasta tai Yhdysvalloista ja sisältävät c-kirjaimen

```sql
SELECT p.ProductName, p.UnitPrice, s.Country
FROM Products p
JOIN Suppliers s ON p.SupplierID = s.SupplierID
WHERE p.UnitPrice BETWEEN 10 AND 15
  AND s.Country IN ('France', 'USA')
  AND p.ProductName LIKE '%c%';
```

**Miten ajattelin:** Tuotteen kotimaa on toimittajalla (Suppliers), joten yhdistän Products ja Suppliers. Sitten kolme ehtoa: hinta 10-15, maa Ranska tai USA ja nimessä on c.

**Muista:** BETWEEN sisältää molemmat päät. LIKE '%c%' tarkoittaa että c on missä vain nimessä. Yhdysvallat on tietokannassa 'USA'.

## Tehtävä 3

**Kysymys:** Listaa myyjät kokonaismyynnin mukaiseen järjestykseen. Vähiten myynyt ensiksi.

```sql
SELECT e.FirstName, e.LastName,
       SUM(od.UnitPrice * od.Quantity) AS Myynti
FROM Employees e
JOIN Orders o ON o.EmployeeID = e.EmployeeID
JOIN [Order Details] od ON od.OrderID = o.OrderID
GROUP BY e.EmployeeID, e.FirstName, e.LastName
ORDER BY Myynti ASC;
```

**Miten ajattelin:** Myyjä on Employees. Hänen tilauksensa ovat Orders ja rivit Order Details. Myynti on hinta kertaa määrä, ja SUM laskee ne yhteen jokaiselle myyjälle.

**Muista:** Kun käytät SUM:ia, tarvitset GROUP BY. ASC = pienin ensin, DESC = suurin ensin.

## Tehtävä 4

**Kysymys:** Millä summalla olemme myyneet juomia?

```sql
SELECT SUM(od.UnitPrice * od.Quantity) AS JuomienMyynti
FROM [Order Details] od
JOIN Products p ON p.ProductID = od.ProductID
JOIN Categories c ON c.CategoryID = p.CategoryID
WHERE c.CategoryName = 'Beverages';
```

**Miten ajattelin:** Juomat ovat tuoteryhmä Beverages. Yhdistän rivit tuotteisiin ja tuotteet ryhmiin, rajaan juomiin ja lasken summan.

**Muista:** Tässä ei tarvita GROUP BY:ta, koska haluan vain yhden luvun.

## Tehtävä 5

**Kysymys:** Listaa tuotteet kokonaismyynnin mukaiseen järjestykseen. Vähiten myynyt ensiksi.

```sql
SELECT p.ProductName,
       SUM(od.UnitPrice * od.Quantity) AS Myynti
FROM Products p
JOIN [Order Details] od ON od.ProductID = p.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY Myynti ASC;
```

**Miten ajattelin:** Sama idea kuin tehtävässä 3, mutta ryhmittelen tuotteen mukaan.

**Muista:** Tuotteet, joita ei ole koskaan myyty, eivät näy, koska JOIN ottaa vain ne joilla on rivejä.

## Tehtävä 6

**Kysymys:** Mikä tuoteryhmämme myy vähiten?

```sql
SELECT c.CategoryName,
       SUM(od.UnitPrice * od.Quantity) AS Myynti
FROM Categories c
JOIN Products p ON p.CategoryID = c.CategoryID
JOIN [Order Details] od ON od.ProductID = p.ProductID
GROUP BY c.CategoryID, c.CategoryName
ORDER BY Myynti ASC
LIMIT 1;
```

**Miten ajattelin:** Lasken myynnin jokaiselle tuoteryhmälle, järjestän pienimmästä ja otan vain ensimmäisen rivin.

**Muista:** LIMIT 1 ottaa yhden rivin. SQL Serverissä kirjoita SELECT TOP 1 ... ja poista LIMIT 1.

## Tehtävä 7

**Kysymys:** Kenen toimittajan tuotteita olemme myyneet eniten?

```sql
SELECT s.CompanyName,
       SUM(od.UnitPrice * od.Quantity) AS Myynti
FROM Suppliers s
JOIN Products p ON p.SupplierID = s.SupplierID
JOIN [Order Details] od ON od.ProductID = p.ProductID
GROUP BY s.SupplierID, s.CompanyName
ORDER BY Myynti DESC
LIMIT 1;
```

**Miten ajattelin:** Toimittaja > tuotteet > tilausrivit. Summaan myynnin toimittajittain ja järjestän suurimmasta.

**Muista:** Eniten = DESC. Sama LIMIT / TOP -huomio kuin tehtävässä 6.

## Tehtävä 8

**Kysymys:** Millä summalla olemme myyneet Save-a-lot Marketsille?

```sql
SELECT SUM(od.UnitPrice * od.Quantity) AS Myynti
FROM Customers c
JOIN Orders o ON o.CustomerID = c.CustomerID
JOIN [Order Details] od ON od.OrderID = o.OrderID
WHERE c.CompanyName = 'Save-a-lot Markets';
```

**Miten ajattelin:** Etsin asiakkaan nimellä, yhdistän tämän tilaukset ja rivit ja lasken summan.

**Muista:** Tekstit kirjoitetaan yksinkertaisiin lainausmerkkeihin.

## Tehtävä 9

**Kysymys:** Mihin maahan olemme myyneet rahallisesti eniten?

```sql
SELECT o.ShipCountry,
       SUM(od.UnitPrice * od.Quantity) AS Myynti
FROM Orders o
JOIN [Order Details] od ON od.OrderID = o.OrderID
GROUP BY o.ShipCountry
ORDER BY Myynti DESC
LIMIT 1;
```

**Miten ajattelin:** Maa, johon tilaus lähetettiin, on Orders-taulussa sarakkeessa ShipCountry. Summaan myynnin maittain.

**Muista:** Voisi käyttää myös asiakkaan maata (Customers.Country). Tässä käytin toimitusmaata, koska kysytään mihin myytiin.

## Tehtävä 10

**Kysymys:** Kuka rahtareista on rahdannut lukumäärällisesti eniten tilauksia?

```sql
SELECT sh.CompanyName,
       COUNT(*) AS Tilauksia
FROM Shippers sh
JOIN Orders o ON o.ShipVia = sh.ShipperID
GROUP BY sh.ShipperID, sh.CompanyName
ORDER BY Tilauksia DESC
LIMIT 1;
```

**Miten ajattelin:** Rahtari on Shippers. Orders-taulun ShipVia kertoo rahtarin id. Lasken tilaukset rahtareittain.

**Muista:** Lukumäärä = COUNT, ei SUM. Liitoksen ehto on ShipVia = ShipperID, eri nimiset sarakkeet.

## Tehtävä 11

**Kysymys:** Tulosta kaikki Maxilakua tilanneet asiakkaat (nimet).

```sql
SELECT DISTINCT c.CompanyName
FROM Customers c
JOIN Orders o ON o.CustomerID = c.CustomerID
JOIN [Order Details] od ON od.OrderID = o.OrderID
JOIN Products p ON p.ProductID = od.ProductID
WHERE p.ProductName = 'Maxilaku';
```

**Miten ajattelin:** Maxilaku on tuote. Kuljen ketjun asiakas > tilaus > rivi > tuote ja otan asiakkaiden nimet.

**Muista:** DISTINCT poistaa tuplat, koska sama asiakas on voinut tilata monta kertaa.

## Tehtävä 12

**Kysymys:** Kuinka monta sellaista tavarantoimittajaa meillä on, joiden alue (region) on tyhjä.

```sql
SELECT COUNT(*) AS Toimittajia
FROM Suppliers
WHERE Region IS NULL;
```

**Miten ajattelin:** Lasken toimittajat, joiden Region on tyhjä.

**Muista:** Taas IS NULL. Jos tietokannassa tyhjä on '' eikä NULL, kokeile Region = ''.

## Tehtävä 13

**Kysymys:** Tulosta kaikki Save-a-lot Marketsia palvelleet henkilöt.

```sql
SELECT DISTINCT e.FirstName, e.LastName
FROM Employees e
JOIN Orders o ON o.EmployeeID = e.EmployeeID
JOIN Customers c ON c.CustomerID = o.CustomerID
WHERE c.CompanyName = 'Save-a-lot Markets';
```

**Miten ajattelin:** Palvelleet henkilöt ovat myyjiä (Employees), jotka ovat hoitaneet tämän asiakkaan tilauksia.

**Muista:** DISTINCT tarvitaan, jotta sama myyjä ei tule monta kertaa.

## Tehtävä 14

**Kysymys:** Listaa asiakkaat kokonaismyynnin mukaiseen järjestykseen. Eniten ostanut ensiksi.

```sql
SELECT c.CompanyName,
       SUM(od.UnitPrice * od.Quantity) AS Myynti
FROM Customers c
JOIN Orders o ON o.CustomerID = c.CustomerID
JOIN [Order Details] od ON od.OrderID = o.OrderID
GROUP BY c.CustomerID, c.CompanyName
ORDER BY Myynti DESC;
```

**Miten ajattelin:** Sama kuin tehtävä 3, mutta asiakkaittain ja suurin ensin.

**Muista:** Eniten ostanut ensin = DESC.

## Tehtävä 15

**Kysymys:** Tulosta kalleimman tuotteemme nimi ja hinta.

```sql
SELECT ProductName, UnitPrice
FROM Products
WHERE UnitPrice = (SELECT MAX(UnitPrice) FROM Products);
```

**Miten ajattelin:** Sisempi kysely hakee suurimman hinnan, ulompi hakee tuotteen jolla on se hinta.

**Muista:** Tämä toimii myös jos kaksi tuotetta on yhtä kalliita.

## Tehtävä 16

**Kysymys:** Kuinka monella tavarantoimittajallamme ei ole nettisivua?

```sql
SELECT COUNT(*) AS IlmanNettisivua
FROM Suppliers
WHERE HomePage IS NULL;
```

**Miten ajattelin:** Lasken toimittajat, joiden HomePage on tyhjä.

**Muista:** Sama idea kuin tehtävässä 12.

## Tehtävä 17

**Kysymys:** Tulosta kunkin tuoteryhmän kallein hinta.

```sql
SELECT c.CategoryName, MAX(p.UnitPrice) AS KalleinHinta
FROM Categories c
JOIN Products p ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryID, c.CategoryName;
```

**Miten ajattelin:** MAX hakee suurimman hinnan, ja GROUP BY tekee sen jokaiselle ryhmälle erikseen.

**Muista:** MAX, MIN, SUM, COUNT ja AVG tarvitsevat GROUP BY:n kun halutaan ryhmittäin.

## Tehtävä 18

**Kysymys:** Mihin tuoteryhmään kuuluu lukumäärällisesti eniten myynnissä olevia tuotteita?

```sql
SELECT c.CategoryName, COUNT(*) AS Tuotteita
FROM Categories c
JOIN Products p ON p.CategoryID = c.CategoryID
WHERE p.Discontinued = 0
GROUP BY c.CategoryID, c.CategoryName
ORDER BY Tuotteita DESC
LIMIT 1;
```

**Miten ajattelin:** Myynnissä olevat tuotteet = Discontinued on 0. Lasken ne ryhmittäin ja otan suurimman.

**Muista:** WHERE rajaa rivit ennen ryhmittelyä. Discontinued = 0 tarkoittaa että tuote on vielä myynnissä.

## Tehtävä 19

**Kysymys:** Tulosta kaikki keskihintaa kalliimmat myynnissä olevat Saksalaiset tuotteet.

```sql
SELECT p.ProductName, p.UnitPrice
FROM Products p
JOIN Suppliers s ON s.SupplierID = p.SupplierID
WHERE s.Country = 'Germany'
  AND p.Discontinued = 0
  AND p.UnitPrice > (SELECT AVG(UnitPrice) FROM Products);
```

**Miten ajattelin:** Kolme ehtoa: toimittaja on Saksasta, tuote on myynnissä ja hinta on yli kaikkien tuotteiden keskihinnan.

**Muista:** Keskihinta lasketaan tässä kaikista tuotteista. Jos opettaja tarkoittaa vain saksalaisten keskihintaa, lisää sisempään kyselyyn sama Germany-ehto.

## Tehtävä 20

**Kysymys:** Kuinka montaa tuotetta myydään pulloissa (bottle)?

```sql
SELECT COUNT(*) AS PullotuoteMaara
FROM Products
WHERE QuantityPerUnit LIKE '%bottle%';
```

**Miten ajattelin:** Pakkaustapa on sarakkeessa QuantityPerUnit, ja siinä lukee esim. '24 - 12 oz bottles'. Haen ne joissa on sana bottle.

**Muista:** Jos haluat vain myynnissä olevat, lisää AND Discontinued = 0.

