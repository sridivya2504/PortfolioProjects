select *
from PortolioProject.dbo.CovidDeaths
where continent is not NULL
order by 3,4
 

--select *
--from PortolioProject.dbo.CovidVaccinations
--order by 3,4


--Select the data that we are going to be using

select location,date,total_cases,new_cases,total_deaths,population
from PortolioProject.dbo.CovidDeaths
where continent is not NULL
order by 1,2

--looking at total cases vs total deaths
-- Shows the likelyhood of death when infected by covid according the date and location

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortolioProject.dbo.CovidDeaths
where location like '%States%'
and continent is not NULL
order by 1,2

--Looking at total cases vs the population
-- shows what percentage of people are gettig infected by covid ou of the total population

select location,date,total_cases,population,(total_cases/population)*100 as PercentpopulationInfected
from PortolioProject.dbo.CovidDeaths
--where location like '%States%'
where continent is not NULL
order by 1,2

--Looking at country with the highest infection Rate compared to population
select location,MAX(total_cases) as HighestInfectionCount,population,MAX((total_cases/population))*100 as PercentpopulationInfected
from PortolioProject.dbo.CovidDeaths
--where location like '%States%'
where continent is not NULL
Group by location,population
order by PercentpopulationInfected desc

-- Showing countries with highest death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortolioProject.dbo.CovidDeaths
--where location like '%States%'
where continent is not NULL
Group by location
order by TotalDeathCount desc

--Let's break these things under continents

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortolioProject.dbo.CovidDeaths
--where location like '%States%'
where continent is not NULL
Group by continent
order by TotalDeathCount desc 


--Showing continents with highest death count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortolioProject.dbo.CovidDeaths
--where location like '%States%'
where continent is not NULL
Group by continent
order by TotalDeathCount desc

--Global numbers
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortolioProject.dbo.CovidDeaths
--where location like '%States%'
where continent is not NULL
--Group by date
order by 1,2


-- vaccination Db use
--Looking at total population vs vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by  dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated , (RollingPeopleVaccinated/population)*100
from PortolioProject.dbo.CovidDeaths dea
Join PortolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
order by 2,3
-- Using CTE
With PopvsVac (Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by  dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
from PortolioProject.dbo.CovidDeaths dea
Join PortolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

--Using Temp Table

Drop Table if exists #PercentPopulationVacinated
Create Table #PercentPopulationVacinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVacinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by  dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
from PortolioProject.dbo.CovidDeaths dea
Join PortolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
--order by 2,3
Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVacinated


--- Creating view to store data for later visualizations

--Create view PercentPopulationVacinated as
--select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by  dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
--from PortolioProject.dbo.CovidDeaths dea
--Join PortolioProject.dbo.CovidVaccinations vac
	--on dea.location = vac.location
	--and dea.date = vac.date
--where dea.continent is not NULL
--order by 2,3
--Drop view [PercentPopulationVacinated]

Create view PerceVacinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by  dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
from PortolioProject.dbo.CovidDeaths dea
Join PortolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
--order by 2,3

Select *
From PerceVacinated