/*

COVID-19 Data Exploration using SQL

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, 
Creating Views, and Converting Data Types using MySQL

*/

SELECT *
FROM COVID_Portfolio.covid_deaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

SELECT *
FROM COVID_Portfolio.covid_deaths
ORDER BY 3,4;

-- Select the data that we are going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM COVID_Portfolio.covid_deaths
ORDER BY 1,2;

-- Total Cases versus Total Deaths
-- Shows likelihood of dying if you contract COVID in the United States

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathRate
FROM COVID_Portfolio.covid_deaths
WHERE location LIKE '%states%'
AND continent IS NOT NULL
ORDER BY 1,2;


-- Total Cases versus Population
-- Shows what percentage of the population  infected with COVID

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentOfPopulationInfected
FROM COVID_Portfolio.covid_deaths
ORDER BY 1,2;

-- Countries with Highest Infection Rate relative to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM COVID_Portfolio.covid_deaths
GROUP BY location, population
ORDER BY PercentPopulationInfected desc;

-- Countries with Highest Death Count relative to Population

SELECT continent, MAX(cast(total_deaths as UNSIGNED)) AS TotalDeathCount
FROM COVID_Portfolio.covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc;

-- DATA BASED ON CONTINENT

-- Continents with Highest Death Count per Population

SELECT continent, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM COVID_Portfolio.covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc;

-- Global Cases and Deaths

SELECT SUM(new_cases) as total_cases, 
	SUM(cast(new_deaths as UNSIGNED)) as TotalDeaths,
    SUM(cast(new_deaths as UNSIGNED))/SUM(new_cases)*100 AS DeathPercentage
    FROM COVID_Portfolio.covid_deaths
    WHERE continent IS NOT NULL
    ORDER BY 1,2;

-- Total Population versus Vaccinations
-- Shows percentage of Population that has received at least one COVID vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations,
	SUM(CONVERT(vac.new_vaccinations, UNSIGNED)) OVER (PARTITION BY dea.location 
	ORDER BY dea.location, dea.date) AS CummulativeAmountVaccinated
FROM COVID_Portfolio.covid_deaths dea
JOIN COVID_Portfolio.covid_vaccinations vacc
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- Using CTE to perform calculation on the partitions of the previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, CummulativeAmountVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations,
	SUM(CONVERT(vac.new_vaccinations, UNSIGNED)) OVER (PARTITION BY dea.location 
	ORDER BY dea.location, dea.date) AS CummulativeAmountVaccinated
FROM COVID_Portfolio.covid_deaths dea
JOIN COVID_Portfolio.covid_vaccinations vacc
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (CummulativeAmountVaccinated/population)*100
FROM PopvsVac;

-- Using Temporary Table to perform calculation on the partitions of the previous query

DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255), 
date datetime,
population numeric,
new_vaccinations numeric
CummulativeAmountVaccinated numeric
)

INSERT INTO 
SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations,
	SUM(CONVERT(vac.new_vaccinations, UNSIGNED)) OVER (PARTITION BY dea.location 
	ORDER BY dea.location, dea.date) AS CummulativeAmountVaccinated
FROM COVID_Portfolio.covid_deaths dea
JOIN COVID_Portfolio.covid_vaccinations vacc
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (CummulativeAmountVaccinated/population)*100
FROM PercentPopulationVaccinated

-- Create View to store data for later visualizations

CREATE VIEW COVID_Portfolio.Global_Numbers AS
SELECT date, SUM(new_cases) as total_cases, 
	SUM(cast(new_deaths as UNSIGNED)) as TotalDeaths,
    SUM(cast(new_deaths as UNSIGNED))/SUM(new_cases)*100 AS DeathPercentage
    FROM COVID_Portfolio.covid_deaths
    WHERE continent IS NOT NULL
    ORDER BY 1,2;
