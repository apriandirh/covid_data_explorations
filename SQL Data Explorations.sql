SELECT * FROM PortfolioProject..CovidDeaths
SELECT * FROM PortfolioProject..CovidVaccinations

--Select data that will be using
SELECT location, date, total_cases, new_cases, total_deaths, population FROM PortfolioProject..CovidDeaths WHERE continent is not null ORDER BY 1, 2

--Looking Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2

--Percentage of death in specific location
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%indonesia%' and continent is not null
ORDER BY 1, 2

--Looking Total Cases vs Populations
SELECT location, date, total_cases, population, (total_cases/population)*100 AS Cases_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2

--Percentage of cases in specific location
SELECT location, date, total_cases, total_deaths, (total_cases/population)*100 AS Cases_Percentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%indonesia%' and continent is not null
ORDER BY 1, 2

--Looking at Countries that have a highest infection compared to populations
SELECT location, population, max(total_cases), max((total_cases/population))*100 AS Infected_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
order by Infected_Percentage desc

--Looking at Countries that have a highest deaths compared to populations
SELECT location, population, MAX(cast(total_deaths as int)) highest_deaths, MAX((total_deaths/population))*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
order by Death_Percentage desc

--Looking at Continent that have a highest deaths compared to populations
SELECT continent, MAX(cast(total_deaths as int)) highest_deaths
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
order by highest_deaths desc

--Global Numbers
SELECT SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths AS INT)) as Total_Deaths, SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 AS Total_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2

--Looking total population vs vaccinated
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, SUM(CONVERT(INT, V.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS Summarize_Vaccinations
FROM PortfolioProject..CovidDeaths as D
JOIN PortfolioProject..CovidVaccinations as V
	ON D.location = V.location
	AND D.date = V.date
WHERE D.continent IS NOT NULL
ORDER BY 2, 3

--Looking total population vs vaccinated using CTE
WITH PvsV (Continent, Location, Date, Population, Vaccination, Summarize)
AS
(
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, SUM(CONVERT(INT, V.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS Summarize_Vaccinations
FROM PortfolioProject..CovidDeaths as D
JOIN PortfolioProject..CovidVaccinations as V
	ON D.location = V.location
	AND D.date = V.date
WHERE D.continent IS NOT NULL
)
SELECT *, (Summarize/Population)*100 AS Percentage FROM PvsV

--Looking total population vs vaccinated using Temp Table
DROP TABLE IF EXISTS #PvsV
CREATE TABLE #PvsV
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
Summarize_Vaccination numeric
)
INSERT INTO #PvsV
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, SUM(CONVERT(INT, V.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS Summarize_Vaccinations
FROM PortfolioProject..CovidDeaths as D
JOIN PortfolioProject..CovidVaccinations as V
	ON D.location = V.location
	AND D.date = V.date
WHERE D.continent IS NOT NULL

SELECT *, (Summarize_Vaccination/Population)*100 AS Percentage FROM #PvsV

--Create View for later
CREATE VIEW PvsV AS
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, SUM(CONVERT(INT, V.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS Summarize_Vaccinations
FROM PortfolioProject..CovidDeaths as D
JOIN PortfolioProject..CovidVaccinations as V
	ON D.location = V.location
	AND D.date = V.date
WHERE D.continent IS NOT NULL

SELECT * FROM PvsV