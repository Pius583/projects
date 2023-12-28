/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types.

*/

Select *
From PortfolioProject..[covid-deaths]
Where continent is not Null
Order by 3,4



--Select Data that we are going to be using

Select continent,Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..[covid-deaths]
Where continent is not Null
order by 2,3

-- Total Cases vs Total Deaths in Ghana
-- Shows likelihood of dying if you contract covid in Ghana

Select continent, Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..[covid-deaths]
Where location like '%ghana%'
order by 1,2

-- Total Cases vs Population in Ghana
-- Shows what percentage of population infected with covid in Ghana

Select continent, Location, date, total_cases, population,(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..[covid-deaths]
Where location = 'Ghana'
order by 1,2

-- Looking at countries with Highest Infection Rate compared to Population

Select continent, Location, population, date, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..[covid-deaths]
Where continent is not Null
Group by continent, Location, population, date
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

Select continent,location, population, Max(Cast (total_deaths as bigint)) as HighestDeathCount, 
Max(cast (total_deaths as bigint)/population)*100 as PercentDeathPopulation
From PortfolioProject..[covid-deaths]
Where continent is not Null
Group by continent,location,population
order by PercentDeathPopulation desc


-- Countries with highest Death Count

Select continent, Location, Max(Cast (total_deaths as bigint)) as HighestDeathCount
From PortfolioProject..[covid-deaths]
Where continent is not Null
Group by continent, Location
order by HighestDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT
-- Showing the continents with the highest death count

Select continent, Max(Cast (total_deaths as bigint)) as HighestDeathCount
From PortfolioProject..[covid-deaths]
Where continent is not Null
Group by continent
order by HighestDeathCount desc

-- Showing Total Deathcount by Continents

Select continent, Sum(Cast (new_deaths as bigint)) as TotalDeathCount
From PortfolioProject..[covid-deaths]
Where continent is not Null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
-- Showing Worldwide Total Cases, Total Deaths, and Total Death Percentage grouped by date

Select date, Sum(new_cases) as total_cases, Sum(Cast(new_deaths as bigint)) as total_deaths, 
Sum(Cast(new_deaths as bigint))/Sum(new_cases) *100 as DeathPercentage
From PortfolioProject..[covid-deaths]
Where continent is not Null
Group by date
Order by 1,2

-- Showing Worldwide Total Cases, Total Deaths, and Total Death Percentage

Select Sum(new_cases) as total_cases, Sum(Cast(new_deaths as bigint)) as total_deaths, 
Sum(Cast(new_deaths as bigint))/Sum(new_cases) *100 as DeathPercentage
From PortfolioProject..[covid-deaths]
Where continent is not Null
Order by 1,2

-- Total Population vs Vaccination
-- Shows Percentage of population that have recieved at least one Covid Vaccine

Select D.continent, D.location, D.date, D.population, V.new_vaccinations,
	Sum(Convert(int, V.new_vaccinations)) OVER (Partition by D.location order by D.location,
	D.date) as RollingPopulationVaccinated
	--,(RollingPopulationVaccinated/population) * 100
From PortfolioProject..[covid-deaths] as D
join PortfolioProject..[covid-vaccinations] as V
	on D.location = V.location
	and D.date = V.date
Where D.continent is not Null
Order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (continent, location, date, population, new_vaccination, RollingPopulationVaccinated)
as
(Select D.continent, D.location, D.date, D.population, V.new_vaccinations,
	Sum(Convert(int, V.new_vaccinations)) OVER (Partition by D.location order by D.location,
	D.date) as RollingPopulationVaccinated
	--,(RollingPopulationVaccinated/population) * 100
From PortfolioProject..[covid-deaths] as D
join PortfolioProject..[covid-vaccinations] as V
	on D.location = V.location
	and D.date = V.date
Where D.continent is not Null
--Order by 2,3
)
Select *, (RollingPopulationVaccinated/population)*100 as PercentageRollingPopulationVaccinated
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

Drop Table if exists #PercentagePopulatioinVaccinated
Create Table #PercentagePopulatioinVaccinated
(
Continent varchar(250),
Location varchar(250),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPopulationVaccinated numeric
)

Insert into #PercentagePopulatioinVaccinated
Select D.continent, D.location, D.date, D.population, V.new_vaccinations,
	Sum(Convert(int, V.new_vaccinations)) OVER (Partition by D.location order by D.location,
	D.date) as RollingPopulationVaccinated
	--,(RollingPopulationVaccinated/population) * 100
From PortfolioProject..[covid-deaths] as D
join PortfolioProject..[covid-vaccinations] as V
	on D.location = V.location
	and D.date = V.date
Where D.continent is not Null
--Order by 2,3
Select *, (RollingPopulationVaccinated/population)*100 as PercentageRollingPopulationVaccinated
From #PercentagePopulatioinVaccinated

-- Creating Views to store data for later visualizations

Create View PercentagePopulatioinVaccinated as
Select D.continent, D.location, D.date, D.population, V.new_vaccinations,
	Sum(Convert(int, V.new_vaccinations)) OVER (Partition by D.location order by D.location,
	D.date) as RollingPopulationVaccinated
	--,(RollingPopulationVaccinated/population) * 100
From PortfolioProject..[covid-deaths] as D
join PortfolioProject..[covid-vaccinations] as V
	on D.location = V.location
	and D.date = V.date
Where D.continent is not Null


Create View HighestInfectionRateCountries as
Select continent, Location, population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..[covid-deaths]
Where continent is not Null
Group by continent, Location, population


Create View HighestDeathCountCountries as
Select continent, Location, Max(Cast (total_deaths as bigint)) as HighestDeathCount
From PortfolioProject..[covid-deaths]
Where continent is not Null
Group by continent, Location

Create View HighestDeathCountContinents as
Select continent, Max(Cast (total_deaths as bigint)) as HighestDeathCount
From PortfolioProject..[covid-deaths]
Where continent is not Null
Group by continent