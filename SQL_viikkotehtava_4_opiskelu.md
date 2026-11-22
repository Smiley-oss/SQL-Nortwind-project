# SQL viikkotehtävä 4: opiskelumuistiinpanot

Tehtävät on tehty Northwind-tietokannalla (NWIND). Työkalu on Letos ja kanta on **SQLite**. Komennot ovat tiedostossa `SQL_viikkotehtava_4.sql`.

> **Tärkein oppi:** SQL-kielessä on murteita. Sama asia kirjoitetaan eri tavalla MySQL:ssä, SQL Serverissä ja SQLitessä. Siksi `DATEDIFF` antoi virheen `no such function`. Se ei kuulu SQLiteen.

| Asia | MySQL / SQL Server | SQLite (tämä kurssi) |
|---|---|---|
| Päivien erotus | `DATEDIFF(...)` | `julianday(loppu) - julianday(alku)` |
| Vuosi päivämäärästä | `YEAR(pvm)` | `strftime('%Y', pvm)` |
| Tekstien yhdistäminen | `CONCAT(a, b)` | `a \|\| b` |
| Transaktion aloitus | `START TRANSACTION` | `BEGIN TRANSACTION` |

---

## 1. Päivämäärät ja laskeminen (tehtävät 1–5, 8)

### Tehtävät 1 ja 2: tilausten laskeminen ajalta

```sql
SELECT COUNT(*) AS Tilauksia FROM Orders WHERE OrderDate < '2020-01-01';
```

- `COUNT(*)` laskee rivit. `WHERE` rajaa, mitkä rivit lasketaan.
- SQLitessä päivämäärä on tekstiä muodossa `'VVVV-KK-PP'`. Tämä muoto vertautuu oikein aakkosjärjestyksessä.
- `BETWEEN a AND b` ottaa mukaan molemmat ääripäät. Jos `OrderDate` sisältää kellonajan, 28.2.2021 klo 14:00 jäisi pois. Silloin kannattaa käyttää muotoa `< '2021-03-01'`.

### Tehtävä 3: keskimääräinen toimitusaika

```sql
SELECT AVG(julianday(ShippedDate) - julianday(OrderDate)) AS KeskimPaivia FROM Orders;
```

- `julianday()` muuttaa päivämäärän luvuksi (päiviä tietystä aloituspäivästä). Lukujen vähennys antaa päivien erotuksen.
- `AVG` ohittaa rivit, joilla `ShippedDate` on NULL, eli tilaukset, joita ei ole vielä toimitettu.

### Tehtävä 4: nuorimman ja vanhimman työntekijän ikäero

- `MAX(BirthDate)` on **nuorin**, koska syntymäaika on myöhäisin.
- `MIN(BirthDate)` on **vanhin**.
- Erotus lasketaan `julianday`-funktiolla päivinä, ja jaettuna luvulla `365.25` vuosina.
- `CAST(... AS INTEGER)` pyöristää desimaalit pois.

### Tehtävä 5: kuka oli vanhin aloittaessaan

- Ikä aloitushetkellä on `(julianday(HireDate) - julianday(BirthDate)) / 365.25`.
- `ORDER BY ... DESC LIMIT 1` järjestää suurimman ensin ja ottaa vain yhden rivin.

### Tehtävä 8: vanhimman tilauksen toimitusaika

- "Vanhin tilaus" tarkoittaa pienintä `OrderDate`-arvoa: `ORDER BY OrderDate ASC LIMIT 1`.
- Tästä rivistä lasketaan päivien erotus. Tulkinta on mielestäni tämä, mutta kysy tarvittaessa opettajalta.

---

## 2. Summat, JOINit ja apunäkymä (tehtävät 6, 7)

Myyntisumma lasketaan tilausriveiltä:

```
summa = UnitPrice * Quantity * (1 - Discount)
```

Tarvittavat taulut yhdistetään JOINilla:

| Tarve | Taulu | Liitos |
|---|---|---|
| Hinta, määrä, alennus | `"Order Details"` | |
| Tilauspäivä | `Orders` | `od.OrderID = o.OrderID` |
| Tuotteen nimi | `Products` | `od.ProductID = p.ProductID` |
| Toimittajan maa | `Suppliers` | `p.SupplierID = s.SupplierID` |

Samat neljä JOINia tarvitaan molemmissa tehtävissä. Siksi tein niistä **apunäkymän** `Myyntirivit`:

```sql
CREATE VIEW Myyntirivit AS
SELECT od.OrderID, o.OrderDate, od.ProductID, p.ProductName,
       s.Country AS ToimittajaMaa, od.UnitPrice, od.Quantity, od.Discount,
       od.UnitPrice * od.Quantity * (1 - od.Discount) AS Summa
FROM "Order Details" od
JOIN Orders o    ON od.OrderID = o.OrderID
JOIN Products p  ON od.ProductID = p.ProductID
JOIN Suppliers s ON p.SupplierID = s.SupplierID;
```

Sen jälkeen kyselyt ovat lyhyitä, eikä JOINeja tarvitse kirjoittaa uudelleen:

```sql
SELECT SUM(Summa) FROM Myyntirivit
WHERE ProductName = 'Maxilaku' AND strftime('%Y', OrderDate) = '2020';   -- 6

SELECT SUM(Summa) FROM Myyntirivit
WHERE ToimittajaMaa = 'Germany' AND OrderDate < '2020-01-01';            -- 7
```

- Taulun nimessä on väli, joten se kirjoitetaan lainausmerkeissä: `"Order Details"`.
- `strftime` palauttaa tekstin, joten vuosi on lainausmerkeissä.
- "Saksalainen tuote" tarkoittaa, että **toimittajan** maa on `Germany`.
- Näkymä tehdään **ennen** tehtävää 9, jotta tehtävän 20 `ROLLBACK` ei poista sitä. Se ei ole osa tehtävänantoa, joten mainitse raportissa, että se on lisäapu. Voit poistaa sen lopuksi komennolla `DROP VIEW Myyntirivit;`.
- Jos `Discount`-saraketta ei ole, jätä `* (1 - od.Discount)` pois.

---

## 3. Tapahtumanhallinta eli transaktiot (tehtävät 9, 20)

```sql
BEGIN TRANSACTION;   -- tehtävä 9
...muutokset...
ROLLBACK;            -- tehtävä 20: peruu kaiken
-- tai COMMIT;       -- vahvistaa pysyvästi
```

- Transaktion sisällä muutokset eivät ole vielä pysyviä.
- `ROLLBACK` peruu kaiken `BEGIN TRANSACTION` -komennon jälkeen. SQLitessä se peruu myös `CREATE VIEW` -komennot, koska SQLiten DDL on mukana transaktiossa.
- Tarkista lopuksi, että muutokset todella peruuntuivat: `SELECT * FROM Shippers;` ja `SELECT ProductName, UnitsInStock, UnitPrice FROM Products;`.
- Letos voi olla asetettu tallentamaan muutokset automaattisesti. Jos `ROLLBACK` ei näytä peruvan mitään, tarkista Letosin kommitointiasetus.

---

## 4. Rivien lisäys, muutos ja poisto (tehtävät 10–17)

| Tehtävä | Komento | Mitä se tekee |
|---|---|---|
| 10 | `INSERT INTO Shippers (...) VALUES (...)` | lisää uuden rahtarin |
| 11 | `UPDATE ... SET Phone = ... WHERE ...` | muuttaa puhelinnumeron |
| 12 | `SET ShipperName = ShipperName \|\| 'j'` | lisää nimen perään kirjaimen |
| 13 | `DELETE FROM Shippers WHERE ...` | poistaa rahtarin |
| 14 | `SET UnitsInStock = UnitsInStock + 43` | kasvattaa saldoa |
| 15 | `SET UnitsInStock = ROUND(UnitsInStock * (1 - 0.43))` | pienentää saldoa 43 % |
| 16 | `SET UnitPrice = ROUND(UnitPrice * 1.15, 2)` | nostaa hintaa 15 % |

**Muista aina `WHERE`!** Ilman sitä `UPDATE` ja `DELETE` koskevat **kaikkia** rivejä. Transaktio auttaa tässä, koska virheen voi perua.

- `||` yhdistää tekstit SQLitessä.
- Pienennys 43 % on kertominen luvulla `1 - 0.43 = 0.57`. Korotus 15 % on kertominen luvulla `1.15`.
- Tehtävä 16: Saksalaiset tuotteet haetaan aliselvityksellä: `WHERE SupplierID IN (SELECT SupplierID FROM Suppliers WHERE Country = 'Germany')`.

### Tehtävä 17: United Packagen poisto ("Mitä tapahtui ja miksi?")

Kirjoita raporttiin se, mitä sinun Letoksesi näytti. Mahdollisia tuloksia on kaksi:

1. **Virhe** `FOREIGN KEY constraint failed`. Tilaukset viittaavat rahtariin vierasavaimella, ja United Packagella on jo tilauksia. Tietokanta estää poiston, jotta tilaukset eivät jää viittaamaan olemattomaan riviin (eheys).
2. **Poisto onnistuu.** SQLitessä vierasavainten tarkistus on oletuksena pois päältä (`PRAGMA foreign_keys` on 0). Silloin rahtari katoaa, ja tilauksiin jää viittaus rahtariin, jota ei enää ole. Se on tietoeheyden kannalta huono tilanne.

Voit ottaa tarkistuksen käyttöön komennolla `PRAGMA foreign_keys = ON;`. Se pitää ajaa **ennen** transaktion aloitusta, koska SQLite ei muuta sitä kesken transaktion. Aja sen jälkeen tehtävä 17 uudestaan, niin näet virheen.

Samin Salama Oyj voitiin poistaa (tehtävä 13), koska sillä ei ollut yhtään tilausta.

---

## 5. Näkymät (tehtävät 18, 19)

```sql
CREATE VIEW Tuotesummat AS
SELECT ProductID, SUM(UnitPrice * Quantity * (1 - Discount)) AS Summa
FROM "Order Details"
GROUP BY ProductID;
```

- Näkymä on **tallennettu SELECT-kysely**. Se ei sisällä omaa dataa, vaan tiedot haetaan aina uudelleen alkuperäisistä tauluista.
- `GROUP BY` ryhmittelee rivit tuotteittain (tai tilauksittain tehtävässä 19). `SUM` laskee summan kullekin ryhmälle.
- `AS Summa` antaa sarakkeelle nimen, jonka tehtävä vaatii.
- Näkymää käytetään kuten taulua: `SELECT * FROM Tuotesummat;`.

---

## Kertauskysymykset

1. Miksi `DATEDIFF` ei toimi SQLitessä, ja mitä käytetään tilalla?
2. Mikä on ero `MIN(BirthDate)`- ja `MAX(BirthDate)`-arvoilla vanhimman ja nuorimman kannalta?
3. Mitä tapahtuu, jos unohdat `WHERE`-ehdon `UPDATE`-komennosta?
4. Mitä vierasavain tekee, ja miksi `PRAGMA foreign_keys` vaikuttaa tehtävään 17?
5. Mitä `ROLLBACK` peruu SQLitessä?
6. Miksi näkymä ei vie levytilaa samalla tavalla kuin taulu?

---

## Uudet komennot tällä viikolla

`julianday`, `strftime`, `CAST`, `ROUND`, `||`, `BEGIN TRANSACTION`, `ROLLBACK`, `COMMIT`, `CREATE VIEW`, aliselvitys (`IN (SELECT ...)`), `PRAGMA foreign_keys`.
