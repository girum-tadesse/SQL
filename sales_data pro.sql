
select *
from [sales_data ]


--cheking unique values
select distinct STATUS from [sales_data ] --good for plot
select distinct YEAR_ID FROM [sales_data ]
select distinct PRODUCTLINE from [sales_data]-- good for plot
select distinct COUNTRY from [sales_data ] --good for plot
select distinct DEALSIZE from [sales_data ]
select distinct TERRITORY from [sales_data ] --good for plot

-- Analysis
--Grouping by 
SELECT PRODUCTLINE, SUM(SALES) as total_sales
FROM [sales_data ]
GROUP BY PRODUCTLINE
ORDER BY 2 DESC 

SELECT YEAR_ID, SUM(SALES) as total_sales
FROM [sales_data ]
GROUP BY YEAR_ID
ORDER BY 2 DESC

SELECT DEALSIZE, SUM(SALES) as total_sales
FROM [sales_data ]
GROUP BY DEALSIZE
ORDER BY 2 DESC

--month with the highst sales in a sepcific year
SELECT  MONTH_ID, SUM(SALES) total_sales,COUNT(ORDERNUMBER) friquancy
FROM [sales_data ]Y
WHERE YEAR_ID = 2004
GROUP BY  MONTH_ID
ORDER BY  2 DESC

--November seems to be the month with the highst sales so what product did they sale the most in November
SELECT  PRODUCTLINE, SUM(SALES) total_sales, COUNT(ORDERLINENUMBER) friquency
FROM [sales_data ]
WHERE YEAR_ID = 2004 AND MONTH_ID = 11
GROUP BY  MONTH_ID, PRODUCTLINE
ORDER BY 2 DESC

-- who is our bast costumer
DROP TABLE IF EXISTS #rfm
;WITH rfm AS
(
SELECT CUSTOMERNAME,
    SUM(SALES) MonetryValue,
	AVG(SALES) AvgMonetryValue,
	COUNT(ORDERNUMBER)Friquency,
	MAX(ORDERDATE) LastOrdeDate,
	(SELECT MAX(ORDERDATE) FROM [sales_data ]) max_order_date,
	DATEDIFF(DD,MAX(ORDERDATE), (SELECT MAX(ORDERDATE) FROM [sales_data ])) Recency
FROM [sales_data ]
GROUP BY CUSTOMERNAME 
),
rfm_calc AS 
(
SELECT r. *,
NTILE(4) OVER (ORDER BY Recency DESC) rfm_recency,
NTILE(4) OVER (ORDER BY Friquency ) rfm_Friquency,
NTILE(4) OVER (ORDER BY MonetryValue ) rfm_Monetry
FROM rfm r
)
SELECT C. *,rfm_recency + rfm_Friquency + rfm_Monetry AS rfm_cells,
       CAST(rfm_recency as varchar) + CAST(rfm_Friquency AS varchar) + CAST(rfm_monetry AS varchar) rfm_cell_string
INTO #rfm
FROM rfm_calc c 

SELECT CUSTOMERNAME  ,rfm_recency,rfm_Friquency,rfm_Monetry, 
     CASE
       WHEN rfm_cell_string in(111,112,121,122,123,132,211,212,114,141) THEN 'lost customer'
       WHEN rfm_cell_string in(133,134,143,244,334,343,344) THEN 'slipping away cannot lose'
       WHEN rfm_cell_string in(311,411,331) THEN 'new customers'
       WHEN rfm_cell_string in(222,223,233,322) THEN 'potential churners'
       WHEN rfm_cell_string in(323,333,321,422,432) THEN 'active'
       WHEN rfm_cell_string in(433,434,433,344) THEN 'loyal'
     END 
FROM #rfm 