-- Covid19 Data Exploration
-- Covid19 up to August 16, 2021

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;


----------------------------------------------------------------------------------------------------

-- This is the data we will be starting with

SELECT location, population, date,new_cases, new_deaths, total_cases, total_deaths 
FROM PortfolioProject..CovidDeaths
WHERE continent  IS NOT NULL
ORDER BY 1, 3;



-----------------------------------------------------------------------------------------------------

-- Countries with the highest infection

SELECT location, population, max(total_cases) AS highest_cases
FROM PortfolioProject..CovidDeaths
WHERE continent  IS NOT NULL
GROUP BY population,location
ORDER BY highest_cases DESC


-----------------------------------------------------------------------------------------------------

-- Countries with the highest infection rate compared to their population

SELECT location, population, max(total_cases) AS highest_cases, max((total_cases/population))*100 AS percentage_of_population_infeted 
FROM PortfolioProject..CovidDeaths
WHERE continent  IS NOT NULL
GROUP BY population,location
ORDER BY highest_cases DESC


----------------------------------------------------------------------------------------------------

-- Showing Countries with Highest Death Count Per Population

SELECT Location, population, MAX(cast(Total_deaths as int)) AS Highest_Deaths
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY Location, population
ORDER BY Highest_Deaths DESC


------------------------------------------------------------------------------------------------------

-- Countries with the Highest Death Rate compared to Population

SELECT continent, MAX(cast(Total_deaths as int)) AS Total_Deaths_Count
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY Total_Deaths_Count DESC


------------------------------------------------------------------------------------------------------

-- Total Cases vs Total Deaths
-- Displaying percentage of death after COVID19 happened

SELECT location, population, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1, 3


---------------------------------------------------------------------------------------------------------

-- Continents with the Highest Deaths

SELECT location, MAX(CAST(total_deaths as int)) AS highest_death
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL AND location <> 'World' AND location <> 'International'
GROUP BY location
ORDER BY highest_death DESC


----------------------------------------------------------------------------------------------------------

-- Global Numbers

SELECT date, SUM(CAST(new_cases AS int)) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, ROUND((SUM(cast(new_deaths AS int))/SUM(new_cases) * 100),2) AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date

----------------------------------------------------------------------------------------------------------

-- Total Population vs Total Vaccinations
-- Percentage of population that has been vaccinated

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


-------------------------------------------------------------------------------------------------------------

-- Use CTE to calculate

WITH PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.Location ORDER BY dea.location, 
dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-----------------------------------------------------------------------------------------------------------------

-- Create TEMP Table

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


-----------------------------------------------------------------------------------------------------------------

-- Uploading data into TEMP Table

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.Location ORDER BY dea.location, 
dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


----------------------------------------------------------------------------------------------------------------------

-- Checking TEMP TABLE

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-----------------------------------------------------------------------------------------------------------------------

-- Creating View to store data for later visualization

CREATE View PercentPopVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.Location ORDER BY dea.location, 
dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM #PercentPopulationVaccinated