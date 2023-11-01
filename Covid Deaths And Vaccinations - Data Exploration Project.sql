--Showing the whole data

SELECT * 
FROM CovidDeaths
WHERE continent IS NOT NULL;

SELECT *
FROM CovidVaccinations;

--Selecting Data the I am going to use in CovidDeaths Table

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- Showing Total Cases vs Total Deaths and there percentage in China

SELECT location, date, total_cases, total_deaths, ((total_deaths/total_cases) * 100) AS Death_To_Case_Ratio
FROM CovidDeaths
WHERE location LIKE '%china%' AND continent IS NOT NULL
ORDER BY 1, 2;

-- Creating a view for the previous data

CREATE VIEW Case_To_Death_View AS 
SELECT location, date, total_cases, total_deaths, ((total_deaths/total_cases) * 100) AS Death_To_Case_Ratio
FROM CovidDeaths
WHERE location LIKE '%china%' AND continent IS NOT NULL;

--Showing Total Cases vs Population and there percentage in China

SELECT location, date, population, total_cases, ((total_cases/population) * 100) AS Cases_To_Population_Ratio
FROM CovidDeaths
WHERE location LIKE '%china%' AND continent IS NOT NULL
ORDER BY 1, 2;

-- Creating a view for the previous data

CREATE VIEW Case_To_Population_View AS 
SELECT location, date, population, total_cases, ((total_cases/population) * 100) AS Cases_To_Population_Ratio
FROM CovidDeaths
WHERE location LIKE '%china%' AND continent IS NOT NULL;

--Showing Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS Maximum_Cases, MAX(((total_cases/population) * 100)) AS Cases_To_Population_Ratio
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC;

--Showing Countries with Highest Deaths

SELECT location, MAX(CAST(total_deaths AS INT)) AS Maximum_Deaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Maximum_Deaths DESC;

--Showing Countries with Highest Death Rate compared to Population

SELECT location, population, MAX(CAST(total_deaths AS INT)) AS Maximum_Deaths, MAX(((total_deaths/population) * 100)) AS Death_To_Population_Ratio
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC;

--Showing Contenints with Highest Deaths

SELECT location, MAX(CAST(total_deaths AS INT)) AS Maximum_Deaths
FROM CovidDeaths
WHERE continent IS NULL AND location <> 'World'
GROUP BY location
ORDER BY Maximum_Deaths DESC;

--Showing Contenints with highest death per popilation

SELECT location, population, MAX(CAST(total_deaths AS INT)) AS Maximum_Deaths, MAX(total_deaths / population) * 100 AS Deaths_To_Population_Ratio
FROM CovidDeaths
WHERE continent IS NULL AND location <> 'World'
GROUP BY location, population
ORDER BY Deaths_To_Population_Ratio DESC;

--Showing Global Numbers by date

SELECT date, SUM(new_cases) AS Date_Cases, SUM(CAST(new_deaths AS INT)) AS Date_Deaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

SELECT date, SUM(new_cases) AS Date_Cases, SUM(CAST(new_deaths AS INT)) AS Date_Deaths, (SUM(CAST(new_deaths AS INT)) / SUM(new_cases)) * 100 AS Death_To_Case_Ratio
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

-- Joining the CovidDeaths Table to The CovidVaccination Table

SELECT *
FROM CovidDeaths
JOIN CovidVaccinations
ON CovidDeaths.location = CovidVaccinations.location AND CovidDeaths.date = CovidVaccinations.date
WHERE CovidDeaths.continent IS NOT NULL
ORDER BY CovidDeaths.location;

-- Showing The Total Population vs Total Vaccinations

SELECT CD.location, CD.continent, CD.population, MAX(CV.total_vaccinations) AS Total_Vaccinations, (MAX(CV.total_vaccinations) / CD.population) * 100 AS Vaccinations_To_Population_Ratio
FROM CovidDeaths AS CD
JOIN CovidVaccinations AS CV
ON CD.location = CV.location AND CD.date = CV.date
WHERE CD.continent IS NOT NULL AND new_vaccinations IS NOT NULL
GROUP BY CD.location, CD.continent, CD.population
ORDER BY Vaccinations_To_Population_Ratio DESC;

-- Showing day by day Vaccination for each country

SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
FROM CovidDeaths AS CD
JOIN CovidVaccinations AS CV
ON CD.location = CV.location AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
ORDER BY CD.location;

-- Showing Accumilated Vaccination for each country day by day

SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(CONVERT(INT, CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS Accumilated_Vaccinations_Per_Country
FROM CovidDeaths AS CD
JOIN CovidVaccinations AS CV
ON CD.location = CV.location AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
ORDER BY CD.location;

-- Use CTE for the previous query and use it to calculate the Accumilated Vaccination per Country Ratio

WITH CTE_Accumilated_Vacinations AS (
SELECT CD.continent, CD.location, CD.population, CV.new_vaccinations,
SUM(CONVERT(INT, CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS Accumilated_Vaccinations_Per_Country
FROM CovidDeaths AS CD
JOIN CovidVaccinations AS CV
ON CD.location = CV.location AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
)
SELECT *, (Accumilated_Vaccinations_Per_Country / population) * 100 AS Accumilated_Vaccinations_Per_Country_Ratio
FROM CTE_Accumilated_Vacinations
ORDER BY location;

-- Creating a view for the previous data

CREATE VIEW Accumilated_Vaccinations AS 
WITH CTE_Accumilated_Vacinations AS (
SELECT CD.continent, CD.location, CD.population, CV.new_vaccinations,
SUM(CONVERT(INT, CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS Accumilated_Vaccinations_Per_Country
FROM CovidDeaths AS CD
JOIN CovidVaccinations AS CV
ON CD.location = CV.location AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
)
SELECT *, (Accumilated_Vaccinations_Per_Country / population) * 100 AS Accumilated_Vaccinations_Per_Country_Ratio
FROM CTE_Accumilated_Vacinations;
