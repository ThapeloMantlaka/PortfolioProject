SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE location = 'South Africa' 
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, CAST(Total_deaths AS Decimal)/CAST(total_cases AS decimal)*100 AS DeathPercentage
FROM CovidDeaths
WHERE Location = 'South Africa'
ORDER BY 1,2

--Looking at Total Cases vs Population
SELECT location, date, total_cases,population ,CAST(Total_cases AS Decimal)/CAST(Population AS decimal)*100 AS PercentofPopulationInfected
FROM CovidDeaths
WHERE Location = 'South Africa'
ORDER BY 1,2


--Looking at Countries with highest infection rate compared to population 

SELECT location,population, MAX(total_cases) as HighestInfectionCount, MAX(CAST(Total_cases AS Decimal)/CAST(Population AS decimal))*100 as PercentPopulationInfected
FROM CovidDeaths
GROUP BY location , population
ORDER BY PercentPopulationInfected desc


--Showing Countries with Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths AS DECIMAL)) As totalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY location 
ORDER BY totalDeathCount desc

--Showing Total Deaths per Continent
SELECT continent, MAX(CAST(total_deaths AS DECIMAL)) As totalDeathCount
FROM CovidDeaths
WHERE continent is not null 
GROUP BY continent
ORDER BY totalDeathCount desc

--GLOBAL NUMBERS
SELECT 
    --date, 
    SUM(CAST(new_cases AS decimal)) AS TotalNewCases, 
    SUM(CAST(new_deaths AS decimal)) AS TotalNewDeaths, 
    SUM(CAST(new_cases AS decimal)) / NULLIF(SUM(CAST(new_deaths AS decimal)), 0) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as decimal)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Using CTE

With PopvsVac (Continent , Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as decimal)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *,(RollingPeopleVaccinated /  Population) *100 AS PercentagePopulationVaccinated
FROM PopvsVac

--Using Temp table
DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as decimal)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null
 
 SELECT *
 FROM #PercentagePopulationVaccinated

--Creating View to store data for later visiuals


CREATE VIEW PercentagePopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as decimal)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null


  