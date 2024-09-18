CREATE DATABASE FoodserviceDB 
USE FoodserviceDB  
GO 

--consumers table
--set Consumer_ID as the primary key to consumers table
ALTER TABLE consumers 
ADD CONSTRAINT pk_Consumer
PRIMARY KEY (Consumer_ID)


--restaurants table
--set Restaurant_ID as primary key to restaurant table
ALTER TABLE restaurants 
ADD CONSTRAINT pk_Restaurant_ID
PRIMARY KEY (Restaurant_ID)


--restaurant_cuisines table
--add Restaurant_ID as foreign key to restaurant_cuisines 
ALTER TABLE restaurant_cuisines 
ADD CONSTRAINT fk_restaurant_cuisines_restaurants FOREIGN KEY (Restaurant_ID) REFERENCES restaurants(Restaurant_ID);


--ratings table
--set Consumer_ID and Restaurant_ID as primary key to ratings table
ALTER TABLE ratings 
ADD CONSTRAINT pk_ratings PRIMARY KEY (Consumer_ID, Restaurant_ID);

--add Restaurant_ID as foreign key to ratings table
ALTER TABLE ratings 
ADD CONSTRAINT fk_ratings_restaurants FOREIGN KEY (Restaurant_ID) REFERENCES restaurants(Restaurant_ID);

--add Consumer_ID as foreign key to ratings table
ALTER TABLE ratings 
ADD CONSTRAINT fk_ratings_consumers FOREIGN KEY (Consumer_ID) REFERENCES consumers(Consumer_ID);



--1. Write a query that lists all restaurants with a Medium range price with open area, 
--serving Mexican food
SELECT r.Name As Restaurant_Name, r.City, r.Country, r.Area, r.Price
FROM restaurants AS r INNER JOIN restaurant_cuisines AS rc 
ON r.Restaurant_ID=rc.Restaurant_ID
WHERE r.Price = 'Medium' AND r.Area = 'Open' AND rc.Cuisine = 'Mexican'


--2. Write a query that returns the total number of restaurants who have the overall rating 
--as 1 and are serving Mexican food. Compare the results with the total number of 
--restaurants who have the overall rating as 1 serving Italian food (please give 
--explanations on their comparison)
SELECT 
    (SELECT COUNT(DISTINCT(r1.Restaurant_ID))
     FROM ratings AS r1
     INNER JOIN restaurant_Cuisines AS rc1 ON r1.Restaurant_ID = rc1.Restaurant_ID
     WHERE r1.Overall_Rating = 1 AND rc1.Cuisine = 'Mexican') AS Mexican_Restaurants,
    
    (SELECT COUNT( DISTINCT(r2.Restaurant_ID))
     FROM ratings AS r2
     INNER JOIN restaurant_Cuisines AS rc2 ON r2.Restaurant_ID = rc2.Restaurant_ID
     WHERE r2.Overall_Rating = 1 AND rc2.Cuisine = 'Italian') AS Italian_Restaurants;



----3. Calculate the average age of consumers who have given a 0 rating to the 'Service_rating'
--column. (NB: round off the value if it is a decimal)
SELECT ROUND(AVG(Age), 0) AS Average_Age
FROM consumers
WHERE Consumer_id IN (
SELECT Consumer_id
FROM Ratings
WHERE Service_Rating = 0)


--4. Write a query that returns the restaurants ranked by the youngest consumer. You 
--should include the restaurant name and food rating that is given by that customer to 
--the restaurant in your result. Sort the results based on food rating from high to low.
-- Assuming the following table structures:
-- restaurants(id, name)
-- reviews(restaurant_id, user_id, age, food_rating)

SELECT r.name AS RestaurantName, ra.Food_Rating AS FoodRating
FROM restaurants AS r INNER JOIN ratings AS ra 
ON r.Restaurant_ID=ra.Restaurant_ID INNER JOIN consumers AS c 
ON ra.Consumer_ID=c.Consumer_ID
where c.AGE = (select min(age) from consumers AS c)
ORDER BY ra.food_rating DESC;  



--5. Write a stored procedure for the query given as:
--Update the Service_rating of all restaurants to '2' if they have parking available, either 
--as 'yes' or 'public'

--counting the initial total number of Service_Ratinhg before applying the stored procedure
SELECT COUNT(*) AS Inital_Service_Rating
FROM ratings
WHERE Service_Rating = 2

--create stored procedure for updating Service_Rating 
CREATE PROCEDURE usp_service_rating_update
AS 
BEGIN
SET NOCOUNT ON;
BEGIN TRANSACTION;
BEGIN TRY
		UPDATE ra
		SET ra.Service_Rating = 2
		FROM restaurants AS re INNER JOIN ratings AS ra
		ON re.Restaurant_ID=ra.Restaurant_ID
		WHERE re.Parking IN ('Yes', 'Public' )
		COMMIT TRANSACTION;
END TRY

BEGIN CATCH
		--Looks like there was an error!
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
		DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int
		SELECT @ErrMsg = ERROR_MESSAGE(),
		@ErrSeverity = ERROR_SEVERITY()
		RAISERROR(@ErrMsg, @ErrSeverity, 1)
END CATCH; 
END;

EXEC usp_service_rating_update

SELECT COUNT(*) AS New_Service_Rating
FROM ratings
WHERE Service_Rating = 2


--6. You should also write four queries of your own and provide a brief explanation of the 
--results which each query returns. You should make use of all of the following at least once:
--Nested queries-EXISTS
--Nested queries-IN
--System functions
--Use of GROUP BY, HAVING and ORDER BY clauses

--6a Nested queries -EXISTS  
SELECT Name AS Restaurant_Name, City, State, Price
FROM restaurants AS r
WHERE EXISTS (
	SELECT  1
	FROM restaurant_cuisines AS rc
	WHERE rc.Restaurant_ID=r.Restaurant_ID AND rc.Cuisine = 'American');

--6b Nested queries-IN
SELECT Name AS Restaurant_Name, City, State
FROM restaurants
WHERE Restaurant_ID IN (
    SELECT Restaurant_ID
    FROM ratings
    WHERE Food_Rating = 1);


--6c System functions
SELECT  City, State, Marital_Status, Occupation, Budget, Age, RANK() OVER(ORDER BY Age) AS RANK 
FROM consumers


--6d Use of GROUP BY, HAVING and ORDER BY clauses
SELECT City, COUNT(Name) AS Total_Restaurant, AVG(ra.Overall_Rating) AS Average_Overall_Rating
FROM Restaurants AS re INNER JOIN ratings AS ra
ON re.Restaurant_ID=ra.Restaurant_ID
GROUP BY re.City
HAVING AVG(ra.Overall_Rating) >= 1
ORDER BY Total_Restaurant DESC;
