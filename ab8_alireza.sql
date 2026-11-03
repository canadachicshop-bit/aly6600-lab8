-- =====================================================
-- ALY6600 Lab Assignment 8
-- Task 1 and Task 2 queries
-- =====================================================

-- -----------------------------------------------------
-- Task 1: Single CTE
-- Which customers spent more than the average customer?
-- The average is taken over customer totals, not payments.
-- -----------------------------------------------------
WITH customer_totals AS (
  SELECT
    customer_id,
    SUM(amount) AS total_spent
  FROM `sakila-aly6600.sakila.payment`
  GROUP BY customer_id
)
SELECT
  customer_id,
  total_spent
FROM customer_totals
WHERE total_spent > (SELECT AVG(total_spent) FROM customer_totals)
ORDER BY total_spent DESC;


-- -----------------------------------------------------
-- Task 2: Chained CTEs
-- Top five cities by number of above-average-spending
-- customers, with revenue from those customers.
-- -----------------------------------------------------
WITH customer_spend AS (
  -- Step 1: total spend per customer
  SELECT
    customer_id,
    SUM(amount) AS total_spent
  FROM `sakila-aly6600.sakila.payment`
  GROUP BY customer_id
),
above_avg_customers AS (
  -- Step 2: customers above the average total
  SELECT
    customer_id,
    total_spent
  FROM customer_spend
  WHERE total_spent > (SELECT AVG(total_spent) FROM customer_spend)
),
customer_city AS (
  -- Step 3: city for each above-average customer
  SELECT
    aac.customer_id,
    aac.total_spent,
    ct.city_id,
    ct.city
  FROM above_avg_customers AS aac
    INNER JOIN `sakila-aly6600.sakila.customer` AS c  ON aac.customer_id = c.customer_id
    INNER JOIN `sakila-aly6600.sakila.address`  AS a  ON c.address_id = a.address_id
    INNER JOIN `sakila-aly6600.sakila.city`     AS ct ON a.city_id = ct.city_id
)
-- Final step: aggregate by city, rank, keep top five
SELECT
  city,
  COUNT(*)         AS above_avg_customer_count,
  SUM(total_spent) AS revenue_from_above_avg
FROM customer_city
GROUP BY city_id, city
ORDER BY above_avg_customer_count DESC,
         revenue_from_above_avg DESC
LIMIT 5;
