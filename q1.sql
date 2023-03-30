-- First sub query that prepares the pre calculation data:
-- 1- Days since last order which will be used to calculate recency score
-- 2- Number of orders which is used to calculate frequency score
-- 3- Monetary value which consists of the sum of quantity * price of each item
WITH RFM_scores AS
(SELECT customerid,
 (SELECT MAX(invoicedate) FROM online_retail) - MAX(invoicedate) as days_since_last_order
, COUNT(*) AS num_orders
, SUM(quantity * unitprice) AS monetary
FROM online_retail
WHERE quantity > 0 AND unitprice > 0 AND customerid != ''
GROUP BY customerid) , segment_calc AS
(SELECT*,
NTILE(5) OVER(ORDER BY days_since_last_order DESC) AS r_score
, NTILE(5) OVER(ORDER BY num_orders) AS f_score
, NTILE(5) OVER(ORDER BY monetary) AS m_score
, ROUND((NTILE(5) OVER(ORDER BY num_orders) + NTILE(5) OVER(ORDER BY monetary))/2 , 0) AS fm_score
FROM RFM_scores)
SELECT
customerid
, days_since_last_order AS Recency
, num_orders AS Frequency
, monetary
, r_score
, f_score
, fm_score
, CASE 
		WHEN (
				r_score = 5
				AND fm_score = 5
				)
			OR (
				r_score = 5
				AND fm_score = 4
				)
			OR (
				r_score = 4
				AND fm_score = 5
				)
			THEN 'Champion'
		WHEN (
				r_score = 5
				AND fm_score = 2
				)
			OR (
				r_score = 4
				AND fm_score = 2
				)
			OR (
				r_score = 3
				AND fm_score = 3
				)
			OR (
				r_score = 4
				AND fm_score = 3
				)
			THEN 'Potential Loyalist'
		WHEN (
				r_score = 5
				AND fm_score = 3
				)
			OR (
				r_score = 4
				AND fm_score = 4
				)
			OR (
				r_score = 3
				AND fm_score = 5
				)
			OR (
				r_score = 3
				AND fm_score = 4
				)
			THEN 'Loyal Customer'
		WHEN (
				r_score = 5
				AND fm_score = 1
				)
			THEN 'Recent Customer'
		WHEN (
				r_score = 4
				AND fm_score = 1
				)
			OR (
				r_score = 3
				AND fm_score = 1
				)
			THEN 'Promising'
		WHEN (
				r_score = 3
				AND fm_score = 2
				)
			OR (
				r_score = 2
				AND fm_score = 3
				)
			OR (
				r_score = 2
				AND fm_score = 2
				)
			THEN 'Customer Needing Attention'
		WHEN (
				r_score = 5
				AND fm_score = 5
				)
			OR (
				r_score = 5
				AND fm_score = 4
				)
			OR (
				r_score = 4
				AND fm_score = 5
				)
			THEN 'At Risk'
		WHEN (
				r_score = 2
				AND fm_score = 5
				)
			OR (
				r_score = 2
				AND fm_score = 4
				)
			OR (
				r_score = 1
				AND fm_score = 3
				)
			THEN 'Cant Lose Them'
		WHEN (
				r_score = 1
				AND fm_score = 5
				)
			OR (
				r_score = 1
				AND fm_score = 2
				)
			THEN 'Hibernating'
		WHEN (
				r_score = 1
				AND fm_score = 1
			)
			THEN 'Lost'
		END AS group_name
FROM segment_calc
