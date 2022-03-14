Select *
From Project..CovidDeaths
Where continent is  null 
order by 3,4



-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From Project..CovidDeaths 
order by 1,2

--Looking at Total cases vs Total deaths 

Select Location, date, total_cases,total_deaths, (total_deaths / total_cases)*100 as DeathPercenatge
From Project..CovidDeaths 
where continent is not null
--where location = 'India'
order by 1,2

--Looking at Total cases vs Population 
--shows what percectage of population got covid 

Select Location, date,population, total_cases ,(total_cases / population)*100 as PercentPopulationInfected
From Project..CovidDeaths 
where location = 'India'
order by 1,2

--Countries with highest infection rate compared to population 

Select Location , population, max(total_cases) as HighestInfectedCount ,max((total_cases / population))*100 as PercentPopulationInfected
From Project..CovidDeaths 
where continent is not null
--where location = 'India'
Group By Location , population
order by PercentPopulationInfected desc

--Showing Continent with highest death count 

Select continent , max(cast(total_deaths as int)) as TotalDeathCount 
From Project..CovidDeaths 
-- where location = 'India'
where continent is not null
Group By continent 
order by TotalDeathCount desc


--Showing Continent with highest death count per population 

Select continent ,population, max(cast(total_deaths as int)) as TotalDeathCount 
From Project..CovidDeaths 
-- where location = 'India'
where continent is not null
Group By continent ,population
order by TotalDeathCount desc

--Global numbers 

Select  sum(new_cases) as TotalCases, Sum(cast(new_deaths as int )) as TotalDeaths, sum(cast(new_deaths as int ))/ Sum(new_cases) *100 as DeathPercentage
From Project..CovidDeaths 
where continent is not null
--where location = 'India'
---Group By date
order by 1,2

--Looking at Total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..CovidDeaths dea
Join Project..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- USE CTE

With PopvsVac (Continent,location, date,population,new_vaccinations,rollingpeoplevaccinated )

as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..CovidDeaths dea
Join Project..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

)
select * ,(RollingPeopleVaccinated/population)*100
from PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

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

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..CovidDeaths dea
Join Project..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--create view to store data for later visualizations

Create view  PercentPopulationVaccinated as 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..CovidDeaths dea
Join Project..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3


Create view  DeathPercenatge as 
Select Location, date, total_cases,total_deaths, (total_deaths / total_cases)*100 as DeathPercenatge
From Project..CovidDeaths 
where continent is not null
--where location = 'India'
--order by 1,2


create view PercentPopulationInfected as 
Select Location, date,population, total_cases ,(total_cases / population)*100 as PercentPopulationInfected
From Project..CovidDeaths 
--where location = 'India'
--order by 1,2

create view TotalDeathCount as 
Select continent , max(cast(total_deaths as int)) as TotalDeathCount 
From Project..CovidDeaths 
-- where location = 'India'
where continent is not null
Group By continent 
--order by TotalDeathCount desc
