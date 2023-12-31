-- Данный запрос считает кол-во уникальных пользователей в таблице customers
select count(distinct customer_id) as customers_count 
from customers c


-- Данный отчет формирует десятку лучших продавцов
select concat(e.first_name,' ',e.last_name) as name, count(distinct s.sales_id) as operations, sum(p.price * s.quantity) as income
from sales s
left join employees e 
 on e.employee_id = s.sales_person_id 
left join products p 
 on p.product_id = s.product_id 
group by concat(e.first_name,' ',e.last_name)
order by income desc
limit 10


-- Данный отчет содержит информацию о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам.
select concat(e.first_name,' ',e.last_name) as name, round(AVG(p.price * s.quantity),0) as average_income
from sales s
left join employees e 
 on e.employee_id = s.sales_person_id 
left join products p 
 on p.product_id = s.product_id 
group by concat(e.first_name,' ',e.last_name)
having AVG(p.price * s.quantity) < (select AVG(p.price * s.quantity)
from sales s
left join products p 
 on p.product_id = s.product_id)
order by average_income asc

-- Данный отчет содержит информацию о выручке по дням недели
with temp as (select concat(e.first_name,' ',e.last_name) as name, to_char(s.sale_date,'day') as weekday, extract(isodow from s.sale_date) as numb, round(sum(p.price * s.quantity),0) as income
from sales s
left join employees e 
 on e.employee_id = s.sales_person_id 
left join products p 
 on p.product_id = s.product_id 
group by concat(e.first_name,' ',e.last_name), to_char(s.sale_date,'day'), extract(isodow from s.sale_date)
order by concat(e.first_name,' ',e.last_name), extract(isodow from s.sale_date) asc)
select name, weekday, income
from temp
order by numb, name asc

-- Данный отчет содержит информацию о количествt покупателей в разных возрастных группах
with temp as (
select case 
	when age between 16 and 25 then '16-25'
	when age between 26 and 40 then '26-40'
	when age > 40 then '40+'
end as age_category, customer_id
from customers c 
)
select age_category, count(customer_id)
from temp
group by age_category
order by age_category

-- Данный отчет содержит информацию по количеству уникальных покупателей и выручке, которую они принесли.
select to_char(s.sale_date, 'YYYY-MM') as date, count(distinct s.customer_id), sum(p.price * s.quantity) as income
from sales s
left join customers c 
 on s.customer_id = c.customer_id
left join products p 
 on p.product_id = s.product_id 
group by to_char(s.sale_date, 'YYYY-MM')
order by to_char(s.sale_date, 'YYYY-MM')



-- Данный отчет содержит информацию о покупателях, первая покупка которых была в ходе проведения акций
with temp as (select concat(c.first_name,' ',c.last_name) as customer, min(sale_date) as sale_date
from sales s
left join customers c 
 on s.customer_id = c.customer_id
left join products p 
 on p.product_id = s.product_id 
group by concat(c.first_name,' ',c.last_name)
having sum(p.price * s.quantity) = 0)
select distinct t.customer, t.sale_date, st.name as seller
from temp t
join (select concat(e.first_name,' ',e.last_name) as name, concat(c.first_name,' ',c.last_name) as customer, s.sale_date 
from sales s
left join customers c 
 on s.customer_id = c.customer_id 
left join employees e 
 on e.employee_id = s.sales_person_id ) st
 on st.customer = t.customer and st.sale_date = t.sale_date
