/*

Queries used for Data Visualization of COVID Data in Tableau Project

*/



-- 1. Total cases, deaths, and death percentage worldwide

SELECT SUM(new_cases) AS total_cases, 
	SUM(CAST(new_deaths AS UNSIGNED)) as total_deaths, 
	(SUM(CAST(new_deaths as UNSIGNED))/(SUM(New_Cases))*100) as DeathPercentage
From COVID_Portfolio.covid_deaths
-- Where location like '%states%'
where continent is not null 
-- Group By date
order by 1,2;

-- The following query includes "International"  location if needed

-- Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as UNSIGNED)) as total_deaths, 
-- 		SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
-- From COVID_Portfolio.covid_deaths
-- -- Where location like '%states%'
-- where location = 'World'
-- -- Group By date
-- order by 1,2


-- 2. Ranking of continents based on death count

-- We take these out as they are not included in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(CONVERT(new_deaths, UNSIGNED)) as TotalDeathCount
From COVID_Portfolio.covid_deaths
-- Where location like '%states%'
Where continent is null OR continent = ' ' 
and location NOT IN ('World', 'European Union', 'International', 'High income', 'Low income')
Group by location
order by TotalDeathCount desc;


-- 3. Ranking of countries based on percent of population infected
-- 		includes highest infection count for each country over time

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, 
	Max((total_cases/population))*100 as PercentPopulationInfected
From COVID_Portfolio.covid_deaths
-- Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc;


-- 4. Ranking of countries with highest percent of population infected over time


Select Location, Population, date AS Date, MAX(total_cases) as HighestInfectionCount,  
	Max((total_cases/population))*100 as PercentPopulationInfected
From COVID_Portfolio.covid_deaths
-- Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc;















