SELECT *
FROM COVID_Project..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM COVID_Project..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases VS Total Deaths

SELECT 
Location, 
date,
total_cases, 
total_deaths, 
((total_deaths/total_cases) * 100) AS death_percentage
FROM COVID_Project..CovidDeaths
WHERE Location = 'United States'
AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases VS Population
-- Shows what percentage of population got Covid

SELECT Location, date, population, total_cases,  
((total_cases/population) * 100) AS Infection_Rate
FROM COVID_Project..CovidDeaths
WHERE Location = 'United States'
AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population

SELECT Location, population,MAX(total_cases) AS Highest_Infection_Count,  
MAX((total_cases/population) * 100) AS Infection_Rate
FROM COVID_Project..CovidDeaths
--WHERE Location = 'United States'
WHERE continent IS NOT NULL
GROUP BY Location, Population
ORDER BY Infection_Rate DESC

-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(CAST(Total_deaths AS INT)) AS Total_Death_Count
FROM COVID_Project..CovidDeaths
--WHERE Location = 'United States'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY Total_Death_Count DESC


-- Let's break things down by continent

--Showing continents with the highest death count per population


SELECT location, MAX(CAST(Total_deaths AS INT)) AS Total_Death_Count
FROM COVID_Project..CovidDeaths
--WHERE Location = 'United States'
WHERE continent IS NULL
GROUP BY location
ORDER BY Total_Death_Count DESC


-- Global Numbers

SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths, SUM(CAST(new_deaths AS INT))/SUM(New_cases)* 100 AS Death_Percentage
FROM COVID_Project..CovidDeaths
--WHERE Location = 'United States'
WHERE continent IS NOT NULL
--GROUP BY Date
ORDER BY 1,2


--Looking at Total Population vs Vaccinations

WITH PopvsVac (continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS INT)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated 
FROM COVID_Project..CovidDeaths dea
JOIN COVID_Project..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac




-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS INT)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated 
FROM COVID_Project..CovidDeaths dea
JOIN COVID_Project..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

USE COVID_Project


CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS INT)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated 
FROM COVID_Project..CovidDeaths dea
JOIN COVID_Project..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3