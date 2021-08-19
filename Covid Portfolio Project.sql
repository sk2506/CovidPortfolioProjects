SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4;

--SELECT *
--FROM PortfolioProject..CovidVaccination
--ORDER BY 3,4;

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood	of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%Canada%' AND continent is not NULL
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, date, total_cases, Population, ROUND((total_cases/Population)*100,2) AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%Canada%' AND continent is not NULL
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) AS Highest_Infection_Count, ROUND(MAX((total_cases/population))*100,2) AS Percent_Population_Infected
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population
ORDER BY Percent_Population_Infected DESC

-- Showing Countries with Highest Death Count Per Population

SELECT Location, MAX(cast(Total_deaths as int)) AS Total_Deaths_Count
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY Location
ORDER BY Total_Deaths_Count DESC

-- Let's break things down by continent
-- Showing continents with the highest death count per population

SELECT continent, MAX(cast(Total_deaths as int)) AS Total_Deaths_Count
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY Total_Deaths_Count DESC


-- Global Numbers

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, ROUND((SUM(cast(new_deaths AS int))/SUM(new_cases) * 100),2) AS Death_Percentage
FROM PortfolioProject..CovidDeaths
-- WHERE Location like '%Canada%' AND 
WHERE continent is not NULL
-- GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.Location ORDER BY dea.location, 
dea.Date) AS Rolling_People_Vaccinated
-- ,(Rolling_People_Vaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE

WITH PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.Location ORDER BY dea.location, 
dea.Date) AS RollingPeopleVaccinated
-- ,(Rolling_People_Vaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.Location ORDER BY dea.location, 
dea.Date) AS RollingPeopleVaccinated
-- ,(Rolling_People_Vaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualization

CREATE View PercentPopVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.Location ORDER BY dea.location, 
dea.Date) AS RollingPeopleVaccinated
-- ,(Rolling_People_Vaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM #PercentPopulationVaccinated