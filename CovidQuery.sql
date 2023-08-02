SELECT * FROM alexanalyst.dbo.coviddeaths
ORDER BY 3, 4

--select * from alexanalyst.dbo.covidvaccinations
--order by 3, 4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM   CovidDeaths
ORDER BY location, date


-- Looking at total cases vs total deaths
-- Shows chance of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, total_deaths / total_cases * 100 AS DeathPercentage
FROM   CovidDeaths
ORDER BY location, date


-- Looking at total cases vs population
--Shows what percentage of population contracted covid
SELECT location, date, population, total_cases, total_cases / population * 100 AS CovidPercentage
FROM   CovidDeaths
ORDER BY location, date

-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestCaseCount, MAX(total_cases / population) * 100 AS CovidPercentage
FROM   CovidDeaths
GROUP BY location, population
ORDER BY CovidPercentage DESC


-- Looking at countries with highest death count per population
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM   CovidDeaths
WHERE (continent IS NOT NULL)
GROUP BY location
ORDER BY totaldeathcount DESC


-- Breaking things down by continent
-- Showing continents with highest death count
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM   CovidDeaths
WHERE (continent IS NOT NULL)
GROUP BY continent
ORDER BY totaldeathcount DESC


-- Global numbers
SELECT date, SUM(new_cases) AS totalCases, SUM(CAST(new_deaths AS int)) AS totalDeaths, SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 AS DeathPercentage
FROM   CovidDeaths
WHERE (continent IS NOT NULL)
GROUP BY date
ORDER BY date, totalCases

SELECT SUM(new_cases) AS totalCases, SUM(CAST(new_deaths AS int)) AS totalDeaths, SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 AS DeathPercentage
FROM   CovidDeaths
WHERE (continent IS NOT NULL)
ORDER BY totalCases, totalDeaths


-- Looking at total population vs vaccinations
WITH PopvsVac (continent, location, date, population, new_vaccinations, peoplevaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as float)) OVER (partition by dea.location order by dea.location, dea.date) AS PeopleVaccinated
FROM AlexAnalyst..coviddeaths AS dea
JOIN alexanalyst..covidvaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL)
SELECT *, (peoplevaccinated/population)*100 AS PercentVaccinated FROM PopvsVac


--Temp table
DROP TABLE IF EXISTS #PercentVaccinated
CREATE TABLE #PercentVaccinated(
Continent nvarchar(255), location nvarchar(255), date datetime,
population numeric, new_vaccinations numeric, peoplevaccinated numeric)

INSERT INTO #PercentVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinated
FROM AlexAnalyst..coviddeaths AS dea
JOIN alexanalyst..covidvaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (peoplevaccinated/population)*100 AS PercentVaccinated FROM #PercentVaccinated


--Creating view to store data for later visualizations
create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS float)) OVER (partition by dea.location order by dea.location, dea.date) AS PeopleVaccinated
FROM AlexAnalyst..coviddeaths AS dea
JOIN alexanalyst..covidvaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

create view ContinentTotalDeaths as
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM   CovidDeaths
WHERE (continent IS NOT NULL)
GROUP BY continent
--order by totaldeathcount desc

create view CountryInfectionRate as
SELECT location, population, MAX(total_cases) AS HighestCaseCount, MAX(total_cases / population) * 100 AS CovidPercentage
FROM   CovidDeaths
GROUP BY location, population
--order by CovidPercentage desc

create view ChanceOfDeath as
SELECT location, date, total_cases, total_deaths, total_deaths / total_cases * 100 AS DeathPercentage
FROM   CovidDeaths