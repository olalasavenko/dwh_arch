/**
Вывести все фильмы без ограничения по возрасту (film.rating = ‘G’). По каждому из фильмов вывести:
- название (film.title)
- сколько всего дисков с этим фильмом (кол-во записей в inventory) (рассчитать отдельной функцией, которая принимает на вход film_id)
- сколько раз фильм сдавали в аренду (кол-во записей в rental) (рассчитать отдельной функцией, которая принимает на вход film_id)
**/

drop function if exists filmInventoryCount;
create function filmInventoryCount(film_id int) returns int
as $$
	select 
		count(*) as inventoryCount
	from inventory i
	where i.film_id=filmInventoryCount.film_id
$$ language sql;


drop function if exists film_rentalCount;
create function film_rentalCount(film_id int) returns int
as $$
	select 
		count(*) as rentalCount
	from 
		rental r
		left join inventory i using(inventory_id)
	where 
		i.film_id=film_rentalCount.film_id
$$ language sql;


select 
	f.title, 
	filmInventoryCount(f.film_id),
	film_rentalCount(f.film_id)
from 
	film f
where 
	f.rating='G'
order by title;


/**
Написать функцию, которая принимает на вход два целых числа типа int и возвращает наибольшее из них.
Написать запрос с пример использования этой функции.
**/

drop function if exists maxInt;
create function maxInt(v1 int, v2 int) returns int
as $$
	select 
		case 
			when v1 >= v2 then v1
			else v2
		end
$$ language sql;


select 
	film_id 
from 
	film f 
where
	film_id > maxInt(13, 111);
	

select maxInt(34, 87);
	

/**
Написать функцию, которая добавляет в систему информацию о новом компакт диске (добавляет новую запись в таблицу inventory).

Принимает параметры:
- film_id - id фильма, который находится на новом компакт диске
- store_id - id магазина, к которому будет привязан компакт диск

Добавить 3 новых компакт диска в систему, используя новую функцию.
**/

drop function if exists newInventory;
create function newInventory(film_id int, store_id int) returns void
as $$
	insert into public.inventory(
		film_id, 
		store_id,
		last_update
	)
	values
	(
		film_id,
		store_id,
		now()
	);
$$ language sql;

select * from inventory
order by inventory_id desc;

select newInventory(21, 2);
select newInventory(73, 1);
select newInventory(45, 2);

/**
Написать функцию, которая принимает на вход film_id и возвращает пары значений:
- дату
- общую сумму платежей по данному фильму за эту дату (sum(payment.amount))

Выводим только даты, за которые был хотя бы один платеж по выбранному фильму.
Отсортировать результат в порядке увеличения даты.
**/

drop function if exists filmPaymentsOnDate;
create function filmPaymentsOnDate(film_id int) returns table("date" date, filmPayments numeric(5,2))
as $$
	select 
		p.payment_date::date as "date", 
		sum(p.amount) as filmPayments
	from 
		payment p 
		join rental r using(rental_id)
		join inventory i using(inventory_id)
	where 
		i.film_id=filmPaymentsOnDate.film_id
	group by 
		p.payment_date::date
	order by 
		date asc
$$ language sql;

select * from filmPaymentsOnDate(25);