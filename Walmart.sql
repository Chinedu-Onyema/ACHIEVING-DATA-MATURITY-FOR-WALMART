# WALMART SALES ANALYSIS WITH THE STRUCTURED QUERY LANGUAGE (SQL)
# IN THIS ANALYSIS, I WILL ANALYZE THE DATA OF A POPULAR STORE CALLED 
# 'WALMART' WHICH WILL GIVE THE ME THE NECESSARY INSIGHTS.


-- Create a database called WALMART to house the datasets.
CREATE DATABASE IF NOT EXISTS walmart;
USE walmart;

-- create a table called SALES DATA and it columns
CREATE TABLE IF NOT EXISTS sales_data(
    invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
	branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
	date DATE NOT NULL,
    time TIME NOT NULL,
	payment_method VARCHAR(15) NOT NULL,
    rating FLOAT(2, 1),
    unit_price DECIMAL(10, 2) NOT NULL,
    quantity_sold INT NOT NULL);
    
    SELECT * FROM sales_data;
    DESCRIBE sales_data;
    
    
----- FEATURE_ENGINEERING: allows us "ADD A NEW COLUMN" to an already existing "table" from already existing "columns" ----
----- ADDING FACT COLUMNS USING MATHEMATICAL CALCULATIONS -----
 
 # ADDING THE COST OF GOODS SOLD (COGS) COLUMN
 # BY MULTIPLYING THE UNIT PRICE BY THE QUANTITY SOLD
SELECT
      unit_price,
      quantity_sold
FROM sales_data;

ALTER TABLE sales_data
ADD COLUMN COGS DECIMAL(10, 2);

SET SQL_SAFE_UPDATES = 0;
UPDATE sales_data
SET COGS = unit_price * quantity_sold;

SELECT COGS FROM sales_data;


# ADDING THE VAT COLUMN WHICH IS 5% OF COGS
SELECT
	COGS * 0.05 AS COGS
FROM sales_data;

ALTER TABLE sales_data
ADD COLUMN VAT FLOAT(6, 4) NOT NULL;

UPDATE sales_data
SET VAT = COGS * 0.05;

SELECT * FROM sales_data;
SELECT VAT FROM sales_data;


# ADDING THE GROSS PROFIT COLUMN
# BY SUMMING THE COGS COLUMN TO VAT COLUMN
SELECT * FROM sales_data;
SELECT
   COGS + VAT AS gross_profit
FROM sales_data;

ALTER TABLE sales_data
ADD COLUMN gross_profit DECIMAL(12, 4) NOT NULL;

UPDATE sales_data
SET gross_profit = COGS + VAT;

SELECT * FROM sales_data;
SELECT gross_profit FROM sales_data;


# ADDING THE NET PROFIT COLUMN
# BY SUBSTRACTING THE COGS COLUMN FROM THE VAT COLUMN
SELECT * FROM sales_data;
SELECT
   COGS - VAT AS net_profit
FROM sales_data;

ALTER TABLE sales_data
ADD COLUMN net_profit DECIMAL(12, 4) NOT NULL;

UPDATE sales_data
SET net_profit = COGS - VAT;

SELECT * FROM sales_data;
SELECT gross_profit FROM sales_data;



----- ADDING LOOK UP COLUMNS -----

# ADDING THE TIME OF THE DAY COLUMN
SELECT * FROM sales_data;
SELECT 
	time,
    (CASE
        WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END    
    ) AS time_of_the_day       
FROM sales_data;

ALTER TABLE sales_data
ADD COLUMN time_of_the_day VARCHAR(20);

UPDATE sales_data
SET time_of_the_day = (
    CASE
        WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END    
    );
SELECT time_of_the_day FROM sales_data;  


# ADDING THE DAY NAME COLUMN
SELECT * FROM sales_data;
SELECT 
    date,
    DAYNAME(date) AS day_name
FROM sales_data;

ALTER TABLE sales_data
ADD COLUMN day_name VARCHAR(10);

UPDATE sales_data
SET day_name = DAYNAME(date);

SELECT day_name FROM sales_data;


# ADDING THE MONTH NAME COLUMN
SELECT * FROM sales_data;
SELECT 
    date,
    MONTHNAME(date) AS months
FROM sales_data;

ALTER TABLE sales_data
ADD COLUMN month_name VARCHAR(15);

UPDATE sales_data
SET month_name = MONTHNAME(date);

SELECT month_name FROM sales_data;
SELECT * FROM sales_data;


----- BUSINESS QUESTIONS TO ANSWER --------------

-- GENERIC QUESTIONS ---
# 1) How many unique cities are in MYANMAR?
SELECT * FROM sales_data;
SELECT 
	DISTINCT city
FROM sales_data;


# 2) In which city is each branch?
SELECT * FROM sales_data;
SELECT
    DISTINCT city,
    branch
FROM sales_data;
    

-- PRODUCT QUESTIONS --
# 1) How many unique product lines does the sales data have?
SELECT * FROM sales_data;
SELECT
     product_line,
     COUNT(DISTINCT product_line) AS product_count
FROM sales_data
GROUP BY product_line;


# 2) What is the most common payment method?
SELECT * FROM sales_data;
SELECT
    payment_method,
    COUNT(payment_method) AS count
FROM sales_data
GROUP BY payment_method
ORDER BY count DESC;


# 3) What is the most selling product line?
SELECT * FROM sales_data;
SELECT 
	product_line,
    COUNT(product_line) AS product_line_count
FROM sales_data
GROUP BY product_line
ORDER BY product_line_count DESC;


# 4) What is the total revenue by month?
SELECT * FROM sales_data;
SELECT
    month_name AS month,
    SUM(net_profit) AS total_revenue
FROM sales_data
GROUP BY month_name
ORDER BY total_revenue DESC;


# 5) What month had the largest COGS (cost of goods sold)?
SELECT * FROM sales_data;
SELECT 
	month_name AS month,
    SUM(cogs) AS cogs
FROM sales_data
GROUP BY month_name
ORDER BY cogs DESC;


# 6) What product line had the largest revenue?
SELECT * FROM sales_data;
SELECT
    product_line,
    SUM(gross_profit) AS revenue_before_VAT,
    SUM(net_profit) AS revenue_after_VAT
FROM sales_data
GROUP BY product_line
ORDER BY revenue_before_VAT DESC,
	     revenue_after_VAT;
         

# 7) What is the city with the largest revenue?
SELECT * FROM sales_data;
SELECT
    branch,
    city,
    SUM(gross_profit) AS revenue_before_VAT,
    SUM(net_profit) AS revenue_after_VAT
FROM sales_data
GROUP BY branch, city
ORDER BY revenue_before_VAT DESC,
	     revenue_after_VAT;
    
    
# 8) What product line had the largest VAT?
SELECT * FROM sales_data; 
SELECT
    product_line,
    AVG(VAT) AS avg_tax,
    SUM(VAT) AS total_tax
FROM sales_data
GROUP BY product_line
ORDER BY avg_tax DESC;


# 9) Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average profit
SELECT * FROM sales_data;
SELECT AVG(net_profit) FROM sales_data;

SELECT
    product_line,
    AVG(net_profit) AS avg_profit
FROM sales_data
GROUP BY product_line;

SELECT 
    product_line,
    AVG(net_profit) AS avg_profit,
    (CASE
        WHEN AVG(net_profit) > '291.78470905'  THEN "Good"
        ELSE "Bad"
    END    
    ) AS product_line_status      
FROM sales_data
GROUP BY product_line
ORDER BY avg_profit DESC;

ALTER TABLE sales_data
ADD COLUMN product_line_status VARCHAR(10);

UPDATE sales_data
SET product_line_status = CASE
						  WHEN '291.78470905' < (SELECT AVG(net_profit))  THEN "Good"
                          ELSE "Bad"
                          END;
                          

SELECT  product_line_status FROM sales_data;
SELECT * FROM sales_data;

SELECT 
	product_line,
	product_line_status,
    AVG(net_profit) AS avg_profit
FROM sales_data
GROUP BY product_line, product_line_status
ORDER BY avg_profit DESC;


# 10) Which branch sold more products quantity than average product quantity sold? 
SELECT * FROM sales_data;
SELECT 
    branch,
    AVG(quantity_sold) AS avg_quantity,
    SUM(quantity_sold) AS total_quantity
FROM sales_data
GROUP BY branch
HAVING SUM(quantity_sold) > (SELECT AVG(quantity_sold) FROM sales_data)
ORDER BY avg_quantity DESC;


# 11) What is the most common product line by gender?
SELECT * FROM sales_data;
SELECT
    gender,
    product_line,
    COUNT(gender) AS total_count
FROM sales_data
GROUP BY gender, product_line
ORDER BY total_count DESC;


# 12) What is the average rating of each product line?
SELECT * FROM sales_data;
SELECT
	product_line,
    ROUND(AVG(rating),2) AS avg_rating
FROM sales_data
GROUP BY product_line
ORDER BY avg_rating DESC;



-- SALES QUESTIONS --

# 1) Number of sales made in each time of the day per weekday?
SELECT * FROM sales_data;
SELECT
    time_of_the_day,
    day_name,
    COUNT(*) AS total_sales
FROM sales_data
# WHERE day_name = 'Monday'
GROUP BY time_of_the_day, day_name
ORDER BY total_sales DESC;


# 2) Which of the customer types brings the most revenue?
SELECT * FROM sales_data;
SELECT
    customer_type,
    SUM(gross_profit)AS revenue_before_VAT,
    SUM(net_profit) AS revenue_after_VAT
FROM sales_data
GROUP BY customer_type
ORDER BY revenue_before_VAT DESC,
		 revenue_after_VAT;


# 3) Which city pays the highest tax percent / VAT (Value Added Tax)?
SELECT *FROM sales_data;
SELECT
    city,
    AVG(VAT) AS AVG_VAT,
    SUM(VAT) AS TOTAL_VAT
FROM sales_data
GROUP BY city
ORDER BY AVG_VAT DESC,
         TOTAL_VAT;


# 4) Which customer type pays the most in VAT?
SELECT * FROM sales_data;
SELECT
    customer_type,
     AVG(VAT) AS AVG_VAT,
    SUM(VAT) AS TOTAL_VAT
FROM sales_data
GROUP BY customer_type
ORDER BY AVG_VAT DESC,
		 TOTAL_VAT;
         

-- CUSTOMER QUESTIONS --
# 1) How many unique customer types does the data have, --
# What is the most common customer type & --
# Which customer type buys the most? --
# Questions 1, 3 and 4 answered at a go in question 1.

SELECT * FROM sales_data;
SELECT
    DISTINCT customer_type,
    COUNT(*) AS customer_count
FROM sales_data
GROUP BY customer_type
ORDER BY customer_type;


# 2) How many unique payment methods does the data have?
SELECT * FROM sales_data;
SELECT
    DISTINCT payment_method,
    COUNT(payment_method) AS payment_counts
FROM sales_data
GROUP BY payment_method
ORDER BY payment_counts DESC;


# 5) What is the gender of most of the customers?
SELECT * FROM sales_data;
SELECT
    gender,
    COUNT(*) AS gender_count
FROM sales_data
GROUP BY gender
ORDER BY gender DESC;


# 6) What is the gender distribution per branch?
SELECT * FROM sales_data;
SELECT
    gender,
    COUNT(*) AS gender_count
FROM sales_data
 WHERE branch = 'A'
# WHERE branch = 'B'
# WHERE branch = 'C'
GROUP BY gender
ORDER BY gender_count DESC;


# 7) Which time of the day do customers give the most ratings?
SELECT * FROM sales_data;
SELECT
	time_of_the_day,
    SUM(rating) AS total_rating,
    AVG(rating) AS avg_rating
FROM sales_data
GROUP BY time_of_the_day
ORDER BY total_rating DESC,
          avg_rating DESC;



# 8) Which time of the day do customers give most ratings per branch?
SELECT * FROM sales_data;
SELECT
	branch,
	time_of_the_day,
    SUM(rating) AS total_rating,
    AVG(rating) AS avg_rating
FROM sales_data
# WHERE branch = 'A'
# WHERE branch = 'B'
# WHERE branch = 'C'
GROUP BY time_of_the_day, branch
ORDER BY total_rating DESC,
          avg_rating DESC;
          

# 9) Which day of the week has the best average and total ratings?
SELECT * FROM sales_data;
SELECT
	day_name,
    AVG(rating) AS avg_rating,
    SUM(rating) AS total_rating
FROM sales_data
GROUP BY day_name
ORDER BY total_rating DESC,
         avg_rating DESC;
         
         
# 10) Which day of the week has the best average and total ratings per branch?
SELECT * FROM sales_data;
SELECT
	day_name,
    branch,
    AVG(rating) AS avg_rating,
    SUM(rating) AS total_rating
FROM sales_data
# WHERE branch = 'A'
# WHERE branch = 'B'
# WHERE branch = 'C'
GROUP BY day_name, branch
ORDER BY avg_rating DESC;
