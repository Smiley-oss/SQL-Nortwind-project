-- SQL viikkotehtävä 4: Northwind (NWIND), SQLite / Letos
-- Ajetaan järjestyksessä 1 -> 20. Selitykset: SQL_viikkotehtava_4_opiskelu.md

-- Tehtävä 1: Laske kuinka monta tilausta on tehty ennen vuotta 2020
SELECT COUNT(*) AS Tilauksia
FROM Orders
WHERE OrderDate < '2020-01-01';

-- Tehtävä 2: Laske kuinka monta tilausta on tehty välillä 1.6.2020-28.2.2021
SELECT COUNT(*) AS Tilauksia
FROM Orders
WHERE OrderDate BETWEEN '2020-06-01' AND '2021-02-28';

-- Tehtävä 3: Tilaukset: kuinka monta päivää kesti keskimäärin tilauksesta toimitukseen?
SELECT AVG(julianday(ShippedDate) - julianday(OrderDate)) AS KeskimPaivia
FROM Orders;

-- Tehtävä 4: Laske mikä on nuorimman ja vanhimman työntekijämme ikäero
SELECT CAST(julianday(MAX(BirthDate)) - julianday(MIN(BirthDate)) AS INTEGER) AS IkaeroPaivina,
       ROUND((julianday(MAX(BirthDate)) - julianday(MIN(BirthDate))) / 365.25, 1) AS IkaeroVuosina
FROM Employees;

-- Tehtävä 5: Selvitä kuka työntekijöistämme oli vanhin aloittaessaan työnsä palveluksessamme
SELECT FirstName, LastName, BirthDate, HireDate,
       CAST((julianday(HireDate) - julianday(BirthDate)) / 365.25 AS INTEGER) AS IkaAloittaessa
FROM Employees
ORDER BY IkaAloittaessa DESC
LIMIT 1;

-- Tehtävä 6: Laske millä summalla Maxilakua on myyty vuoden 2020 aikana
-- Apunäkymä (tehdään ennen tehtävää 9, jotta ROLLBACK ei poista sitä). JOINit kirjoitetaan vain kerran.
CREATE VIEW Myyntirivit AS
SELECT od.OrderID,
       o.OrderDate,
       od.ProductID,
       p.ProductName,
       s.Country AS ToimittajaMaa,
       od.UnitPrice,
       od.Quantity,
       od.Discount,
       od.UnitPrice * od.Quantity * (1 - od.Discount) AS Summa
FROM "Order Details" od
JOIN Orders o    ON od.OrderID = o.OrderID
JOIN Products p  ON od.ProductID = p.ProductID
JOIN Suppliers s ON p.SupplierID = s.SupplierID;

SELECT SUM(Summa) AS Summa
FROM Myyntirivit
WHERE ProductName = 'Maxilaku'
  AND strftime('%Y', OrderDate) = '2020';

-- Tehtävä 7: Laske millä summalla Saksalaisia tuotteita on myyty ennen vuotta 2020
SELECT SUM(Summa) AS Summa
FROM Myyntirivit
WHERE ToimittajaMaa = 'Germany'
  AND OrderDate < '2020-01-01';

-- Tehtävä 8: Kuinka monta päivää on kesti vanhimman tilauksen tilauksesta toimitukseen?
SELECT OrderID, OrderDate, ShippedDate,
       CAST(julianday(ShippedDate) - julianday(OrderDate) AS INTEGER) AS Paivia
FROM Orders
ORDER BY OrderDate ASC
LIMIT 1;

-- Tehtävä 9: Laita tapahtumanhallinta päälle
BEGIN TRANSACTION;

-- Tehtävä 10: Lisää uusi rahtari. Samin Salama Oy, puhelin 050-9874561
INSERT INTO Shippers (ShipperName, Phone)
VALUES ('Samin Salama Oy', '050-9874561');

-- Tehtävä 11: Muuta Samin puhelinnumeroksi 050-1478963
UPDATE Shippers
SET Phone = '050-1478963'
WHERE ShipperName = 'Samin Salama Oy';

-- Tehtävä 12: Lisää Samin Salama Oy perään kirjain j
UPDATE Shippers
SET ShipperName = ShipperName || 'j'
WHERE ShipperName = 'Samin Salama Oy';

-- Tehtävä 13: Poista Samin Salama Oyj
DELETE FROM Shippers
WHERE ShipperName = 'Samin Salama Oyj';

-- Tehtävä 14: Kasvata Lakkaliköörin varastosaldoa 43:lla pullolla
UPDATE Products
SET UnitsInStock = UnitsInStock + 43
WHERE ProductName = 'Lakkalikööri';

-- Tehtävä 15: Pienennä Lakkaliköörin varastosaldoa 43 prosentilla
UPDATE Products
SET UnitsInStock = ROUND(UnitsInStock * (1 - 0.43))
WHERE ProductName = 'Lakkalikööri';

-- Tehtävä 16: Nosta kaikkien Saksalaisten tuotteiden hintaa 15%. Pyöristä 2 des.
UPDATE Products
SET UnitPrice = ROUND(UnitPrice * 1.15, 2)
WHERE SupplierID IN (SELECT SupplierID FROM Suppliers WHERE Country = 'Germany');

-- Tehtävä 17: Poista rahtari United Package. (Mitä tapahtui ja miksi?)
DELETE FROM Shippers
WHERE ShipperName = 'United Package';
-- Katso opiskelumuistiinpanot: tulos riippuu siitä, onko foreign_keys päällä.

-- Tehtävä 18: Tee näkymä Tuotesummat, jossa on ProductID ja Summa kentät
CREATE VIEW Tuotesummat AS
SELECT ProductID,
       SUM(UnitPrice * Quantity * (1 - Discount)) AS Summa
FROM "Order Details"
GROUP BY ProductID;

-- Tehtävä 19: Tee näkymä Tilaussummat, jossa on OrderID ja Summa kentät
CREATE VIEW Tilaussummat AS
SELECT OrderID,
       SUM(UnitPrice * Quantity * (1 - Discount)) AS Summa
FROM "Order Details"
GROUP BY OrderID;

-- Tehtävä 20: Peruuta kaikki tekemäsi muutokset
ROLLBACK;
-- Myyntirivit-apunäkymä on tehty ennen transaktiota, joten se jää. Poista halutessasi: DROP VIEW Myyntirivit;
