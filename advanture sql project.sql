create database advantureworks;
use advantureworks;

show tables;

select * from factinternetsales;
### union factinternetsales and fact_internet_sales_new
select * 
from factinternetsales
union all
select * 
from fact_internet_sales_new;
### adding product name
select 
f.*,
p.englishproductname
from factinternetsales f
left join dimproduct p
on f.productkey = p.productkey;
select 
f.productkey
from factinternetsales f
left join dimproduct p
on f.productkey = p.productkey
where p.productkey is null;
### checking factinternetsales rows
select count(*) from factinternetsales;
### checking dimproduct rows
select count(*) from dimproduct;
### checking null count
select count(*)
from factinternetsales f
left join dimproduct p
on f.productkey = p.productkey
where p.productkey is null;
select
f.*,
p.englishproductname
from factinternetsales f
inner join dimproduct p
on f.productkey = p.productkey;
### custumer fullname product sheet ,unit price from the product sheet
select
f.*,
concat(c.firstname,' ',c.lastname) as
customerfullname,
p.`unit price` as unitprice
from factinternetsales f
left join dimcustomer c
on f.customerkey = c.customerkey
left join dimproduct p
on f.productkey = p.productkey;

use advantureworks;
## Q.3. Creating Data Field from OrderDateKey
SELECT OrderDateKey,
STR_TO_DATE(OrderDateKey, '%Y%m%d') AS OrderDate,
YEAR(STR_TO_DATE(OrderDateKey, '%Y%m%d')) AS Year,
MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')) AS MonthNo,
DATE_FORMAT(STR_TO_DATE(OrderDateKey, '%Y%m%d'), '%M') AS MonthFullName,
CONCAT('Q', QUARTER(STR_TO_DATE(OrderDateKey, '%Y%m%d'))) AS Quarter,
DATE_FORMAT(STR_TO_DATE(OrderDateKey, '%Y%m%d'), '%Y-%b') AS YearMonth,
WEEKDAY(STR_TO_DATE(OrderDateKey, '%Y%m%d')) + 1 AS WeekdayNo,
DATE_FORMAT(STR_TO_DATE(OrderDateKey, '%Y%m%d'), '%W') AS WeekdayName,

## financial month 
CASE
	WHEN MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')) >= 4
	THEN MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')) - 3
	ELSE MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')) + 9
END AS FinancialMonth,

    ## financial quarter 
CASE
	WHEN MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')) IN (4,5,6) THEN 'Q1'
	WHEN MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')) IN (7,8,9) THEN 'Q2'
	WHEN MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')) IN (10,11,12) THEN 'Q3'
	ELSE 'Q4'
END AS FinancialQuarter

FROM FactInternetSales;

## Q.4. Sales Amount Calculation

SELECT ProductKey, OrderQuantity, UnitPrice, UnitPriceDiscountPct, DiscountAmount, (UnitPrice * OrderQuantity) - DiscountAmount AS SalesAmount

FROM FactInternetSales;

## Q.5. Production Cost Calculation

SELECT f.ProductKey, f.OrderQuantity, p.StandardCost AS UnitCost, (p.StandardCost * f.OrderQuantity) AS ProductionCost

FROM FactInternetSales f

LEFT JOIN DimProduct p
ON f.ProductKey = p.ProductKey;

## Q.6. Profit Calculation

SELECT f.ProductKey, f.OrderQuantity, f.UnitPrice, p.StandardCost, (f.UnitPrice * f.OrderQuantity * (1 - f.UnitPriceDiscountPct)) AS SalesAmount,
(p.StandardCost * f.OrderQuantity) AS ProductionCost, 
((f.UnitPrice * f.OrderQuantity * (1 - f.UnitPriceDiscountPct)) - (p.StandardCost * f.OrderQuantity)) AS Profit

FROM FactInternetSales f

LEFT JOIN DimProduct p
ON f.ProductKey = p.ProductKey;

## Q.7. Month-wise Sales

SELECT YEAR(STR_TO_DATE(OrderDateKey,'%Y%m%d')) AS Year,
MONTH(STR_TO_DATE(OrderDateKey,'%Y%m%d')) AS MonthNo,
MONTHNAME(STR_TO_DATE(OrderDateKey,'%Y%m%d')) AS Month,
SUM(SalesAmount) AS TotalSales

FROM FactInternetSales

GROUP BY Year, MonthNo, Month
ORDER BY Year, MonthNo;

## Q.8. Year wise sales
SELECT
YEAR(STR_TO_DATE(OrderDateKey,'%Y%m%d')) AS Year,
SUM(SalesAmount) AS TotalSales

FROM FactInternetSales

GROUP BY Year
ORDER BY Year;

## Q.9. Quarter wise sales
SELECT
CONCAT('Q', QUARTER(STR_TO_DATE(OrderDateKey,'%Y%m%d'))) AS Quarter,
SUM(SalesAmount) AS TotalSales

FROM FactInternetSales

GROUP BY Quarter
ORDER BY Quarter;

##8. Year-wise Sales (Bar Chart)
SELECT
    YEAR(OrderDate) AS SalesYear,
    SUM(SalesAmount) AS TotalSales
FROM Sales
GROUP BY YEAR(OrderDate)
ORDER BY SalesYear;

##9. Month-wise Sales (Line Chart)
SELECT
    DATENAME(MONTH, OrderDate) AS MonthName,
    MONTH(OrderDate) AS MonthNo,
    SUM(SalesAmount) AS TotalSales
FROM Sales
GROUP BY
    MONTH(OrderDate),
    DATENAME(MONTH, OrderDate)
ORDER BY MonthNo;

##10. Quarter-wise Sales (Pie Chart)
SELECT
    CONCAT('Q', DATEPART(QUARTER, OrderDate)) AS Quarter,
    SUM(SalesAmount) AS TotalSales
FROM Sales
GROUP BY DATEPART(QUARTER, OrderDate)
ORDER BY Quarter;

##11. Combination Chart (Sales Amount vs Production Cost)
SELECT
    YEAR(OrderDate) AS SalesYear,
    SUM(SalesAmount) AS TotalSales,
    SUM(ProductionCost) AS TotalProductionCost
FROM Sales
GROUP BY YEAR(OrderDate)
ORDER BY SalesYear;

##12. KPI / Charts
##a) Product Performance
SELECT
    ProductName,
    SUM(SalesAmount) AS TotalSales
FROM Sales
GROUP BY ProductName
ORDER BY TotalSales DESC;
##b) Customer Performance
SELECT
    CustomerName,
    SUM(SalesAmount) AS TotalSales
FROM Sales
GROUP BY CustomerName
ORDER BY TotalSales DESC;

##c) Region Performance
SELECT
    Region,
    SUM(SalesAmount) AS TotalSales
FROM Sales
GROUP BY Region
ORDER BY TotalSales DESC;

##d) Total Sales KPI
SELECT
    SUM(SalesAmount) AS TotalSales
FROM Sales;

##e) Total Production Cost KPI
SELECT
    SUM(ProductionCost) AS TotalProductionCost
FROM Sales;

##f) Profit KPI
SELECT
    SUM(SalesAmount - ProductionCost) AS TotalProfit
FROM Sales;

##g) Number of Customers
SELECT
    COUNT(DISTINCT CustomerID) AS TotalCustomers
FROM Sales;

##h) Number of Products Sold
SELECT
    COUNT(DISTINCT ProductID) AS TotalProducts
FROM Sales;































