-- Данный запрос считает кол-во уникальных пользователей в таблице customers
select count(distinct customer_id) as customers_count 
from customers c


-- Данный отчет формирует десятку лучших продавцов
select concat(e.first_name,' ',e.last_name) as name, count(distinct s.sales_id) as operations, round(sum(p.price * s.quantity),0) as income
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
select concat(e.first_name,' ',e.last_name) as name, to_char(s.sale_date,'Day') as weekday, round(sum(p.price * s.quantity),0) as income
from sales s
left join employees e 
 on e.employee_id = s.sales_person_id 
left join products p 
 on p.product_id = s.product_id 
group by concat(e.first_name,' ',e.last_name), s.sale_date
order by extract(isodow from s.sale_date) ASC