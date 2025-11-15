CREATE DATABASE superstore_db;
USE superstore_db;

select * from superstore;

-- Count total rows
SELECT COUNT(*) AS total_records FROM superstore;

-- Check distinct years
SELECT YEAR(Order_Date) AS year, COUNT(*) AS cnt
FROM superstore
GROUP BY YEAR(Order_Date)
ORDER BY year;

-- Remove duplicates (example for MySQL; adapt for other DBs)
ALTER TABLE superstore ADD COLUMN row_num INT AUTO_INCREMENT;

DELETE s1 FROM superstore s1
JOIN superstore s2
  ON s1.Order_ID = s2.Order_ID
  AND s1.row_num > s2.row_num;

ALTER TABLE superstore DROP COLUMN row_num;

-- Check for nulls in critical columns
SELECT 
    SUM(CASE WHEN Sales IS NULL THEN 1 ELSE 0 END) AS null_sales,
    SUM(CASE WHEN Profit IS NULL THEN 1 ELSE 0 END) AS null_profit
FROM superstore;

-- Total Sales, Profit & Avg Transaction
SELECT 
    ROUND(SUM(Sales),2) AS total_sales,
    ROUND(SUM(Profit),2) AS total_profit,
    ROUND(AVG(Sales),2) AS average_sales
FROM superstore;

-- Sales & Profit by Category
SELECT 
    Category, 
    ROUND(SUM(Sales),2) AS sales,
    ROUND(SUM(Profit),2) AS profit
FROM superstore
GROUP BY Category
ORDER BY sales DESC;

-- Top Sub-Categories by Profit
SELECT 
    Sub_Category,
    ROUND(SUM(Profit),2) AS total_profit
FROM superstore
GROUP BY Sub_Category
ORDER BY total_profit DESC
LIMIT 10;

-- Yearly Sales & Profit Trend
SELECT 
    YEAR(Order_Date) AS year,
    ROUND(SUM(Sales),2) AS sales,
    ROUND(SUM(Profit),2) AS profit
FROM superstore
GROUP BY YEAR(Order_Date)
ORDER BY year;

-- Region Performance
SELECT 
    Region,
    ROUND(SUM(Sales),2) AS sales,
    ROUND(SUM(Profit),2) AS profit
FROM superstore
GROUP BY Region
ORDER BY sales DESC;

-- Top 10 Customers by Profit
WITH customer_profit AS (
    SELECT 
        Customer_ID,
        Customer_Name,
        SUM(Profit) AS total_profit
    FROM superstore
    GROUP BY Customer_ID, Customer_Name
)
SELECT *
FROM customer_profit
ORDER BY total_profit DESC
LIMIT 10;

-- Running Total Sales over Time
WITH monthly_sales AS (
    SELECT 
        DATE_FORMAT(Order_Date, '%Y-%m') AS ym,
        SUM(Sales) AS sales
    FROM superstore
    GROUP BY DATE_FORMAT(Order_Date, '%Y-%m')
)
SELECT 
    ym,
    sales,
    SUM(sales) OVER (ORDER BY ym) AS cumulative_sales
FROM monthly_sales;

-- RFM Analysis Basic (Recency, Frequency, Monetary)
WITH recency_cte AS (
    SELECT 
        Customer_ID,
        DATEDIFF(MAX(Order_Date), MAX(Order_Date)) AS recency,  -- you would substitute current date
        COUNT(Order_ID) AS frequency,
        SUM(Sales) AS monetary
    FROM superstore
    GROUP BY Customer_ID
)
SELECT *
FROM recency_cte
ORDER BY monetary DESC
LIMIT 10;

-- Sales by Ship Mode
SELECT 
    Ship_Mode,
    ROUND(SUM(Sales),2) AS sales,
    ROUND(SUM(Profit),2) AS profit
FROM superstore
GROUP BY Ship_Mode
ORDER BY profit DESC;

-- Discount vs Profit Relationship
SELECT 
    Discount,
    COUNT(*) AS orders_count,
    ROUND(AVG(Profit),2) AS avg_profit
FROM superstore
GROUP BY Discount
ORDER BY Discount ASC;

-- Best Months (Top Sales) by Year
SELECT 
    YEAR(Order_Date) AS year,
    MONTH(Order_Date) AS month,
    ROUND(SUM(Sales),2) AS sales
FROM superstore
GROUP BY YEAR(Order_Date), MONTH(Order_Date)
ORDER BY year, sales DESC
LIMIT 12;
