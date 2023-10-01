			-------------------------- SQL Queries Imported into Tableau --------------------------

			-------------------------- Global Impact related, SQL Queries Imported into Tableau --------------------------

-- Query #1: Global Numbers related to COVID-19 --
-- Shows global total cases where COVID-19 is present, total deaths and % of deaths caused by COVID-19 --
-- Columns: total_cases, total_deaths & DeathPercentage
SELECT SUM(new_cases) AS total_cases,
       SUM(cast(new_deaths as bigint)) AS total_deaths,
	   SUM(cast(new_deaths as bigint))/ NULLIF(SUM(new_cases),0)*100 AS DeathPercentage
FROM Covid_PortfolioProject..['CovidDeaths$']
WHERE continent IS NOT NULL
ORDER BY total_cases, total_deaths

-- Query #2: Total Death Count Per Continent --
-- Columns: location, TotalDeathCount
SELECT location,
	   SUM(CAST(new_deaths as int))  AS TotalDeathCount 
FROM Covid_PortfolioProject..['CovidDeaths$']
WHERE continent IS NULL AND location NOT IN ('World', 'European Union', 'International') -- EU is excluded because it is part of Europe
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Query #3: Percent Population Infected Per Country --
-- Columns: Location, Population, HighestInfectionCount, PercentPopulationInfected
SELECT
    location,
    population,
    COALESCE(NULLIF(MAX(total_cases), 0), 0) AS HighestInfectionCount,
    COALESCE(NULLIF(MAX(total_cases / population), 0) * 100, 0) AS PercentPopulationInfected
FROM Covid_PortfolioProject..['CovidDeaths$']
GROUP BY location, Population
ORDER BY PercentPopulationInfected DESC

-- Query #4: Percent Population Infected --
-- Columns: Location, Population, date, HighestInfectionCount, PercentPopulationInfected
SELECT
    location,
    population,
    date,
    COALESCE(MAX(total_cases), 0) AS HighestInfectionCount,
    COALESCE(MAX((total_cases / population)) * 100, 0) AS PercentPopulationInfected
FROM Covid_PortfolioProject..['CovidDeaths$']
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC


			-------------------------- SEA related, SQL Queries Imported into Tableau --------------------------
-- Query #5: SEA Numbers related to COVID-19 --
-- Shows global total cases where COVID-19 is present, total deaths and % of deaths caused by COVID-19 --
-- Columns: total_cases_SEA, total_deaths_SEA & DeathPercentage_SEA
SELECT
    SUM(new_cases) AS total_cases_SEA,
    SUM(CAST(new_deaths AS BIGINT)) AS total_deaths_SEA,
    SUM(CAST(new_deaths AS BIGINT)) / NULLIF(SUM(new_cases), 0) * 100 AS DeathPercentage_SEA
FROM
    Covid_PortfolioProject..['CovidDeaths$']
WHERE
    location IN ('Brunei', 'Cambodia', 'Timor', 'Indonesia', 'Laos', 'Malaysia', 'Myanmar', 'Philippines', 'Singapore', 'Thailand', 'Vietnam')
    AND continent IS NOT NULL
ORDER BY
    total_cases_SEA, total_deaths_SEA

-- Query #6: Total Death Count for countries, grouped by SEA --
-- Columns: location, TotalDeathCount_SEA, DeathPercentage_SEA
SELECT
    location,
    SUM(CAST(new_deaths AS INT)) AS TotalDeathCount_SEA,
    SUM(cast(new_deaths as bigint))/ NULLIF(SUM(new_cases),0)*100 AS DeathPercentage_SEA
FROM
    Covid_PortfolioProject..['CovidDeaths$']
WHERE
    location IN ('Brunei', 'Cambodia', 'Timor', 'Indonesia', 'Laos', 'Malaysia', 'Myanmar', 'Philippines', 'Singapore', 'Thailand', 'Vietnam')
    AND continent IS NOT NULL
GROUP BY
    location
ORDER BY
    DeathPercentage_SEA DESC


			-------------------------- Initial EDA --------------------------

-- Inspection of CovidDeaths Dataset --
SELECT *
FROM Covid_PortfolioProject..['CovidDeaths$']
WHERE continent IS NOT NULL
ORDER BY 3,4 -- Sort by 'location' & 'date' ASC

-- Inspection of CovidVaccinations Dataset --
SELECT *
FROM Covid_PortfolioProject..['CovidVaccinations$']
ORDER BY 3,4 -- Sort by 'location' & 'date' ASC

							-- Inspecting % of deaths for confirmed COVID cases --
		-- DeathPercentage is calculated by: (total_deaths/total_cases) * 100 --
-- Shows likelihood of dying if you contract COVID in U.S
SELECT Location, date, total_cases, total_deaths, CONVERT(decimal,total_deaths)/CONVERT(decimal,total_cases)*100 AS DeathPercentage
FROM Covid_PortfolioProject..['CovidDeaths$']
WHERE Location = 'United States' AND continent IS NOT NULL
ORDER BY 1,2

-- Shows likelihood of dying if you contract COVID in Singapore
SELECT Location, date, total_cases, total_deaths, CONVERT(decimal,total_deaths)/CONVERT(decimal,total_cases)*100 AS DeathPercentage
FROM Covid_PortfolioProject..['CovidDeaths$']
WHERE Location LIKE '%Singapore%' AND continent IS NOT NULL
ORDER BY 1,2

							-- Inspecting Percentage of Population Infected by COVID --
											-- Country_Level EDA --
		-- PercentPopulationInfected is calculated by: (total_cases/population) * 100 --
-- Shows percentage of population that got COVID in U.S
SELECT Location, date, Population, total_cases, CONVERT(decimal,total_cases)/CONVERT(decimal,Population)*100 AS PercentPopulationInfected
FROM Covid_PortfolioProject..['CovidDeaths$']
WHERE Location = 'United States' AND continent IS NOT NULL
ORDER BY 1,2

-- Shows percentage of population that got COVID in Singapore
SELECT Location, date, Population, total_cases, CONVERT(decimal,total_cases)/CONVERT(decimal,Population)*100 AS PercentPopulationInfected
FROM Covid_PortfolioProject..['CovidDeaths$']
WHERE Location LIKE '%Singapore%' AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, date, total_cases, Population, MAX(CONVERT(decimal,total_cases)/CONVERT(decimal,Population))*100 AS PercentPopulationInfected
FROM Covid_PortfolioProject..['CovidDeaths$']
-- WHERE Location LIKE '%states%' AND continent IS NOT NULL
GROUP BY Location, date, total_cases, Population
ORDER BY MAX(CONVERT(decimal,total_cases)/CONVERT(decimal,Population))*100 DESC

-- Looking at Countries with Highest Death Count
SELECT Location,
MAX(cast(total_deaths as bigint)) AS TotalDeathCount
-- MAX(CONVERT(decimal,total_deaths)/CONVERT(decimal,Population))*100 AS PercentPopulationDead
FROM Covid_PortfolioProject..['CovidDeaths$']
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY MAX(cast(total_deaths as bigint)) DESC

											-- Continent_Level EDA --
SELECT continent, MAX(cast(total_deaths as bigint)) AS TotalDeathCount
FROM Covid_PortfolioProject..['CovidDeaths$']
WHERE continent IS NOT NULL
--AND
--location NOT LIKE '%income%'
GROUP BY continent
ORDER BY TotalDeathCount DESC

											-- Global Level EDA on Death Percentage --
-- Overall total_cases, total_deaths, overall DeathPercentage
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as bigint)) AS total_deaths, SUM(cast(new_deaths as bigint))/ NULLIF(SUM(new_cases),0)*100 AS DeathPercentage
FROM Covid_PortfolioProject..['CovidDeaths$']
WHERE continent IS NOT NULL
ORDER BY total_cases, total_deaths

													-- Covid Vaccination EDA --

					-- Obtaining culmulative count of people who are vaccinated via CTE & Window Function --
-- Double check on calculation for the below code block --
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM Covid_PortfolioProject..['CovidDeaths$'] AS dea
INNER JOIN Covid_PortfolioProject..['CovidVaccinations$'] AS vac ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY dea.location, dea.date
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentagePopulationVaccinated
FROM PopvsVac
WHERE (RollingPeopleVaccinated/population)*100 < 100 -- Exclude locations where vaccination has already reached 100%. We focus on locations that are still in need of more vaccination
-- AND location = 'Singapore'
ORDER BY 6 DESC
-- Double check on calculation for the above code block --