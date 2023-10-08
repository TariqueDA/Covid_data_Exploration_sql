/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT * 
from sql_portfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

-- Select Data that we are going to be starting with

 SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM sql_portfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM sql_portfolioProject..CovidDeaths
WHERE location like '%states%'
and continent is not null
ORDER BY 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT Location, date, total_cases, Population, (total_deaths/population)*100 as PercentPopulationInfected
FROM sql_portfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population

SELECT Location, Population, Max(total_cases) as HighestInfectionCount, MAx((total_cases/population))*100 as PercentPopulationInfected
FROM sql_portfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
Group BY location,Population
ORDER BY PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

SELECT location, Max(cast(Total_deaths as int)) as TotalDeathCount
FROM sql_portfolioProject..CovidDeaths
--WHERE location like '%states%
WHERE continent is null
Group BY location
ORDER BY TotalDeathCount desc


-- Showing Countries with highest death count per population

SELECT population, Max(cast(Total_deaths as int)) as TotalDeathCount
FROM sql_portfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is  null
Group BY population
ORDER BY TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT continent, Max(cast(Total_deaths as int)) as TotalDeathCount
FROM sql_portfolioProject..CovidDeaths
--WHERE location like '%states%
WHERE continent is not null
Group BY continent
ORDER BY TotalDeathCount desc

 

-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM sql_portfolioProject..CovidDeaths
--Where location like '%states'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
	
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, 
dea.Date) as RollingPeopleVaccinated 
from sql_portfolioProject..CovidDeaths dea 
JOIN sql_portfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- Using CTE to perform Calculation on Partition By in previous query

with PopvsVac (Continet, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
 as
 (
 SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, 
dea.Date) as RollingPeopleVaccinated --, (RollingPeopleVaccinated/Population)*100
from sql_portfolioProject..CovidDeaths dea 
JOIN sql_portfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select * , (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query
	
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continet nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert Into #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, 
dea.Date) as RollingPeopleVaccinated --, (RollingPeopleVaccinated/Population)*100
from sql_portfolioProject..CovidDeaths dea 
JOIN sql_portfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

Select * , (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--CREATE Views to store data for later visulizatoons

Create View PercentPopulationvaccinated as 

 SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, 
dea.Date) as RollingPeopleVaccinated --, (RollingPeopleVaccinated/Population)*100
from sql_portfolioProject..CovidDeaths dea 
JOIN sql_portfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

Select *
from PercentPopulationvaccinated
