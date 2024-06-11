/* select * from Covid_Deaths */

/* select the data that we are going to be using */

select location, date, total_cases, new_cases, total_deaths, population
from Portfolio_Project.dbo.Covid_Deaths
order by 1,2


/* Looking at Total Cases Vs. Total Deaths, likelihood of dying if you contract covid in your country */

Select location, date, total_cases,total_deaths, (cast (total_deaths as float)/ (total_cases as float))*100 as Death_Percentage
From Portfolio_Project..Covid_Deaths
Where location like '%ndia'
order by 1,2




/* Looking at total cases Vs. Population, shows what percentage of population got covid */

select location, date, population, total_cases, (total_cases/population)*100 AS Percentage_of_Infection
from Covid_Deaths
where location like '%ndia'
order by 1,2

/* Looking at countries with highest infection rate compared to population */
select location, population, MAX(total_cases) AS MAX_CASES, MAX((total_cases/population))*100 AS Percentage_Of_Infection
from Covid_Deaths
group by location, population
order by Percentage_Of_Infection desc


/* showing countries with highest death count per population */
select location, MAX(cast(total_deaths as int)) as total_deaths_per_population
from Covid_Deaths
where continent is not null
group by location
order by total_deaths_per_population desc


/* breaking down things by continent OR showing continents with highest death count per population */
select continent, MAX(cast(total_deaths as int)) as total_deaths_per_population
from Covid_Deaths
group by continent
order by total_deaths_per_population desc

/* Global Numbers */
select * from Covid_Deaths

select date, sum(new_cases) as total_new_cases, sum(cast(new_deaths as int)) as total_new_deaths
-- sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from Covid_Deaths
where continent is not null
group by date
order by 1,2


select sum(new_cases) as total_new_cases, sum(cast(new_deaths as int)) as total_new_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from Covid_Deaths
where continent is not null
order by 1,2

/* Looking at Total Population Vs. Vaccinations */
-- 1) using CTE and 
-- 2) using Temp tables

-- select * from Covid_Vaccinations

select dea.continent, dea.location, dea.date, vac.new_vaccinations
from Covid_Deaths as dea Join Covid_Vaccinations as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Vaccination_count
from Covid_Deaths as dea Join Covid_Vaccinations as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- 1) using CTE

with PopVsVac (continent, location, date, population, new_vaccinations, Vaccinations_count)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Vaccinations_count
--, (Vaccinations_count/population)*100
from Covid_Deaths as dea Join Covid_Vaccinations as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
select *, (Vaccinations_count/population)*100 as Vaccinated_Population_Percentage from PopVsVac

-- 2) using Temp tables 

create table #Percentage_of_Population_Vaccinated
(continent nvarchar(255), location nvarchar(255), date datetime, 
 population numeric, new_vaccinations numeric, Vaccinations_count numeric,)
 
 Insert into #Percentage_of_Population_Vaccinated
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Vaccinations_count
--, (Vaccinations_count/population)*100
from Covid_Deaths as dea Join Covid_Vaccinations as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

select *, (Vaccinations_count/population)*100 as Vaccinated_Population_Percentage from #Percentage_of_Population_Vaccinated

/* creating view for storing data for visualizations in tableau */

create view Percentage_of_Population_Vaccinated as
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Vaccinations_count
--, (Vaccinations_count/population)*100
from Covid_Deaths as dea Join Covid_Vaccinations as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

select * from Percentage_of_Population_Vaccinated --View created and its usage 