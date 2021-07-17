SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3,4

--SELECT DATA THAT WE ARE GOING TO BE USING

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population was diagnosed with Covid

SELECT Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

--Showing continents with highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc




-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac



--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into  #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated