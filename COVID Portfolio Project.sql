Select * From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select * From PortfolioProject..CovidVaccinations
--order by 3,4


--Select Data that we are going to be using
Select location, Date, total_cases, new_cases, total_deaths, population
from PortfolioProject.. CovidDeaths
order by 1,2

--Total cases Vs Total Deaths in United States:
Select location, Date, total_cases, total_deaths, Round((total_deaths/total_cases)*100,2) as DeathPercentage
from PortfolioProject.. CovidDeaths
Where location like '%states%'
order by 1,2

--Total Cases VS Population:
Select location, Date, total_cases, Population, Round((total_cases/Population)*100,2) as PercentPopulationInfected
from PortfolioProject.. CovidDeaths
order by 1,2

--Countries with highest Infection rate compared to population:
Select location, Population, MAX(total_cases) AS HighestInfectionCount, Round((Max(total_cases/Population))*100,2) as PercentPopulationInfected
from PortfolioProject.. CovidDeaths
Group By Location, Population
order by PercentPopulationInfected desc

--Countries with Highest Death Count per Population:
Select location, MAX(Cast(total_deaths as int)) AS TotalDeathCount
from PortfolioProject.. CovidDeaths
Where continent is not null
Group By Location
order by TotalDeathCount desc

--Continent with Highest Death Count per Population:
Select Continent, MAX(Cast(total_deaths as int)) AS TotalDeathCount
from PortfolioProject.. CovidDeaths
Where continent is not null
Group By Continent
order by TotalDeathCount desc

--Global Numbers:
Select  Date, Sum(new_cases) as TotalCases, Sum(cast(new_deaths as int)) as TotalDeaths, Round(Sum(cast(new_deaths as int))/ Sum(New_cases)*100,2) as DeathPercentage
from PortfolioProject.. CovidDeaths
where continent is not null
Group by date
order by 1,2

--Total cases:
Select  Sum(new_cases) as TotalCases, Sum(cast(new_deaths as int)) as TotalDeaths, Round(Sum(cast(new_deaths as int))/ Sum(New_cases)*100,2) as DeathPercentage
from PortfolioProject.. CovidDeaths
where continent is not null
order by 1,2


--Combining 2 tables
Select * From PortfolioProject..CovidDeaths dea
Join PortfolioProject.. CovidVaccinations vac
	On dea.location = vac.location
	and dea.date =  vac.date


-- Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.Location order by dea.Location, dea.date) as RollingPeopleVaccinated
 From PortfolioProject..CovidDeaths dea
Join PortfolioProject.. CovidVaccinations vac
	On dea.location = vac.location
	and dea.date =  vac.date
Where dea.continent is not null
order by 2,3


--Use CTE
With PopulationVsVaccination (Continen, Location, date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.Location order by dea.Location, dea.date) as RollingPeopleVaccinated
 From PortfolioProject..CovidDeaths dea
Join PortfolioProject.. CovidVaccinations vac
	On dea.location = vac.location
	and dea.date =  vac.date
Where dea.continent is not null
)
Select *,(Round(RollingPeopleVaccinated/Population,2)) as RollingPercentageVaccinated from PopulationVsVaccination



--Temp Table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.Location order by dea.Location, dea.date) as RollingPeopleVaccinated
 From PortfolioProject..CovidDeaths dea
Join PortfolioProject.. CovidVaccinations vac
	On dea.location = vac.location
	and dea.date =  vac.date


Select *,(Round(RollingPeopleVaccinated/Population,2)) as RollingPercentageVaccinated from #PercentPopulationVaccinated




--Creating to view to store data for future Visualizations
--Drop view if exists PercentPopulationVaccinated
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.Location order by dea.Location, dea.date) as RollingPeopleVaccinated
 From PortfolioProject..CovidDeaths dea
Join PortfolioProject.. CovidVaccinations vac
	On dea.location = vac.location
	and dea.date =  vac.date
Where dea.continent is not null


