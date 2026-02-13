CREATE DATABASE IF NOT EXISTS airbnb_project;
USE airbnb_project;

DROP TABLE IF EXISTS uk_airbnb;

CREATE TABLE uk_airbnb (
    id BIGINT PRIMARY KEY,
    price DECIMAL(10,2) NOT NULL,
    room_type VARCHAR(50) NOT NULL,
    neighbourhood VARCHAR(100) NOT NULL,
    minimum_nights INT CHECK (minimum_nights >= 0),
    number_of_reviews INT CHECK (number_of_reviews >= 0),
    availability_365 INT CHECK (availability_365 BETWEEN 0 AND 365)
);

SELECT COUNT(*) AS total_rows
FROM uk_airbnb;

SELECT 
    COUNT(*) AS total_rows,
    COUNT(price) AS price_not_null,
    COUNT(DISTINCT neighbourhood) AS unique_neighbourhoods
FROM uk_airbnb;

SELECT 
    COUNT(*) - COUNT(DISTINCT id) AS duplicate_ids
FROM uk_airbnb;

CREATE INDEX idx_room_type ON uk_airbnb(room_type);
CREATE INDEX idx_neighbourhood ON uk_airbnb(neighbourhood);

-- Average price by room type
SELECT 
    room_type,
    COUNT(*) AS listings_count,
    ROUND(AVG(price), 2) AS avg_price
FROM uk_airbnb
WHERE price > 0
GROUP BY room_type
ORDER BY avg_price DESC;

-- Top 10 most expensive neighbourhoods (statistically valid)
SELECT 
    neighbourhood,
    COUNT(*) AS listings_count,
    ROUND(AVG(price), 2) AS avg_price
FROM uk_airbnb
WHERE price > 0
GROUP BY neighbourhood
HAVING COUNT(*) >= 30
ORDER BY avg_price DESC
LIMIT 10;

-- Top 10 cheapest neighbourhoods
SELECT 
    neighbourhood,
    COUNT(*) AS listings_count,
    ROUND(AVG(price), 2) AS avg_price
FROM uk_airbnb
WHERE price > 0
GROUP BY neighbourhood
HAVING COUNT(*) >= 30
ORDER BY avg_price ASC
LIMIT 10;

-- Availability vs price (bucketed analysis)
SELECT
    CASE
        WHEN availability_365 = 0 THEN 'No availability'
        WHEN availability_365 BETWEEN 1 AND 90 THEN 'Low availability'
        WHEN availability_365 BETWEEN 91 AND 180 THEN 'Medium availability'
        ELSE 'High availability'
    END AS availability_group,
    COUNT(*) AS listings_count,
    ROUND(AVG(price), 2) AS avg_price
FROM uk_airbnb
WHERE price > 0
GROUP BY availability_group
ORDER BY 
    FIELD(
        availability_group,
        'No availability',
        'Low availability',
        'Medium availability',
        'High availability'
    );

-- Reviews impact on pricing (bucketed)
SELECT
    CASE
        WHEN number_of_reviews = 0 THEN 'No reviews'
        WHEN number_of_reviews BETWEEN 1 AND 50 THEN 'Low reviews'
        WHEN number_of_reviews BETWEEN 51 AND 200 THEN 'Medium reviews'
        ELSE 'High reviews'
    END AS review_group,
    COUNT(*) AS listings_count,
    ROUND(AVG(price), 2) AS avg_price
FROM uk_airbnb
WHERE price > 0
GROUP BY review_group
ORDER BY listings_count DESC;

-- Advanced insight: Price per night (value analysis)
SELECT
    neighbourhood,
    COUNT(*) AS listings_count,
    ROUND(AVG(price / NULLIF(minimum_nights, 1)), 2) AS price_per_night
FROM uk_airbnb
WHERE price > 0
GROUP BY neighbourhood
HAVING COUNT(*) >= 30
ORDER BY price_per_night DESC
LIMIT 10;