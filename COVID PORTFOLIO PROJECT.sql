SELECT*
FROM CovidDeaths
Where continent is not null
Order by 3,4

--SELECT*
--FROM CovidVaccinations
--Order by 3,4

--Select data that we are going to be using

SELECT Location, Date, total_cases,new_cases total_deaths, population_density
FROM CovidDeaths
Order by 1,2

--Looking at Total cases vs Total deaths
--Shows likelihood of dying

--SELECT Location, Date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
--FROM CovidDeaths
--Order by 1,2

Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
FROM CovidDeaths
Where location like '%africa%'
Order by 1,2

--Looking at total cases vs population
--Shows what percentage of population got Covid

SELECT Location, population_density,MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population_density))*100 AS PopulationInfected
FROM CovidDeaths
--Where location like '%africa%'
Group by Location, Population_density
Order by PopulationInfected

--Showing countries with highest death count per population
Select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
where continent is not null
Group by location
Order by TotalDeathCount desc

--BY LOCATION
Select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
where continent is null
Group by location
Order by TotalDeathCount desc

--BY CONTINENT
Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
where continent is not null
Group by continent
Order by TotalDeathCount desc


--Global numbers

Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
FROM CovidDeaths
--Where location like '%africa%'
where continent is not null
Order by 1,2

Select date, sum(new_cases), sum(cast(new_deaths as int)) --, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
FROM CovidDeaths
--Where location like '%africa%'
where continent is not null
group by date
Order by 1,2

Select date, sum(new_cases), sum(cast(new_deaths as int)), sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
--Where location like '%africa%'
where continent is  null
group by date
Order by 1,2

--Total population vs vaccinations
select*
from CovidDeaths AS CD
join CovidVaccinations AS CV
on CD.location = CV.location
and CD.date = CV.date

select CD.continent, CD.location, CD.date, CD.population_density, CV.new_vaccinations
from CovidDeaths AS CD
join CovidVaccinations AS CV
on CD.location = CV.location
and CD.date = CV.date
where CD.continent is not null
order by 1,2,3

select CD.continent, CD.location, CD.date, CD.population_density, CV.new_vaccinations,
sum(cast(new_vaccinations as bigint)) OVER (Partition by CD.location)
from CovidDeaths AS CD
join CovidVaccinations AS CV
on CD.location = CV.location
and CD.date = CV.date
where CD.continent is not null
order by 2,3

select CD.continent, CD.location, CD.date, CD.population_density, CV.new_vaccinations,
sum(cast(new_vaccinations as bigint)) OVER (Partition by CD.location order by CD.location,CD. date) as RollingPeopleVaccinated
from CovidDeaths AS CD
join CovidVaccinations AS CV
on CD.location = CV.location
and CD.date = CV.date
where CD.continent is not null
order by 2,3

--USING CTE
With Popvsvac (continent, location, date, population_density,new_vaccinations, RollingPeopleVaccinated)
as
(
select CD.continent, CD.location, CD.date, CD.population_density, CV.new_vaccinations,
sum(cast(new_vaccinations as bigint)) OVER (Partition by CD.location order by CD.location,CD. date) as RollingPeopleVaccinated
from CovidDeaths AS CD
join CovidVaccinations AS CV
on CD.location = CV.location
and CD.date = CV.date
where CD.continent is not null
--order by 2,3
)
select*, (RollingPeopleVaccinated/population_density)*100
from Popvsvac

--TEMP TABLE
DROP table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population_density numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select CD.continent, CD.location, CD.date, CD.population_density, CV.new_vaccinations,
sum(cast(new_vaccinations as bigint)) OVER (Partition by CD.location order by CD.location,CD. date) as RollingPeopleVaccinated
from CovidDeaths AS CD
join CovidVaccinations AS CV
on CD.location = CV.location
and CD.date = CV.date
where CD.continent is not null
--order by 2,3

select*, (RollingPeopleVaccinated/population_density)*100
from #PercentPopulationVaccinated

--Creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select CD.continent, CD.location, CD.date, CD.population_density, CV.new_vaccinations,
sum(cast(new_vaccinations as bigint)) OVER (Partition by CD.location order by CD.location,CD. date) as RollingPeopleVaccinated
from CovidDeaths AS CD
join CovidVaccinations AS CV
on CD.location = CV.location
and CD.date = CV.date
where CD.continent is not null
--order by 2,3

select*
from PercentPopulationVaccinated