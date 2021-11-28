Select *
from PortfolioProject..CovidDeaths
order by 3,4

--Select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- selecting data that we re going to use

select Location,date,total_Cases,new_cases,total_deaths,population 
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths

select Location,date,total_Cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
order by 1,2

-- shows likelihood of dying if you contract covid in US TILL DATE
select Location,date,total_Cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where Location like '%states%'
order by 1,2

-- Looking at WHAT PERCENTAGE Total Cases vs Population in INDIA

select Location,date,total_Cases,population,(total_cases/population)*100 as CasesPercentage
from PortfolioProject..CovidDeaths
where Location like '%india%'
order by 1,2

--Which country has highest infection rate with respect to percentage

select Location,Population,max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

-- Showing countries with Highest Death Count per population

select Location,max(cast(total_deaths as bigint)) as TotalDeathCount
from PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc


-- Let's Break things down by continent
-- Lets show continent with the highest death count

select Continent,max(cast(total_deaths as bigint)) as TotalDeathCount
from PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

select date,sum(new_cases) as total_Cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where continent is not null
Group by date
order by 1,2

select sum(new_cases) as total_Cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- joining two tables

Select * 
From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..Covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..Covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100 #we cannot use this because we have used it as alias,
From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..Covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--CTE
With PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 
From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..Covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select * ,(RollingPeopleVaccinated/population)*100
from PopvsVac

-- Temp Table

Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continenet nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 
From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..Covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select *,(RollingPeopleVaccinated/population)*100 as Percentageofpeople_vaccinated
from #PercentPopulationVaccinated

-- creting View to store data for later visualizations

Create View PercentPopulationVaccinated  as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 
From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..Covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

SELECT * FROM PercentPopulationVaccinated