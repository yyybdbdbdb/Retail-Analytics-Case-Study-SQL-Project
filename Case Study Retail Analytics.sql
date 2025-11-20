######### Case Study Retail Analytics ##########
  
   use case_study; 
   alter table `customer_profiles-1-1714027410` 
   rename to customer_profiles; 
   alter table `product_inventory-1-1714027438` 
   rename to product_inventory; 
   alter table `sales_transaction-1714027462`
   rename to sales_transaction; 
   
   select * from  customer_profiles;
   desc customer_profiles;
   select * from  Product_Inventory;
   desc  Product_Inventory;
   select * from  sales_transaction;
   desc sales_transaction;
   
   
#####  1. Remove  Duplicates 
   select ï»¿TransactionID, count(*)   from sales_transaction 
   group by ï»¿TransactionID
   having count(*) > 1; 
   
   ######## 2 Duplicates present ######  
   
create table sales_tn_unique as select distinct * from sales_transaction; 
drop table sales_transaction; 
alter table sales_tn_unique 
rename to sales_transaction; 

####  2.Fixing Incorrect Prices 
select p.ï»¿ProductID , s.ï»¿TransactionID , s.price as Trans_price , p.price as Prod_price 
from sales_transaction as s 
inner join product_inventory as p on s.productid = p.ï»¿ProductID
where p.price <> s.price; 
   ### productid 51 have wrong price ###

update sales_transaction 
set price =93.12
where productid = 51;    
   
 select p.ï»¿ProductID , s.ï»¿TransactionID , s.price as Trans_price , p.price as Prod_price 
from sales_transaction as s 
inner join product_inventory as p on s.productid = p.ï»¿ProductID
where p.price <> s.price;    

#####  3. Fix null values
select * from  customer_profiles; ### have 13 blank rows in location 
select * from  Product_Inventory; ## no nulls or blank 
select * from  sales_transaction; ## no nulls or blank 
select count(*) as count_null from customer_profiles 
where Location is null; 
select count(*) as count_null from customer_profiles 
where Location ='';  #### 13 blanks

update customer_profiles 
set Location ="Unkonwn"
where Location ='';
select count(*) as count_null from customer_profiles 
where Location =''; 
select * from  customer_profiles; 

#### 4. Cleaning Data 
 select * from  sales_transaction;
   desc sales_transaction;
create table sales_trans_updated as 
select * , str_to_date(TransactionDate, "%d/%m/%Y") as transactiondate_updated 
from sales_Transaction
 
 desc sales_trans_updated; 
 drop table sales_transaction; 
 
 alter table  sales_trans_updated
 rename to sales_transaction;
select * from sales_transaction;

#### 5.Total sales summary  
select * from  sales_transaction;
select productid , sum(quantitypurchased) as TotalUnitssold , round(sum(quantitypurchased * price),0) as Totalsales
from sales_transaction 
group by productid
order by sum(quantitypurchased * price) desc;

#### 6. customer purchase frequency  
select * from  sales_transaction;
select customerid , count(ï»¿TransactionID) as trans_count 
from sales_transaction
group by customerid
order by count(ï»¿TransactionID)  desc; 

#### 7. Product category Performance  
select * from product_inventory; 
select p.category , sum(s.quantitypurchased) as Quantitysold , s.price, sum(s.quantitypurchased * p.price) as toalsales from sales_transaction as s 
inner join product_inventory as p on s.productid = p.ï»¿ProductID
group by p.category 
order by sum(s.quantitypurchased * s.price) desc;

with t1 as ( 
select p.ï»¿ProductID , p.category , s.quantitypurchased , s.price from sales_transaction as s
inner join product_inventory as p on productid =p.ï»¿ProductID ) 

 #### select * from t1; 
 select t1.category , sum(t1.quantitypurchased) as totalunitssold ,round(sum(t1.quantitypurchased * t1.price),0) as totalsales from t1
 group by t1.category 
 order by sum(t1.quantitypurchased * t1.price) desc;
 
 ##### 8.High Sale Product
 
 select productid , round(sum(quantitypurchased * price),1) as Total_revenue 
 from sales_transaction 
 group by productid
 order by sum(quantitypurchased * price) desc limit 10; 
 
 ##### Low sales products 
  ## on Quantity 
 select productid , sum(quantitypurchased) as Total_units_sold 
 from sales_transaction
 group by productid
 order by sum(quantitypurchased) asc limit 10; 
 
 ## on Total sales 
 
  select productid , round(sum(quantitypurchased * price),0) as Total_revenue 
 from sales_transaction
 group by productid
 order by sum(quantitypurchased * price) asc limit 10;  
 
 #### 10. Sales Trend 
 
 select transactiondate_updated as datetrans , count(ï»¿TransactionID) as transaction_count , sum(quantitypurchased) as Totalunitssold, 
 round(sum(quantitypurchased * price),0) as Totalsales
 from sales_transaction
 Group by transactiondate_updated
 order  by transactiondate_updated desc; 
 
 #### 11. Growth Rate of sales 
 
  with cte1 as (
select month(transactiondate_updated) as month, sum(QuantityPurchased*Price) as Total_Sales
from sales_transaction
group by month(transactiondate_updated)
)
  ####   select * from cte1;

select *, LAG(Total_Sales) over (order by month) as previous_month_sales,
round(((Total_Sales - LAG(Total_Sales) over (order by month))/LAG(Total_Sales) over (order by month))*100,2) as mom_growth_perc
from cte1;
 
 
 ### 12. High purchase frequency 
 
 select * from sales_transaction;

select customerid, count(ï»¿TransactionID) as numberoftransactions, round(sum(quantitypurchased*price)) as totalspent
from sales_transaction
group by customerid
having count(ï»¿TransactionID) > 10 and sum(quantitypurchased*price) > 1000
order by sum(quantitypurchased*price) desc;

#### 13. occasional customers 
select customerid, count(ï»¿TransactionID)  as numberoftransactions, round(sum(quantitypurchased*price)) as totalspent
from sales_transaction
group by customerid
having count(ï»¿TransactionID)  <= 2
order by count(ï»¿TransactionID)  asc, sum(quantitypurchased*price) desc;

### 14. Repeat purchases 
select customerid , productid, count(ï»¿TransactionID) as timpepurchased 
from sales_transaction 
group by customerid , productid
having  count(ï»¿TransactionID) > 1
order by  count(ï»¿TransactionID) desc;

### 15.Loyalty Indicators 
select customerid , min(transactiondate_updated) as FirstPurchase , max(transactiondate_updated) as LastPurchase,
 (max(transactiondate_updated)- min(transactiondate_updated)) as DaysBetweenPurchases 
 from sales_transaction 
 group by customerid 
 having (max(transactiondate_updated)- min(transactiondate_updated)) >0
 order by (max(transactiondate_updated)- min(transactiondate_updated)) desc;
 
 #### 16. Customer Segmentation
 
 create table customer_segment as  
 select  ï»¿CustomerID, case when totalquantity >30 then "High" 
 when totalquantity between 11 and 30 then  "Mid"
 when totalquantity between 1 and 10 then "Low"
 else "none"
 end as cusseg 
 from (select c.ï»¿CustomerID , sum(s.quantitypurchased) as totalquantity from customer_profiles as c
 inner join sales_transaction as s on c.ï»¿CustomerID= s.customerid 
 group by ï»¿CustomerID 
 ) as derived_table;
 
 select cusseg, count(*)
from customer_segment
group by cusseg;

select * from customer_segment; 

SELECT c.cusseg, s.customerid, SUM(s.quantitypurchased) AS total_quantity
FROM customer_segment AS c
INNER JOIN sales_transaction AS s ON c.ï»¿CustomerID= s.customerid
GROUP BY s.customerid, c.cusseg
ORDER BY c.cusseg DESC; 
drop table  customer_segment