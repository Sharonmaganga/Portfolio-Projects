Select Location, date, total_cases, new_cases, total_deaths, population
From [portfolio projects]..CovidDeaths
Order by 1,2

--- Looking at Total cases vs Total deaths

Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as deathpercentage
From [portfolio projects]..CovidDeaths
where Location like '%states%'
order by 1,2

--Looking as Total Cases vs Population
--Shows what percentage of population got covid
Select Location, date, total_cases, population,(total_cases/population)*100 as PercentPopulationInfected
From [portfolio projects]..CovidDeaths
where Location like '%states%'
order by 1,2

--Looking as Population with highest infection rates
Select Location, population,MAX(total_cases)as HigestInfectioncount ,MAX(total_cases/population)*100 as PercentPopulationInfected
From [portfolio projects]..CovidDeaths
--where Location like '%states%'
Group by location,Population
order by PercentPopulationInfected


--Showing cointries with highest death count per population
Select Location,MAX(cast (Total_Deaths as int)) as TotalDeathcount
From [portfolio projects]..CovidDeaths
--where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathcount desc

-- LETS BREAK THINGS DOWN BY CONTINENT
Select continent,MAX(cast (Total_Deaths as int)) as TotalDeathcount
From [portfolio projects]..CovidDeaths
--where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathcount desc

--GLOBAL NUMBERS

Select  SUM(new_cases) as total_cases  ,SUM(cast(new_deaths as int)) as total_deaths ,SUM(cast(new_deaths as int))/SUM(cast(new_cases as int))as DeathPercentages
From [portfolio projects]..CovidDeaths
where continent is not null
--Group by Date
order by 1,2

-- Looking at Total Population vs Vacconations

Select *
From [portfolio projects]..CovidDeaths dea
join [portfolio projects]..CovidVaccines vac
  on dea.location = vac.location
  and dea.date = vac.date

  Select *
From [portfolio projects]..CovidDeaths dea
join [portfolio projects]..CovidVaccines vac
  on dea.location = vac.location
  and dea.date = vac.date

select *
from [portfolio projects]..CovidVaccines

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(cast(vac.new_vaccinations as int)) OVER(Partition by dea.location Order by dea.location,dea.date) as RolligPeopleVaccination
From [portfolio projects]..CovidDeaths dea 
join [portfolio projects]..CovidVaccines vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


-- USE CTE

With PopvsVac(Continent,Location,Date,Population,new_vaccinations,RollingPeopleVaccination)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(cast(vac.new_vaccinations as int)) OVER(Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccination
From [portfolio projects]..CovidDeaths dea 
join [portfolio projects]..CovidVaccines vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccination/Population)*100
From PopvsVac

Drop Table if exists  #PercentPopulationVaccinated
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
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(cast(vac.new_vaccinations as int)) OVER(Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccination
From [portfolio projects]..CovidDeaths dea 
join [portfolio projects]..CovidVaccines vac
  on dea.location = vac.location
  and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [portfolio projects]..CovidDeaths dea
Join [portfolio projects]..CovidVaccines vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
