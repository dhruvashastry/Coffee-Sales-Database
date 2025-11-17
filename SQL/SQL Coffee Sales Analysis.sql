-- Name: Dhruva Kashyap Shastry
-- Matric No: G2502233L

-- 1. How many product categories are there? For each product category, show the number of records.
select product_category, count(*) as Records
from baristacoffeesalestbl
group by product_category;

-- 2. For each customer_gender and loyalty_member type, show the number of records. Within the same outcome, within each customer_gender and loyalty_member type, for each is_repeat_customer type, show the number of records.
select T1.customer_gender, T1.loyalty_member, T1.records, is_repeat_customer, T2.Records
from 
(
	(
		select concat(customer_gender, loyalty_member, "True") as F1, customer_gender, loyalty_member, count(*) as Records
		from baristacoffeesalestbl
		group by customer_gender, loyalty_member
	)
	Union
	(
		select concat(customer_gender, loyalty_member, "False") as F1, customer_gender, loyalty_member, count(*)
		from baristacoffeesalestbl
		group by customer_gender, loyalty_member
	) 
) as T1,
(
	select concat(customer_gender, loyalty_member, is_repeat_customer) as F1, customer_gender, loyalty_member, is_repeat_customer, count(*) as Records
	from baristacoffeesalestbl
	group by customer_gender, loyalty_member,is_repeat_customer
) as T2
where T1.F1 = T2.F1
order by customer_gender, loyalty_member, is_repeat_customer;

-- 3. For each product_category and customer_discovery_source, display the sum of total_amount.
-- A.
select product_category, customer_discovery_source, sum(convert(total_amount, decimal)) as total_sales
from baristacoffeesalestbl
group by product_category, customer_discovery_source
order by product_category, customer_discovery_source;

-- B.
select product_category, customer_discovery_source, sum(total_amount) as total_sales
from baristacoffeesalestbl
group by product_category, customer_discovery_source
order by product_category, customer_discovery_source;

-- Reasoning A is the preferred option because the sales value contain text and strings. After conversion we are getting more appropriate values.

-- 4. Consider consuming coffee as the beverage, for each time_of_day category and gender, display the average focus_level and average sleep_quality.
(select "Morning" as time_of_day, "Female" as gender, avg(convert(focus_level, decimal)) as avg_focus_level, avg(convert(sleep_quality,decimal)) as avg_sleep_quality
from caffeine_intake_tracker
where beverage_coffee = "True" and time_of_day_morning = "True" and gender_female = "True")
union
(select "Afternoon" as time_of_day, "Female" as gender, avg(convert(focus_level, decimal)) as avg_focus_level, avg(convert(sleep_quality,decimal)) as avg_sleep_quality
from caffeine_intake_tracker
where beverage_coffee = "True" and time_of_day_afternoon = "True" and gender_female = "True")
union
(select "Evening" as time_of_day, "Female" as gender, avg(convert(focus_level, decimal)) as avg_focus_level, avg(convert(sleep_quality,decimal)) as avg_sleep_quality
from caffeine_intake_tracker
where beverage_coffee = "True" and time_of_day_evening = "True" and gender_female = "True")
union
(select "Morning" as time_of_day, "Male" as gender, avg(convert(focus_level, decimal)) as avg_focus_level, avg(convert(sleep_quality,decimal)) as avg_sleep_quality
from caffeine_intake_tracker
where beverage_coffee = "True" and time_of_day_morning = "True" and gender_male = "True")
union
(select "Afternoon" as time_of_day, "Male" as gender, avg(convert(focus_level, decimal)) as avg_focus_level, avg(convert(sleep_quality,decimal)) as avg_sleep_quality
from caffeine_intake_tracker
where beverage_coffee = "True" and time_of_day_afternoon = "True" and gender_male = "True")
union
(select "Evening" as time_of_day, "Male" as gender, avg(convert(focus_level, decimal)) as avg_focus_level, avg(convert(sleep_quality,decimal)) as avg_sleep_quality
from caffeine_intake_tracker
where beverage_coffee = "True" and time_of_day_evening = "True" and gender_male = "True")
order by time_of_day DESC, gender;

-- 5. There are problems with the data in this table. List out the problematic records.
 /* Below are the porblems with the data-
		1. The url_id column fileds are incorrect
        2. range_price and percentage list mulitple values
        3. The following locations have null percentages:
			'Dimitree Cafe'
			'Kopi Cinta Asli Bogor'
			'PICCOLO COFFEE LOUNGE'
			'Groovy Space'
			'1996 Coffee & Talk'
		4. Some locations have duplicate names and null time of opening/closing:
			Vivere Coffee
			HAGU Coffee & Space
			FOUR CORNERS - Coffee Shop Bogor
			Cafe de Aut - DUPLICATES
			Aumont Kofie - DUPLICATES
*/

-- 6. List the amount of spending (money) recorded before 12 and after 12.
-- Before 12 is defined as the time between 0 and < 12 hours.
-- After 12 is defined as the time between =12 and <24 hours.

(
select "Before 12" as period, sum(convert(money, decimal(4,2))) as amt
from
	(
		select hour(convert(datetime, time)) as the_hour, cash_type, card, money, coffee_name
		from coffeesales
	) as T1
where the_hour >= 0 and the_hour< 12
)
Union
(
select "After 12" as period, sum(convert(money, decimal(4,2))) as amt
from
	(
		select hour(convert(datetime, time)) as the_hour, cash_type, card, money, coffee_name
		from coffeesales
	) as T1
where the_hour >= 12 and the_hour<= 24
);

/* Problems:
		1. Hours extending beyond 24
        2. "." before seconds
        3. Money has no fixed decimal place
*/

/* 7. Consider 7 categories of Ph values
-	pH >= 0.0 && pH < 1.0
-	pH >= 1.0 && pH < 2.0
-	pH >= 2.0 && pH < 3.0
-	pH >= 3.0 && pH < 4.0
-	pH >= 4.0 && pH < 5.0
-	pH >= 5.0 && pH < 6.0
-	pH >= 6.0 && pH < 7.0
For each category of Ph values, show the average Liking, FlavorIntensity, Acidity, and Mouthfeel. */

(
select "0 - 1" as pH, convert(avg(Liking),decimal(4,2)) as avgLiking, convert(avg(FlavorIntensity), decimal(4,2)) as avgFlavorIntensity, convert(avg(Acidity), decimal(4,2)) as avgAcidity, convert(avg(Mouthfeel), decimal(4,2)) as MouthFeel
from consumerpreference
where pH >= 0.0 and pH < 1.0
)
union
(
select "1 - 2" as pH, convert(avg(Liking),decimal(4,2)) as avgLiking, convert(avg(FlavorIntensity), decimal(4,2)) as avgFlavorIntensity, convert(avg(Acidity), decimal(4,2)) as avgAcidity, convert(avg(Mouthfeel), decimal(4,2)) as MouthFeel
from consumerpreference
where pH >= 1.0 and pH < 2.0
)
union
(
select "2 - 3" as pH, convert(avg(Liking),decimal(4,2)) as avgLiking, convert(avg(FlavorIntensity), decimal(4,2)) as avgFlavorIntensity, convert(avg(Acidity), decimal(4,2)) as avgAcidity, convert(avg(Mouthfeel), decimal(4,2)) as MouthFeel
from consumerpreference
where pH >= 2.0 and pH < 3.0
)
union
(
select "3 - 4" as pH, convert(avg(Liking),decimal(4,2)) as avgLiking, convert(avg(FlavorIntensity), decimal(4,2)) as avgFlavorIntensity, convert(avg(Acidity), decimal(4,2)) as avgAcidity, convert(avg(Mouthfeel), decimal(4,2)) as MouthFeel
from consumerpreference
where pH >= 3.0 and pH < 4.0
)
union
(
select "4 - 5" as pH, convert(avg(Liking),decimal(4,2)) as avgLiking, convert(avg(FlavorIntensity), decimal(4,2)) as avgFlavorIntensity, convert(avg(Acidity), decimal(4,2)) as avgAcidity, convert(avg(Mouthfeel), decimal(4,2)) as MouthFeel
from consumerpreference
where pH >= 4.0 and pH < 5.0
)
union
(
select "5 - 6" as pH, convert(avg(Liking),decimal(4,2)) as avgLiking, convert(avg(FlavorIntensity), decimal(4,2)) as avgFlavorIntensity, convert(avg(Acidity), decimal(4,2)) as avgAcidity, convert(avg(Mouthfeel), decimal(4,2)) as MouthFeel
from consumerpreference
where pH >= 5.0 and pH < 6.0
)
union
(
select "6 - 7" as pH, convert(avg(Liking),decimal(4,2)) as avgLiking, convert(avg(FlavorIntensity), decimal(4,2)) as avgFlavorIntensity, convert(avg(Acidity), decimal(4,2)) as avgAcidity, convert(avg(Mouthfeel), decimal(4,2)) as MouthFeel
from consumerpreference
where pH >= 6.0 and pH < 7.0
);

-- 8. Background: The barista group (baristacoffeesalestbl) and coffee shops in kota bogor (list_coffee_shops_in_kota_bogor) have a common loyalty program. This question aims to reveal the synergy of this program (e.g., identifying the profitable combinations of outlets)
(select "MAR" as "trans_month", store_id, store_location, location_name, FORMAT(AVG(agtron), 6) as avg_agtron, count(*) as "trans_amt", convert(sum(money),decimal(4,2)) as "total_money" 
from coffeesales, list_coffee_shops_in_kota_bogor, `top-rated-coffee`, baristacoffeesalestbl
where coffeesales.coffeeID = `top-rated-coffee`.ID and 
coffeesales.shopID = list_coffee_shops_in_kota_bogor.no and 
coffeesales.customer_id = substring(baristacoffeesalestbl.customer_id, 6) and
extract(month from str_to_date(date, '%d/%m/%y')) = 3
group by store_id, store_location, location_name
order by sum(money) DESC
limit 3)
union
(select "APR" as "trans_month", store_id, store_location, location_name, FORMAT(AVG(agtron), 6) as avg_agtron, count(*) as "trans_amt", convert(sum(money),decimal(4,2)) as "total_money" 
from coffeesales, list_coffee_shops_in_kota_bogor, `top-rated-coffee`, baristacoffeesalestbl
where coffeesales.coffeeID = `top-rated-coffee`.ID and 
coffeesales.shopID = list_coffee_shops_in_kota_bogor.no and 
coffeesales.customer_id = substring(baristacoffeesalestbl.customer_id, 6) and
extract(month from str_to_date(date, '%d/%m/%y')) = 4
group by store_id, store_location, location_name
order by sum(money) DESC
limit 3)
union
(select "MAY" as "trans_month", store_id, store_location, location_name, FORMAT(AVG(agtron), 6) as avg_agtron, count(*) as "trans_amt", convert(sum(money),decimal(4,2)) as "total_money" 
from coffeesales, list_coffee_shops_in_kota_bogor, `top-rated-coffee`, baristacoffeesalestbl
where coffeesales.coffeeID = `top-rated-coffee`.ID and 
coffeesales.shopID = list_coffee_shops_in_kota_bogor.no and 
coffeesales.customer_id = substring(baristacoffeesalestbl.customer_id, 6) and
extract(month from str_to_date(date, '%d/%m/%y')) = 5
group by store_id, store_location, location_name
order by sum(money) DESC
limit 3)
union
(select "JUN" as "trans_month", store_id, store_location, location_name, FORMAT(AVG(agtron), 6) as avg_agtron, count(*) as "trans_amt", convert(sum(money),decimal(4,2)) as "total_money" 
from coffeesales, list_coffee_shops_in_kota_bogor, `top-rated-coffee`, baristacoffeesalestbl
where coffeesales.coffeeID = `top-rated-coffee`.ID and 
coffeesales.shopID = list_coffee_shops_in_kota_bogor.no and 
coffeesales.customer_id = substring(baristacoffeesalestbl.customer_id, 6) and
extract(month from str_to_date(date, '%d/%m/%y')) = 6
group by store_id, store_location, location_name
order by sum(money) DESC
limit 3)
union
(select "JUL" as "trans_month", store_id, store_location, location_name, FORMAT(AVG(agtron), 6) as avg_agtron, count(*) as "trans_amt", convert(sum(money),decimal(4,2)) as "total_money" 
from coffeesales, list_coffee_shops_in_kota_bogor, `top-rated-coffee`, baristacoffeesalestbl
where coffeesales.coffeeID = `top-rated-coffee`.ID and 
coffeesales.shopID = list_coffee_shops_in_kota_bogor.no and 
coffeesales.customer_id = substring(baristacoffeesalestbl.customer_id, 6) and
extract(month from str_to_date(date, '%d/%m/%y')) = 7
group by store_id, store_location, location_name
order by sum(money) DESC
limit 3)
order by field(trans_month, 'MAR','APR','MAY','JUN','JUL');