use student;
select * from orders;
--- CTE(Common Table Expression) is a temporary result set that can be referenced within a SELECT, INSERT, UPDATE, or DELETE statement.
---that can be used multiple times in a query. It is defined using the WITH clause and can be thought of as a named temporary result set that exists only for the duration of the query.
---1.Non- Recursive CTE ( is executed only once)
---2. Recursive CTE( is executed multiple times until the termination condition is met)
-----Standalone CTE----------------------------------

--finde  the Total Sales per Customer
with cte_Total_sales as(
		select 
		  customer_id,
		  sum(amount)as Totalsales
		from orders
		group by customer_id
)
---main Query
select  c.Customer_id,
        cts.Totalsales
		from orders c
	    left join
		cte_Total_sales cts
		on c.customer_id=cts.customer_id;

----Multiple Standalone CTE----------------------------------
--Step1: finde  the Total Sales per Customer
with cte_Total_sales as(
		select 
		  customer_id,
		  sum(amount)as Totalsales
		from orders
		group by customer_id
),
---Step2: Finde the last order Date for each Customer
CTE_last_order as(
		select
		   customer_id,
		   max(order_date)as last_date
		from orders 
		group by customer_id
)
---main Query
select 
        c.Customer_id,
        cts.Totalsales,
		clo.last_date
from orders c
left join
		cte_Total_sales cts
on c.customer_id=cts.customer_id
left join
CTE_last_order clo on
clo.customer_id=c.customer_id;
-----------------------####### mini project-----------------------------------------------------
-----Nested CTE-------------------------
--#1 Step: Find the Total sales per Customer.
--#2 Step: Find the last order dte per Customer.
--#3 Step: Rank Customers based on total sales per Customers.
--#4 Step: Segment Cutomers based on their total Sales.
--Step1: finde  the Total Sales per Customer
with cte_Total_sales as(
		select 
		  customer_id,
		  sum(amount)as Totalsales
		from orders
		group by customer_id
),
---Step2: Finde the last order Date for each Customer
CTE_last_order as(
		select
		   customer_id,
		   max(order_date)as last_date
		from orders 
		group by customer_id
),
---Step3 : Rank Customers based on Total Sales Per Cutomer
CTE_Customer_Rank as
(
    select 
	   customer_id,
	   Totalsales,
	   rank() over(order by Totalsales desc) as CustomerRank
	   from  cte_Total_sales
),
---4 Step: Segment Cutomers based on their total Sales.
CTE_Customer_Segments as(
    select 
	     customer_id,
		 case  
		   when Totalsales > 50000 then 'High'
		   when	Totalsales > 20000 then 'Medium'
			else 'Low'
		end CustomerSegments
		from cte_Total_sales		      
)
---main Query---------------------------------------------------
select 
        c.Customer_id,
        cts.Totalsales,
		clo.last_date,
		ccr.CustomerRank,
		ccs.CustomerSegments
from orders c
left join
cte_Total_sales cts
on c.customer_id=cts.customer_id
left join
CTE_last_order clo on
clo.customer_id=c.customer_id
left join
CTE_Customer_Rank ccr 
on ccr.customer_id=c.customer_id
left join
CTE_Customer_Segments ccs on
ccs.customer_id=c.customer_id
;
---#### ---2. Recursive CTE(Self-referencing query that repeatedly processes data untill a specific conditon is met)---

----Generate a Sequence of Number form 1 to 20
WITH Series as (
      --Anchor Query
		select 
		  1 as myNumber
		  UNION ALL
	 -- Recursive Query
		select  
		  myNumber+1
		 from Series
		 where myNumber < 20 
		  )
-- Main Query----
select * from Series
OPTION(MAXRECURSION 200);
---## Task: Show the employee hierarchy by displaying each employee's level within the organization
/*select
   employee_id,
   name,department ,manager_id,
   DENSE_RANK() over(order by manager_id )as Top_RnkEmployee
from employees;*/
With CTE_Emp_Hierarchy as(
    ---Anchor Queerey
		Select 
		  Employee_id,
		  name ,
		  Manager_id,
		  1 as level
		from employees
		where manager_id is null
		UNION all
	--Recursive Query
	 select
	   e.employee_id,
	   e.name ,
	   e.Manager_id,
	    level +1
	from employees as e
	INNER JOIN
	CTE_Emp_Hierarchy CTE ON
	E.manager_id=CTE.employee_id

)
-- Main Query
select
 * from CTE_Emp_Hierarchy;