use covid;

/* LOADING THE FALE */ 
LOAD DATA local infile 'C:/Users/turkd/OneDrive/Desktop/Projects/Covid/Covid_Deaths.csv' into table Covid_deaths
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;


##total count 
SELECT COUNT(continent) as count FROM covid_deaths as deaths
;


/* USA Data  */ 
SELECT * FROM Covid_deaths 
WHERE location LIKE 'united states';

/* Deleting Data from Vac Table and uploading */
TRUNCATE TABLE vac;

LOAD DATA local infile 'C:/Users/turkd/OneDrive/Desktop/Projects/Covid/Covid_Vac.csv' into table vac
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;


/* Getting Totals for fields Lowest and Highest */ 
SELECT location, DATE(date), SUM(new_cases) as tot_cases, SUM(new_deaths) as tot_deaths, SUM(hosp_patients) as tot_hospital_patients
FROM covid_deaths
WHERE continent <> ''
GROUP BY location
ORDER BY tot_deaths DESC; 

SELECT location, DATE(date), SUM(new_cases) as tot_cases, SUM(new_deaths) as tot_deaths, SUM(hosp_patients) as tot_hospital_patients
FROM covid_deaths
WHERE continent <> ''
GROUP BY location
ORDER BY tot_hospital_patients ASC; 

/* CTE to get the cases and deaths per population */
WITH CTE_cases (location, cases, deaths, patients,population)
as
(
SELECT location, SUM(new_cases) as tot_cases, SUM(new_deaths) as tot_deaths, SUM(hosp_patients) as tot_hospital_patients, population
FROM covid_deaths
WHERE continent <> ''
GROUP BY location 
)
SELECT location, (cases/population)*100 as percent_cases, (deaths/population)*100 as percent_deaths, population
FROM CTE_cases
ORDER BY percent_deaths DESC;


/* CTE to get the death rate of infected */
WITH CTE_cases (location, cases, deaths, patients,population)
as
(
SELECT location, SUM(new_cases) as tot_cases, SUM(new_deaths) as tot_deaths, SUM(hosp_patients) as tot_hospital_patients, population
FROM covid_deaths
WHERE continent <> ''
GROUP BY location 
)
SELECT location, (deaths/cases)*100 as percent_DeathRate, population
FROM CTE_cases
ORDER BY percent_deathrate DESC;

/* comparing low income to high income areas */ 
WITH CTE_cases (location, cases, deaths, patients,population)
as
(
SELECT location, SUM(new_cases) as tot_cases, SUM(new_deaths) as tot_deaths, SUM(hosp_patients) as tot_hospital_patients, population
FROM covid_deaths
WHERE location LIKE '%income%'
GROUP BY location 
)
SELECT location, (deaths/cases)*100 as percent_DeathRate, population
FROM CTE_cases
ORDER BY percent_deathrate DESC;

/* Worst Covid Day in History by Location and Continent */ 
SELECT location, DATE(date), MAX(cast(new_deaths as DECIMAL)) as deaths, population
from covid_deaths
WHERE continent <> ''
and population > 0
GROUP BY location
ORDER BY deaths DESC;

SELECT continent , DATE(date), MAX(cast(new_deaths as DECIMAL)) as deaths, population
from covid_deaths
WHERE continent <> ''
and population > 0
GROUP BY continent
ORDER BY deaths DESC;

/* Looking at Vac Table */ 

SELECT * FROM Vac;

/* total vaccinations by location */ 
SELECT location, DATE(date) as Date, SUM(new_vaccinations) as tot_vaccinations, population
FROM Vac
WHERE location <> '' and location <> 'World' and location NOT LIKE '%income%'
GROUP BY location
ORDER BY tot_vaccinations DESC; 

/* joining covid_deaths and vac tables */ 
SELECT deaths.location, DATE(deaths.date) as Date, deaths.new_cases, deaths.new_deaths, vac.new_vaccinations, vac.population
FROM covid_deaths as deaths
JOIN vac
on deaths.location = vac.location 
and deaths.date = DATE(vac.date)
ORDER BY 1,3;

SELECT deaths.location, SUM(deaths.new_cases) as tot_cases, deaths.new_deaths, SUM(vac.new_vaccinations) as tot_vaccinations, vac.population
FROM covid_deaths as deaths
JOIN vac
on deaths.location = vac.location
ORDER BY 1,3; 

DROP TABLE IF EXISTS totals_per_location;
CREATE TABLE totals_per_location
(
Location VARCHAR(80),
Date DATE,
total_cases BINARY,
total_deaths BINARY,
population BINARY
)
;INSERT INTO totals_per_location
SELECT deaths.location, 
		SUM(deaths.new_cases) as tot_cases, 
		SUM(deaths.new_deaths) as tot_deaths, 
        SUM(vac.new_vaccinations) as tot_vaccinations, 	
        vac.population
FROM covid_deaths as deaths
JOIN vac
on deaths.location = vac.location
WHERE deaths.location <> '' 
	and deaths.location <> 'World' 
	and deaths.location NOT LIKE '%income%'
    GROUP BY location
ORDER BY tot_deaths
LIMIT 10;


SELECT *
FROM totals_per_location;


WITH CTE_locationAVGS 
(location, tot_cases, tot_deaths,tot_vaccines)
as
(
SELECT deaths.location, SUM(deaths.new_cases), SUM(deaths.new_deaths), SUM(vac.new_vaccinations)
FROM covid_deaths as deaths
JOIN vac 
ON deaths.location = vac.location
WHERE deaths.continent <> ''
GROUP BY location
)
SELECT AVG(tot_cases) as AVG_cases, AVG(tot_deaths) as AVG_deaths,AVG(tot_vaccines) as AVG_vaccines
FROM CTE_locationAVGS;






 