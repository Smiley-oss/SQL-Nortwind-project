-- SQL viikkotehtävä 3: Northwind-tietokanta
-- Vastaukset 1-20. Taulut: Employees, Products, Suppliers, Categories,
-- Customers, Orders, [Order Details], Shippers.
-- Huom: LIMIT 1 toimii MySQL/PostgreSQL/SQLite. SQL Serverissä käytä SELECT TOP 1.
-- Myynti = UnitPrice * Quantity (alennusta ei huomioida).

-- 1. Hae sen työntekijän nimi, jolla ei ole esimiestä.
SELECT FirstName, LastName
FROM Employees
WHERE ReportsTo IS NULL;

-- 2. Tulosta kaikki 10-15 hintavälillä olevat tuotteet, jotka ovat kotoisin Ranskasta tai Yhdysvalloista ja sisältävät c-kirjaimen
SELECT p.ProductName, p.UnitPrice, s.Country
FROM Products p
JOIN Suppliers s ON p.SupplierID = s.SupplierID
WHERE p.UnitPrice BETWEEN 10 AND 15
  AND s.Country IN ('France', 'USA')
  AND p.ProductName LIKE '%c%';

-- 3. Listaa myyjät kokonaismyynnin mukaiseen järjestykseen. Vähiten myynyt ensiksi.
SELECT e.FirstName, e.LastName,
       SUM(od.UnitPrice * od.Quantity) AS Myynti
FROM Employees e
JOIN Orders o ON o.EmployeeID = e.EmployeeID
JOIN [Order Details] od ON od.OrderID = o.OrderID
GROUP BY e.EmployeeID, e.FirstName, e.LastName
ORDER BY Myynti ASC;

-- 4. Millä summalla olemme myyneet juomia?
SELECT SUM(od.UnitPrice * od.Quantity) AS JuomienMyynti
FROM [Order Details] od
JOIN Products p ON p.ProductID = od.ProductID
JOIN Categories c ON c.CategoryID = p.CategoryID
WHERE c.CategoryName = 'Beverages';

-- 5. Listaa tuotteet kokonaismyynnin mukaiseen järjestykseen. Vähiten myynyt ensiksi.
SELECT p.ProductName,
       SUM(od.UnitPrice * od.Quantity) AS Myynti
FROM Products p
JOIN [Order Details] od ON od.ProductID = p.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY Myynti ASC;

-- 6. Mikä tuoteryhmämme myy vähiten?
SELECT c.CategoryName,
       SUM(od.UnitPrice * od.Quantity) AS Myynti
FROM Categories c
JOIN Products p ON p.CategoryID = c.CategoryID
JOIN [Order Details] od ON od.ProductID = p.ProductID
GROUP BY c.CategoryID, c.CategoryName
ORDER BY Myynti ASC
LIMIT 1;

-- 7. Kenen toimittajan tuotteita olemme myyneet eniten?
SELECT s.CompanyName,
       SUM(od.UnitPrice * od.Quantity) AS Myynti
FROM Suppliers s
JOIN Products p ON p.SupplierID = s.SupplierID
JOIN [Order Details] od ON od.ProductID = p.ProductID
GROUP BY s.SupplierID, s.CompanyName
ORDER BY Myynti DESC
LIMIT 1;

-- 8. Millä summalla olemme myyneet Save-a-lot Marketsille?
SELECT SUM(od.UnitPrice * od.Quantity) AS Myynti
FROM Customers c
JOIN Orders o ON o.CustomerID = c.CustomerID
JOIN [Order Details] od ON od.OrderID = o.OrderID
WHERE c.CompanyName = 'Save-a-lot Markets';

-- 9. Mihin maahan olemme myyneet rahallisesti eniten?
SELECT o.ShipCountry,
       SUM(od.UnitPrice * od.Quantity) AS Myynti
FROM Orders o
JOIN [Order Details] od ON od.OrderID = o.OrderID
GROUP BY o.ShipCountry
ORDER BY Myynti DESC
LIMIT 1;

-- 10. Kuka rahtareista on rahdannut lukumäärällisesti eniten tilauksia?
SELECT sh.CompanyName,
       COUNT(*) AS Tilauksia
FROM Shippers sh
JOIN Orders o ON o.ShipVia = sh.ShipperID
GROUP BY sh.ShipperID, sh.CompanyName
ORDER BY Tilauksia DESC
LIMIT 1;

-- 11. Tulosta kaikki Maxilakua tilanneet asiakkaat (nimet).
SELECT DISTINCT c.CompanyName
FROM Customers c
JOIN Orders o ON o.CustomerID = c.CustomerID
JOIN [Order Details] od ON od.OrderID = o.OrderID
JOIN Products p ON p.ProductID = od.ProductID
WHERE p.ProductName = 'Maxilaku';

-- 12. Kuinka monta sellaista tavarantoimittajaa meillä on, joiden alue (region) on tyhjä.
SELECT COUNT(*) AS Toimittajia
FROM Suppliers
WHERE Region IS NULL;

-- 13. Tulosta kaikki Save-a-lot Marketsia palvelleet henkilöt.
SELECT DISTINCT e.FirstName, e.LastName
FROM Employees e
JOIN Orders o ON o.EmployeeID = e.EmployeeID
JOIN Customers c ON c.CustomerID = o.CustomerID
WHERE c.CompanyName = 'Save-a-lot Markets';

-- 14. Listaa asiakkaat kokonaismyynnin mukaiseen järjestykseen. Eniten ostanut ensiksi.
SELECT c.CompanyName,
       SUM(od.UnitPrice * od.Quantity) AS Myynti
FROM Customers c
JOIN Orders o ON o.CustomerID = c.CustomerID
JOIN [Order Details] od ON od.OrderID = o.OrderID
GROUP BY c.CustomerID, c.CompanyName
ORDER BY Myynti DESC;

-- 15. Tulosta kalleimman tuotteemme nimi ja hinta.
SELECT ProductName, UnitPrice
FROM Products
WHERE UnitPrice = (SELECT MAX(UnitPrice) FROM Products);

-- 16. Kuinka monella tavarantoimittajallamme ei ole nettisivua?
SELECT COUNT(*) AS IlmanNettisivua
FROM Suppliers
WHERE HomePage IS NULL;

-- 17. Tulosta kunkin tuoteryhmän kallein hinta.
SELECT c.CategoryName, MAX(p.UnitPrice) AS KalleinHinta
FROM Categories c
JOIN Products p ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryID, c.CategoryName;

-- 18. Mihin tuoteryhmään kuuluu lukumäärällisesti eniten myynnissä olevia tuotteita?
SELECT c.CategoryName, COUNT(*) AS Tuotteita
FROM Categories c
JOIN Products p ON p.CategoryID = c.CategoryID
WHERE p.Discontinued = 0
GROUP BY c.CategoryID, c.CategoryName
ORDER BY Tuotteita DESC
LIMIT 1;

-- 19. Tulosta kaikki keskihintaa kalliimmat myynnissä olevat Saksalaiset tuotteet.
SELECT p.ProductName, p.UnitPrice
FROM Products p
JOIN Suppliers s ON s.SupplierID = p.SupplierID
WHERE s.Country = 'Germany'
  AND p.Discontinued = 0
  AND p.UnitPrice > (SELECT AVG(UnitPrice) FROM Products);

-- 20. Kuinka montaa tuotetta myydään pulloissa (bottle)?
SELECT COUNT(*) AS PullotuoteMaara
FROM Products
WHERE QuantityPerUnit LIKE '%bottle%';

