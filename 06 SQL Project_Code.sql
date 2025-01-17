/*

-----------------------------------------------------------------------------------------------------------------------------------
                                               Guidelines
-----------------------------------------------------------------------------------------------------------------------------------

The provided document is a guide for the project. Follow the instructions and take the necessary steps to finish
the project in the SQL file			

-----------------------------------------------------------------------------------------------------------------------------------

                                                         Queries
                                               
-----------------------------------------------------------------------------------------------------------------------------------*/

-- 1. WRITE A QUERY TO DISPLAY CUSTOMER FULL NAME WITH THEIR TITLE (MR/MS), BOTH FIRST NAME AND LAST NAME ARE IN UPPER CASE WITH 
-- CUSTOMER EMAIL ID, CUSTOMER CREATIONDATE AND DISPLAY CUSTOMER’S CATEGORY AFTER APPLYING BELOW CATEGORIZATION RULES:
	-- i.IF CUSTOMER CREATION DATE YEAR <2005 THEN CATEGORY A
    -- ii.IF CUSTOMER CREATION DATE YEAR >=2005 AND <2011 THEN CATEGORY B
    -- iii.IF CUSTOMER CREATION DATE YEAR>= 2011 THEN CATEGORY C
    
    -- HINT: USE CASE STATEMENT, NO PERMANENT CHANGE IN TABLE REQUIRED. [NOTE: TABLES TO BE USED -ONLINE_CUSTOMER TABLE]

WITH TITLE AS (
SELECT 
    CUSTOMER_ID,
    CASE 
    WHEN CUSTOMER_GENDER = 'F' THEN 'MS.'
    WHEN CUSTOMER_GENDER = 'M' THEN 'MR.' END AS TITLE_COL
FROM
    ONLINE_CUSTOMER)
    
SELECT 
CONCAT(TITLE.TITLE_COL,' ', UPPER(CUSTOMER_FNAME),' ',UPPER(CUSTOMER_LNAME)) AS 'FULL NAME',
CUSTOMER_EMAIL AS 'EMAIL', CUSTOMER_CREATION_DATE AS 'CREATION DATE',
CASE
	WHEN YEAR(CUSTOMER_CREATION_DATE) < 2005 THEN 'A'
    WHEN YEAR(CUSTOMER_CREATION_DATE) >= 2005 AND YEAR(CUSTOMER_CREATION_DATE) < 2011 THEN 'B'
    WHEN YEAR(CUSTOMER_CREATION_DATE) >= 2011 THEN 'C'
    END AS CATEGORY
FROM 
ONLINE_CUSTOMER 
JOIN 
TITLE ON ONLINE_CUSTOMER.CUSTOMER_ID = TITLE.CUSTOMER_ID
LIMIT 5;


-- 2. WRITE A QUERY TO DISPLAY THE FOLLOWING INFORMATION FOR THE PRODUCTS, WHICH HAVE NOT BEEN SOLD:  PRODUCT_ID, PRODUCT_DESC, 
-- PRODUCT_QUANTITY_AVAIL, PRODUCT_PRICE,INVENTORY VALUES(PRODUCT_QUANTITY_AVAIL*PRODUCT_PRICE), NEW_PRICE AFTER APPLYING DISCOUNT 
-- AS PER BELOW CRITERIA. SORT THE OUTPUT WITH RESPECT TO DECREASING VALUE OF INVENTORY_VALUE.
	-- i.IF PRODUCT PRICE > 20,000 THEN APPLY 20% DISCOUNT
    -- ii.IF PRODUCT PRICE > 10,000 THEN APPLY 15% DISCOUNT
    -- iii.IF PRODUCT PRICE =< 10,000 THEN APPLY 10% DISCOUNT
    
    -- HINT: USE CASE STATEMENT, NO PERMANENT CHANGE IN TABLE REQUIRED. [NOTE: TABLES TO BE USED -PRODUCT, ORDER_ITEMS TABLE] 
    

WITH DISCOUNT AS (
SELECT PRODUCT_ID,
CASE 
	WHEN PRODUCT_PRICE >= 20000 THEN 0.2 
	WHEN PRODUCT_PRICE > 10000 AND PRODUCT_PRICE < 20000  THEN 0.15
	WHEN PRODUCT_PRICE <= 10000 THEN 0.1
END AS DISCOUNT_RATE 
FROM PRODUCT)
            
SELECT 
P.PRODUCT_ID, 
PRODUCT_DESC AS 'DESCRIPTION', 
PRODUCT_QUANTITY_AVAIL AS 'QUANTITY AVAILABLE', 
PRODUCT_PRICE AS 'PRICE',
FORMAT(PRODUCT_PRICE * PRODUCT_QUANTITY_AVAIL,0) AS 'INVENTORY VALUE',
CONCAT(ROUND(DISCOUNT_RATE * 100), '%') 'DISCOUNT RATE',
FORMAT(PRODUCT_PRICE * (1 - DISCOUNT_RATE),2) AS 'NEW PRICE' 
FROM 
PRODUCT P 
	JOIN DISCOUNT D 
	ON P.PRODUCT_ID = D.PRODUCT_ID
WHERE P.PRODUCT_ID NOT IN (SELECT DISTINCT PRODUCT_ID FROM ORDER_ITEMS)
ORDER BY PRODUCT_PRICE * PRODUCT_QUANTITY_AVAIL DESC
LIMIT 5;




-- 3. WRITE A QUERY TO DISPLAY PRODUCT_CLASS_CODE, PRODUCT_CLASS_DESCRIPTION, COUNT OF PRODUCT TYPE IN EACH PRODUCT CLASS, 
-- INVENTORY VALUE (P.PRODUCT_QUANTITY_AVAIL*P.PRODUCT_PRICE). INFORMATION SHOULD BE DISPLAYED FOR ONLY THOSE PRODUCT_CLASS_CODE 
-- WHICH HAVE MORE THAN 1,00,000 INVENTORY VALUE. SORT THE OUTPUT WITH RESPECT TO DECREASING VALUE OF INVENTORY_VALUE.
	-- [NOTE: TABLES TO BE USED -PRODUCT, PRODUCT_CLASS]
    
SELECT 
    P.PRODUCT_CLASS_CODE,
    PC.PRODUCT_CLASS_DESC,
    COUNT(P.PRODUCT_ID) 'PRODUCT COUNT',
    FORMAT(SUM(P.PRODUCT_PRICE * P.PRODUCT_QUANTITY_AVAIL),0) AS 'INVENTORY VALUE'
FROM
    PRODUCT P
        LEFT JOIN
    PRODUCT_CLASS PC ON PC.PRODUCT_CLASS_CODE = P.PRODUCT_CLASS_CODE
GROUP BY P.PRODUCT_CLASS_CODE
HAVING SUM(P.PRODUCT_PRICE * P.PRODUCT_QUANTITY_AVAIL) > 100000
ORDER BY SUM(P.PRODUCT_PRICE * P.PRODUCT_QUANTITY_AVAIL) DESC
LIMIT 5;


-- 4. WRITE A QUERY TO DISPLAY CUSTOMER_ID, FULL NAME, CUSTOMER_EMAIL, CUSTOMER_PHONE AND COUNTRY OF CUSTOMERS WHO HAVE CANCELLED 
-- ALL THE ORDERS PLACED BY THEM(USE SUB-QUERY)
	-- [NOTE: TABLES TO BE USED - ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]

SELECT 
    OC.CUSTOMER_ID,
    CONCAT(OC.CUSTOMER_FNAME, ' ',OC.CUSTOMER_LNAME) AS 'FULL NAME',
    OC.CUSTOMER_EMAIL,
    OC.CUSTOMER_PHONE,
    AD.COUNTRY
FROM
    ORDER_HEADER OH
        JOIN
    ONLINE_CUSTOMER OC ON OH.CUSTOMER_ID = OC.CUSTOMER_ID
        JOIN
    ADDRESS AD ON OC.ADDRESS_ID = AD.ADDRESS_ID
WHERE OH.ORDER_STATUS = 'CANCELLED'
LIMIT 5;


-- 5. WRITE A QUERY TO DISPLAY SHIPPER NAME, CITY TO WHICH IT IS CATERING, NUMBER OF CUSTOMER CATERED BY THE SHIPPER IN THE CITY AND 
-- NUMBER OF CONSIGNMENTS DELIVERED TO THAT CITY FOR SHIPPER DHL(9 ROWS)
	-- [NOTE: TABLES TO BE USED -SHIPPER, ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
    
SELECT 
    S.SHIPPER_NAME,
    A.CITY,
    COUNT(DISTINCT OH.CUSTOMER_ID) 'CUSTOMERS CATERED',
    COUNT(OH.ORDER_ID) 'CONSIGNMENTS DELIVERED'
FROM
    ADDRESS A
        JOIN
    ONLINE_CUSTOMER OC ON OC.ADDRESS_ID = A.ADDRESS_ID
        JOIN
    ORDER_HEADER OH ON OH.CUSTOMER_ID = OC.CUSTOMER_ID
        JOIN
    SHIPPER S ON OH.SHIPPER_ID = S.SHIPPER_ID
WHERE
    S.SHIPPER_NAME = 'DHL'
GROUP BY A.CITY
LIMIT 5;


-- ALL RECORDS FOR DHL --
SELECT 
    S.SHIPPER_NAME,
    A.CITY,
    OC.CUSTOMER_ID,
    OC.CUSTOMER_FNAME,
    OC.CUSTOMER_LNAME,
    OH.ORDER_ID
FROM
    ADDRESS A
        JOIN
    ONLINE_CUSTOMER OC ON OC.ADDRESS_ID = A.ADDRESS_ID
        JOIN
    ORDER_HEADER OH ON OH.CUSTOMER_ID = OC.CUSTOMER_ID
        JOIN
    SHIPPER S ON OH.SHIPPER_ID = S.SHIPPER_ID
WHERE
    S.SHIPPER_NAME = 'DHL'
    ORDER BY A.CITY;

-- 6. WRITE A QUERY TO DISPLAY CUSTOMER ID, CUSTOMER FULL NAME, TOTAL QUANTITY AND TOTAL VALUE (QUANTITY*PRICE) SHIPPED WHERE MODE 
-- OF PAYMENT IS CASH AND CUSTOMER LAST NAME STARTS WITH 'G'
	-- [NOTE: TABLES TO BE USED -ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER]
    
SELECT 
    OC.CUSTOMER_ID,
    CONCAT(OC.CUSTOMER_FNAME,
            ' ',
            OC.CUSTOMER_LNAME) AS 'FULL NAME',
    SUM(OI.PRODUCT_QUANTITY) 'TOTAL QUANTITY',
    FORMAT(SUM(OI.PRODUCT_QUANTITY * P.PRODUCT_PRICE),2) 'TOTAL VALUE'
FROM
    ONLINE_CUSTOMER OC
        JOIN
    ORDER_HEADER OH ON OC.CUSTOMER_ID = OH.CUSTOMER_ID
        RIGHT JOIN
    ORDER_ITEMS OI ON OH.ORDER_ID = OI.ORDER_ID
        JOIN
    PRODUCT P ON OI.PRODUCT_ID = P.PRODUCT_ID
WHERE
    OH.PAYMENT_MODE = 'CASH'
        AND OC.CUSTOMER_LNAME LIKE 'G%'
GROUP BY OC.CUSTOMER_ID
LIMIT 5;


-- 7. WRITE A QUERY TO DISPLAY ORDER_ID AND VOLUME OF BIGGEST ORDER (IN TERMS OF VOLUME) THAT CAN FIT IN CARTON ID 10  
	-- [NOTE: TABLES TO BE USED -CARTON, ORDER_ITEMS, PRODUCT]
    
SELECT 
    OI.ORDER_ID,
    FORMAT(SUM(P.HEIGHT * P.LEN * P.WIDTH * OI.PRODUCT_QUANTITY),0) AS 'VOLUME'
FROM
    ORDER_ITEMS OI
        JOIN
    PRODUCT P ON OI.PRODUCT_ID = P.PRODUCT_ID
GROUP BY OI.ORDER_ID
HAVING SUM(P.HEIGHT * P.LEN * P.WIDTH * OI.PRODUCT_QUANTITY) < (SELECT 
        LEN * WIDTH * HEIGHT
    FROM
        CARTON
    WHERE
        CARTON_ID = 10)
ORDER BY SUM(P.HEIGHT * P.LEN * P.WIDTH * OI.PRODUCT_QUANTITY) DESC
LIMIT 1;

-- 8. WRITE A QUERY TO DISPLAY PRODUCT_ID, PRODUCT_DESC, PRODUCT_QUANTITY_AVAIL, QUANTITY SOLD, AND SHOW INVENTORY STATUS OF 
-- PRODUCTS AS BELOW AS PER BELOW CONDITION:
	-- A.FOR ELECTRONICS AND COMPUTER CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY',
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 10% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY', 
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 50% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv.IF INVENTORY QUANTITY IS MORE OR EQUAL TO 50% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
	-- B.FOR MOBILES AND WATCHES CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY', 
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 20% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY',  
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 60% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv.IF INVENTORY QUANTITY IS MORE OR EQUAL TO 60% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
	-- C.REST OF THE CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY', 
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 30% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY',  
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 70% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv. IF INVENTORY QUANTITY IS MORE OR EQUAL TO 70% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
        
			-- [NOTE: TABLES TO BE USED -PRODUCT, PRODUCT_CLASS, ORDER_ITEMS] (USE SUB-QUERY)
            
WITH INV AS (
SELECT 
    P.PRODUCT_CLASS_CODE,
    CONCAT(ROUND((SUM(P.PRODUCT_QUANTITY_AVAIL) - SUM(OI.PRODUCT_QUANTITY)) * 100 / SUM(P.PRODUCT_QUANTITY_AVAIL),1),'%') AS INVENTORY
FROM
    PRODUCT P
        JOIN
    ORDER_ITEMS OI ON P.PRODUCT_ID = OI.PRODUCT_ID
GROUP BY P.PRODUCT_CLASS_CODE)
            
SELECT 
    P.PRODUCT_CLASS_CODE,
    PC.PRODUCT_CLASS_DESC,
    SUM(P.PRODUCT_QUANTITY_AVAIL) 'QUANTITY AVLBL',
    SUM(OI.PRODUCT_QUANTITY) 'QUANTITY SOLD',
    I.INVENTORY 'INVENTORY PERCENT',
    CASE 
		WHEN PC.PRODUCT_CLASS_DESC IN ('ELECTRONICS','COMPUTER') AND I.INVENTORY = 100 THEN 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY' 
		WHEN PC.PRODUCT_CLASS_DESC IN ('ELECTRONICS','COMPUTER') AND I.INVENTORY < 10 THEN 'LOW INVENTORY, NEED TO ADD INVENTORY'
        WHEN PC.PRODUCT_CLASS_DESC IN ('ELECTRONICS','COMPUTER') AND I.INVENTORY < 50 THEN 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY'
        WHEN PC.PRODUCT_CLASS_DESC IN ('ELECTRONICS','COMPUTER') AND I.INVENTORY >= 50 THEN 'SUFFICIENT INVENTORY'
        WHEN PC.PRODUCT_CLASS_DESC IN ('MOBILES','WATCHES') AND I.INVENTORY = 100 THEN 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY'
        WHEN PC.PRODUCT_CLASS_DESC IN ('MOBILES','WATCHES') AND I.INVENTORY < 20 THEN 'LOW INVENTORY, NEED TO ADD INVENTORY'
        WHEN PC.PRODUCT_CLASS_DESC IN ('MOBILES','WATCHES') AND I.INVENTORY < 60 THEN 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY'
        WHEN PC.PRODUCT_CLASS_DESC IN ('MOBILES','WATCHES') AND I.INVENTORY >= 60 THEN 'SUFFICIENT INVENTORY'
        WHEN PC.PRODUCT_CLASS_DESC NOT IN ('ELECTRONICS','COMPUTER','MOBILES','WATCHES') AND I.INVENTORY = 100 THEN 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY'
        WHEN PC.PRODUCT_CLASS_DESC NOT IN ('ELECTRONICS','COMPUTER','MOBILES','WATCHES') AND I.INVENTORY < 30 THEN 'LOW INVENTORY, NEED TO ADD INVENTORY'
        WHEN PC.PRODUCT_CLASS_DESC NOT IN ('ELECTRONICS','COMPUTER','MOBILES','WATCHES') AND I.INVENTORY < 70 THEN 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY'
        WHEN PC.PRODUCT_CLASS_DESC NOT IN ('ELECTRONICS','COMPUTER','MOBILES','WATCHES') AND I.INVENTORY >= 70 THEN 'SUFFICIENT INVENTORY'
        END 'INVENTORY STATUS'
FROM
    INV I 
		JOIN 
    PRODUCT_CLASS PC ON PC.PRODUCT_CLASS_CODE = I.PRODUCT_CLASS_CODE
        JOIN
    PRODUCT P ON PC.PRODUCT_CLASS_CODE = P.PRODUCT_CLASS_CODE
        JOIN
    ORDER_ITEMS OI ON P.PRODUCT_ID = OI.PRODUCT_ID
GROUP BY P.PRODUCT_CLASS_CODE
ORDER BY PRODUCT_CLASS_CODE
LIMIT 5;


-- 9. WRITE A QUERY TO DISPLAY PRODUCT_ID, PRODUCT_DESC AND TOTAL QUANTITY OF PRODUCTS WHICH ARE SOLD TOGETHER WITH PRODUCT ID 201 
-- AND ARE NOT SHIPPED TO CITY BANGALORE AND NEW DELHI. DISPLAY THE OUTPUT IN DESCENDING ORDER WITH RESPECT TO TOT_QTY.(USE SUB-QUERY)
	-- [NOTE: TABLES TO BE USED -ORDER_ITEMS,PRODUCT,ORDER_HEADER, ONLINE_CUSTOMER, ADDRESS]
    
WITH IDS AS (
SELECT 
		DISTINCT ORDER_ID
        FROM
            (SELECT 
                ORDER_ID, PRODUCT_ID, PRODUCT_QUANTITY
            FROM
                ORDER_ITEMS
            WHERE
                PRODUCT_ID = 212) X)

SELECT 
    OI.ORDER_ID,
    OI.PRODUCT_ID,
    P.PRODUCT_DESC 'DESCRIPTION',
    OI.PRODUCT_QUANTITY 'QUANTITY',
    A.CITY
FROM
    PRODUCT P 
    JOIN
    ORDER_ITEMS OI ON P.PRODUCT_ID = OI.PRODUCT_ID
    JOIN 
    ORDER_HEADER OH ON OI.ORDER_ID = OH.ORDER_ID 
    JOIN
    ONLINE_CUSTOMER OC ON OH.CUSTOMER_ID = OC.CUSTOMER_ID
    JOIN
    ADDRESS A ON A.ADDRESS_ID = OC.ADDRESS_ID
WHERE
    OI.ORDER_ID IN (SELECT ORDER_ID FROM IDS)
        AND OI.PRODUCT_ID <> 212 AND A.CITY NOT IN ('BANGALORE','NEW DELHI')
ORDER BY OI.PRODUCT_QUANTITY DESC 
LIMIT 5;
        

-- 10. WRITE A QUERY TO DISPLAY THE ORDER_ID,CUSTOMER_ID AND CUSTOMER FULLNAME AND TOTAL QUANTITY OF PRODUCTS SHIPPED FOR ORDER IDS 
-- WHICH ARE EVENAND SHIPPED TO ADDRESS WHERE PINCODE IS NOT STARTING WITH "5" 
	-- [NOTE: TABLES TO BE USED - ONLINE_CUSTOMER,ORDER_HEADER, ORDER_ITEMS, ADDRESS]

SELECT 
    OH.ORDER_ID,
    OC.CUSTOMER_ID,
    CONCAT(OC.CUSTOMER_FNAME,
            ' ',
            OC.CUSTOMER_LNAME) AS 'FULL NAME',
    SUM(OI.PRODUCT_QUANTITY) 'PRODUCT QUANTITY',
    A.PINCODE
FROM
    ORDER_ITEMS OI
        JOIN
    ORDER_HEADER OH ON OI.ORDER_ID = OH.ORDER_ID
        JOIN
    ONLINE_CUSTOMER OC ON OH.CUSTOMER_ID = OC.CUSTOMER_ID
        JOIN
    ADDRESS A ON A.ADDRESS_ID = OC.ADDRESS_ID
WHERE
    MOD(OH.ORDER_ID, 2) = 0
        AND A.PINCODE NOT LIKE '5%'
GROUP BY OH.ORDER_ID
LIMIT 5;
