--Looking at the data we are working with

SELECT 
    *
FROM 
    portfolioproject..CovidDeaths
WHERE
    continent IS NOT NULL
order by 
    3,4;


-- Looking at the Total Cases vs Total Deaths
-- Shows likelihood of death when contracting covid in your country

SELECT 
    location, 
	date, 
	total_cases, 
	total_deaths, 
	CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT) * 100 AS DeathPercentage
FROM 
    portfolioproject..CovidDeaths
WHERE 
    location = 'Netherlands'
    AND continent IS NOT NULL
	AND total_cases IS NOT NULL AND total_cases <> 0
	AND total_deaths IS NOT NULL AND total_deaths <> 0
ORDER BY 1,2;


-- Looking at the Total Cases vs Population
-- Shows what percentage of population has contracted covid in your country

SELECT 
    location, 
	date, 
	population, 
	total_cases,  
	CAST(total_cases AS FLOAT) / CAST(population AS FLOAT) * 100 AS PercentageContractedCovid
FROM 
    portfolioproject..CovidDeaths
WHERE 
    location = 'Netherlands'
    AND continent IS NOT NULL
    AND (total_cases IS NOT NULL AND total_cases <> 0)
ORDER BY 1,2;


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT 
    location, 
	population, 
	MAX(total_cases) AS HighestInfectionCount,  
	CAST(MAX(total_cases) AS FLOAT) / CAST(population AS FLOAT) * 100 AS PercentageInfected
FROM 
    portfolioproject..CovidDeaths
WHERE 
    continent IS NOT NULL
GROUP BY 
    location, population
ORDER BY 
    PercentageInfected DESC;


--Deathcount by Continent

SELECT 
    continent, 
	MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM 
    portfolioproject..CovidDeaths
WHERE 
    continent IS NOT NULL
GROUP BY 
    continent
ORDER BY 
    TotalDeathCount DESC;


-- Showing the Countries with the Highest Death Count

SELECT 
    location, 
	MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM 
    portfolioproject..CovidDeaths
WHERE 
    continent IS NOT NULL
GROUP BY 
    location
ORDER BY 
    TotalDeathCount DESC;


-- GLOBAL NUMBERS

SELECT
    date,
    SUM(CAST(new_cases AS INT)) AS total_cases,
    SUM(CAST(new_deaths AS INT)) AS total_deaths,
    CASE
        WHEN SUM(CAST(new_cases AS INT)) = 0 THEN NULL
        ELSE SUM(CAST(new_deaths AS INT)) * 100.0 / NULLIF(SUM(CAST(new_cases AS INT)), 0)
    END AS DeathPercentage
FROM
    portfolioproject..CovidDeaths
WHERE
    continent IS NOT NULL
    AND (new_cases IS NOT NULL AND new_cases <> 0)
    AND (new_deaths IS NOT NULL AND new_deaths <> 0)
GROUP BY
    date
ORDER BY
    date;


-- Looking at Total Population vs Vaccinations
-- USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, rollingcountvaccinations)
AS
(
SELECT
    dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingCountVaccinations
FROM
    PortfolioProject..CovidDeaths dea
JOIN
    PortfolioProject..CovidVaccinations vac
ON
    dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT 
    *, 
    (rollingcountvaccinations/population) * 100
FROM 
    PopvsVac
Order by 
    2,3;


-- CREATING A TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingCountVaccinations numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT
    dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingCountVaccinations
FROM
    PortfolioProject..CovidDeaths dea
JOIN
    PortfolioProject..CovidVaccinations vac
ON
    dea.location = vac.location
    and dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL

SELECT 
    *, 
    (rollingcountvaccinations/population) * 100
FROM 
    #PercentPopulationVaccinated;


--Creating a view for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
    SELECT
        dea.continent,
	    dea.location,
	    dea.date,
	    dea.population,
	    vac.new_vaccinations,
	    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingCountVaccinations
    FROM
        PortfolioProject..CovidDeaths dea
    JOIN
        PortfolioProject..CovidVaccinations vac
    ON
        dea.location = vac.location
        and dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT
    *
FROM
    PercentPopulationVaccinated;