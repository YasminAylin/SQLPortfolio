SELECT *
FROM dbo.CovidDeaths
WHERE continent is not null
ORDER BY 3,4

SELECT *
FROM dbo.CovidVaccinations
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
ORDER BY 1,2

-------------------------------------------------------------------
-- Total Cases VS Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_deaths, total_cases, (CAST(total_deaths AS decimal)/ total_cases)*100 AS DeathPercentage
FROM dbo.CovidDeaths
WHERE location like 'Ethiopia'
ORDER BY 1,2

--Total cases VS Population
--Shows what percentage of population got covid

SELECT location, date, Population, total_cases, CAST(total_cases AS decimal)/ CAST(Population AS decimal)*100 AS PopulationPercentage
FROM dbo.CovidDeaths
WHERE location like 'Ethiopia'
ORDER BY 1,2

--Countries with Highest Infection Rate compared to Population

SELECT location, Population, MAX(total_cases) AS HighestInfectionCount , MAX(CAST(total_cases AS decimal)/ CAST(Population AS decimal)*100) AS PopulationPercentage
FROM dbo.CovidDeaths
GROUP BY location, Population
ORDER BY PopulationPercentage DESC


--Countries with Highest Death per Continent

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent is not null
GROUP BY  continent
ORDER BY TotalDeathCount DESC

--Countries with Highest Death per Population

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


--Global Numbers

--Precentage of Deaths per day
SELECT date, SUM(new_cases) AS TotalCases , SUM(CAST(new_deaths AS decimal)) AS TotalDeaths, SUM(CAST(new_deaths AS decimal))/ SUM(new_cases)*100 AS DeathPercentage
FROM dbo.CovidDeaths
WHERE continent is not null and new_cases <> 0
GROUP BY date
ORDER BY 1,2

--Total Precentage of Deaths
SELECT SUM(new_cases) AS TotalCases , SUM(CAST(new_deaths AS decimal)) AS TotalDeaths, SUM(CAST(new_deaths AS decimal))/ SUM(new_cases)*100 AS DeathPercentage
FROM dbo.CovidDeaths
WHERE continent is not null and new_cases <> 0
ORDER BY 1,2


-- Total Population VS Vaccinattion

--Use CTE
WITH PopVSVac (Continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(CAST(Vac.new_vaccinations AS decimal)) OVER (Partition by Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
FROM dbo.CovidDeaths AS Dea
JOIN dbo.CovidVaccinations AS Vac
     ON  Dea.location = Vac.location
	 AND Dea.date = Vac.date
WHERE Dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population)
FROM PopVSVac


--TEMP Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(CAST(Vac.new_vaccinations AS decimal)) OVER (Partition by Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
FROM dbo.CovidDeaths AS Dea
JOIN dbo.CovidVaccinations AS Vac
     ON  Dea.location = Vac.location
	 AND Dea.date = Vac.date
WHERE Dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creat View to Store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(CAST(Vac.new_vaccinations AS decimal)) OVER (Partition by Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
FROM dbo.CovidDeaths AS Dea
JOIN dbo.CovidVaccinations AS Vac
     ON  Dea.location = Vac.location
	 AND Dea.date = Vac.date
WHERE Dea.continent is not null
--ORDER BY 2,3
