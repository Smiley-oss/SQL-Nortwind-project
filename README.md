# SQL-projekti: Northwind-myyntitietokanta

Opiskeluprojekti, jossa ratkaisin 20 SQL-tehtävää myynti- ja tilaustietokannasta (työntekijät, tuotteet, toimittajat, asiakkaat, rahtarit ja tuoteryhmät).

## Tiedostot
- `northwind-answers.sql`: kaikki 20 vastausta SQL-lauseina
- `opiskelu.md`: selitykset omin sanoin jokaisesta tehtävästä
- `SQL_viikkotehtava_3_vastaukset.xlsx`: tehtävälista, johon vastaukset on täytetty

## Mitä opin
- Taulujen yhdistäminen: JOIN useamman taulun yli
- Ryhmittely ja laskenta: GROUP BY, SUM, COUNT, MAX, AVG
- Rajaukset: WHERE, BETWEEN, IN, LIKE, IS NULL
- Alikyselyt: kalleimman tuotteen ja keskihinnan haku
- Järjestys: ORDER BY ASC ja DESC

## Käytetyt taulut
Employees, Products, Suppliers, Categories, Customers, Orders, Order Details, Shippers

## Huomioita
- Myynti on laskettu kaavalla hinta x määrä (alennusta ei ole huomioitu).
- Vastaukset on kirjoitettu perus-SQL:llä. SQL Serverissä LIMIT 1 korvataan sanalla TOP 1.
