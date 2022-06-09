CREATE DATABASE covid_impact;
USE covid_impact;

CREATE TABLE vaccinated(
	iso_code VARCHAR(10),
    continent VARCHAR(100),
    location VARCHAR(225),
    `date` DATE,
    total_cases BIGINT,
    people_vaccinated BIGINT,
    people_fully_vaccinated BIGINT,
    total_boosters BIGINT,
    population BIGINT,
    population_density FLOAT(5),
    median_age FLOAT(2)
    );

CREATE TABLE casualties_n_cases(
	iso_code VARCHAR(10),
    continent VARCHAR(100),
    location VARCHAR(225),
    `date` DATE,
    total_cases BIGINT,
    new_cases BIGINT,
    total_deaths BIGINT,
    new_deaths BIGINT,
    population BIGINT
    );


SELECT * FROM vaccinated; 
SELECT * FROM casualties_n_cases;








/*
Likelihood of being Fully Vaccinated*/
SELECT iso_code,  location, 100 * max(people_fully_vaccinated)/population AS FullyVaccinatedPercentage
FROM vaccinated
WHERE iso_code NOT LIKE "OWID%" AND iso_code NOT IN ("GIB","PCN")
GROUP BY iso_code
ORDER BY FullyVaccinatedPercentage DESC;








/*
Likelihood of being infected*/
SELECT iso_code,  location, 100 * max(total_cases)/population AS InfectedPercentage, population
FROM casualties_n_cases
WHERE iso_code NOT LIKE "OWID%"
GROUP BY iso_code
ORDER BY InfectedPercentage DESC;





/*
Countries with higher death rate than the global death rate*/
SELECT iso_code, location, avg(total_deaths) AS Avg_Deaths
FROM casualties_n_cases
WHERE iso_code NOT LIKE "OWID%" 
GROUP BY iso_code, location
ORDER by Avg_Deaths DESC;



set @startdate := (select `date` from casualties_n_cases order by `date` limit 1);
set @enddate   := (select `date` from casualties_n_cases order by `date` DESC limit 1);




set @globalaverage = (SELECT max(total_deaths) / datediff(@enddate,@startdate)
						FROM casualties_n_cases 
						WHERE location = "World");
                    
SELECT @globalaverage;

SELECT "GLO" as iso_code, "Global" as location, round(@globalaverage,2) as Avg_Deaths
UNION
SELECT iso_code, location, round(avg(total_deaths), 2) AS Avg_Deaths
FROM casualties_n_cases
WHERE iso_code NOT LIKE "OWID%"
GROUP BY iso_code, location
HAVING Avg_Deaths > @globalaverage
ORDER by 3 DESC;


/*
Density Of Total Cases Country-Wise*/
SELECT iso_code, location, 100 * max(total_cases)/population AS PercentPopulationInfected, population
FROM vaccinated
WHERE iso_code NOT LIKE "OWID%"
GROUP BY iso_code
ORDER BY PercentPopulationInfected DESC;



DROP VIEW IF EXISTS CasesDensity;
CREATE VIEW CasesDensity
AS
SELECT iso_code, location, 100 * max(total_cases)/population AS PercentPopulationInfected, population
FROM vaccinated
WHERE iso_code NOT LIKE "OWID%"
GROUP BY iso_code
ORDER BY PercentPopulationInfected DESC;

SELECT * FROM CasesDensity;



/*
Continent wise break down*/

SELECT continent, max(total_cases) as TotalCases, max(total_deaths) as TotalDeaths, SUM(population) OVER (partition by continent) AS Population
FROM casualties_n_cases
WHERE iso_code NOT LIKE "OWID%"
GROUP BY continent;




