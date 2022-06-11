
SELECT *
FROM DataProjectCovid..CovidDeath
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM DataProjectCovid..CovidVacc
--ORDER BY 3,4

SELECT location, date, total_cases_per_million, new_cases, total_deaths, population
FROM DataProjectCovid..CovidDeath
ORDER BY 1,2

SELECT total_cases_per_million
	.FORMAT (total_cases_per_million , 'G','en-us') AS 'General Format'


--Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases_per_million, total_deaths, (total_deaths/total_cases_per_million)*100 as DeathPercentage
FROM DataProjectCovid..CovidDeath
Where location like '%states%'
and continent is not null
ORDER BY 1,2
      

-- Looking at Total Cases vs Population

SELECT location, date, population, total_cases_per_million, (total_cases_per_million/population)*100 as DeathPercentage
FROM DataProjectCovid..CovidDeath
Where location like '%states%'
ORDER BY 1,2

--Looking at countries with highest infest rate compare to population

SELECT continent, population, MAX(total_cases_per_million) AS HighestInfectionCount, Max((total_cases_per_million/population))*100 as PercentPopulationInfected
FROM DataProjectCovid..CovidDeath
--Where location like '%states%'
GROUP BY continent, population
ORDER BY PercentPopulationInfected desc

--Countries with Highest Death Count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM DataProjectCovid..CovidDeath
--Where location like '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--Continents with highest death count

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM DataProjectCovid..CovidDeath
--Where location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--Global numbers

SELECT date,SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM DataProjectCovid..CovidDeath
--Where location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


SELECT SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM DataProjectCovid..CovidDeath
--Where location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--JOIN COMMAND

SELECT *
FROM DataProjectCovid..CovidDeath dea
JOIN DataProjectCovid..CovidVacc vac
	ON dea.location = vac.location
	and dea.date = vac.date

--Total Population vs Vacc 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
--SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location)
FROM DataProjectCovid..CovidDeath dea
JOIN DataProjectCovid..CovidVacc vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.location = 'Canada'
AND dea.continent is not null
ORDER  BY  2, 3

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int,vac.new_vaccinations))
OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
FROM DataProjectCovid..CovidDeath dea
JOIN DataProjectCovid..CovidVacc vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER  BY  2, 3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations as bigint))
OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM DataProjectCovid..CovidDeath dea
JOIN DataProjectCovid..CovidVacc vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER  BY  2, 3
)
Select * , (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
Create table  #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated  numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations as int))
OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM DataProjectCovid..CovidDeath dea
JOIN DataProjectCovid..CovidVacc vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER  BY  2, 3

Select * , (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to store data for visualizations

Create view PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations as int))
OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM DataProjectCovid..CovidDeath dea
JOIN DataProjectCovid..CovidVacc vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER  BY  2, 3


Select *
From PercentPopulationVaccinated