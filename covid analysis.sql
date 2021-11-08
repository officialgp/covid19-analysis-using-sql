select *
from portfolioproject..CovidDeath$
where continent is not null
order by 3,4

SELECT*
from portfolioproject..CovidVaccinations$
where continent is not null
order by 3,4

--selecting data to be used for the project


select location,date, total_cases, total_deaths,population
from portfolioproject..CovidDeath$
where continent is not null
order by 1,2

--looking at total cases vs total deaths in nigeria
--shows the likelihood of dying if you contact covid in nigeria
select location,date, total_cases, total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from portfolioproject..CovidDeath$
Where location = 'nigeria'
order by 1,2

--looking at total cases vs population in nigeria
--shows percentage of nigerians that have covid
select location,date, total_cases, population,(total_cases/population)*100 as populationperecentage
from portfolioproject..CovidDeath$
Where location = 'nigeria'
order by 1,2

--looking at countries with highest infection rates
select location, population,max(total_cases) as highestinfectioncount,max((total_cases/population))*100 as percentpopulationinfected
from portfolioproject..CovidDeath$
--Where location like '%states%'
where continent is not null
group by location,population
order by percentpopulationinfected desc

--showing countries with highest death count per population

select location,max(cast(total_deaths as int)) as totaldeathcount
from portfolioproject..CovidDeath$
--Where location like '%states%'
where continent is not null
group by location
order by totaldeathcount desc

---breaking it down by continents


---showing the continents with highest death count per population
select continent,max(cast(total_deaths as int)) as totaldeathcount
from portfolioproject..CovidDeath$
--Where location like '%states%'
where continent is not null
group by continent
order by totaldeathcount desc


--global numbers

select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from portfolioproject..CovidDeath$
--Where location like %states%
where continent is not null
--group by date
order by 1,2

---looking at total population vs vaccinations


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from portfolioproject..CovidDeath$ dea
join portfolioproject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use cte

with popvsvac (continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
as
(

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from portfolioproject..CovidDeath$ dea
join portfolioproject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(rollingpeoplevaccinated/population)*100
from popvsvac


---TEMP TABLE

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from portfolioproject..CovidDeath$ dea
join portfolioproject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *,(rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated


----creating view for future visualization
create  view  percentpopulationvaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from portfolioproject..CovidDeath$ dea
join portfolioproject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select*
from percentpopulationvaccinated