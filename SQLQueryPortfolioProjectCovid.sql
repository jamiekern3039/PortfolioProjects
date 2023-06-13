
--Data Exploration

Select * 
From PortfolioProjectCovid..CovidDeaths
Where continent is not null
ORDER by 3, 4

Select *
From INFORMATION_SCHEMA.COLUMNS
Where TABLE_CATALOG = 'PortfolioProjectCovid'
And COLUMN_NAME Like '%Age%'

Select dea.continent, dea.location, vac.median_age, vac.aged_65_older
From PortfolioProjectCovid..CovidDeaths dea
Full Outer Join PortfolioProjectCovid..CovidVaccinations vac
On vac.median_age = dea.median_age
Where dea.continent is not null
Group by dea.continent, dea.location, vac.median_age, vac.aged_65_older
order by 2,3

Select location, median_age, aged_65_older
From PortfolioProjectCovid..CovidVaccinations
Where continent is not null
Group by location, median_age, aged_65_older
order by location desc

Select location, median_age, aged_65_older
From PortfolioProjectCovid..CovidVaccinations
Where median_age is  null and aged_65_older is null
and continent is not null
Group by location, median_age, aged_65_older
order by location desc


--Looking at death rate percentage in the U.S

Select location, date, total_cases, total_deaths, (try_convert(decimal, [total_deaths])/ try_convert(decimal, [total_cases]))*100 
as DeathPercentage
From PortfolioProjectCovid..CovidDeaths
Where location like '%states%'
ORDER by 1, 2


--Looking at total cases vs population

Select location, date,population, total_cases, (try_convert(decimal, [total_cases])/ try_convert(decimal, [population]))*100 
as InfectedPercentage
From PortfolioProjectCovid..CovidDeaths
ORDER by 1, 2


--Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectedCount, MAX((total_cases/population))*100
as InfectedPercentage
From PortfolioProjectCovid..CovidDeaths
Group by location, population
ORDER by InfectedPercentage desc


--Looking at countries with highest infection rate compared to population with date data

Select location, population, date, MAX(total_cases) as HighestInfectedCount, MAX((total_cases/population))*100
as InfectedPercentage
From PortfolioProjectCovid..CovidDeaths
Group by location, population, date
ORDER by InfectedPercentage desc


--Showing countries with the recent death count per population

Select location, MAX(cast(total_deaths as int)) as CountryDeathCount
From PortfolioProjectCovid..CovidDeaths
Where continent is not null 
Group by location
ORDER by CountryDeathCount desc 

--Query to show the total recent death count for each continent

Select location, SUM(new_deaths) as TotalDeathCount
From PortfolioProjectCovid..CovidDeaths
Where continent is null and location not in ('World', 'European Union', 'International')
and location <> 'High income' and location <> 'Upper middle income' 
and location <> 'Lower middle income' and location <> 'Low income' and location <> 'World'
Group by location
Order by TotalDeathCount desc


--Highest death count by continent

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjectCovid..CovidDeaths
Where continent is null and location <> 'High income' and location <> 'Upper middle income' 
and location <> 'Lower middle income' and location <> 'Low income' and location <> 'World'
Group by location
ORDER by TotalDeathCount desc


--Global Numbers

Select SUM(new_cases) as total_cases, 
SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From PortfolioProjectCovid..CovidDeaths
where continent is not null
order by 1, 2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100
From PortfolioProjectCovid..CovidDeaths dea
Join PortfolioProjectCovid..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
  Where dea.continent is not null
  order by 2,3


  --Using a CTE

  With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) as
(
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProjectCovid..CovidDeaths dea
Join PortfolioProjectCovid..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
  Where dea.continent is not null
  )
  Select *, (RollingPeopleVaccinated/Population)*100
  From PopVsVac

  
  -- Creating a Temp Table

  Drop Table if exists #PercentagePopulationvaccinated
  Create Table #PercentagePopulationvaccinated
  (
  Continent nvarchar(255),
  Location nvarchar(255),
  Date datetime,
  Population numeric,
  New_Vaccinations numeric,
  RollingPeopleVaccinated numeric
  )

  Insert into #PercentagePopulationvaccinated

  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProjectCovid..CovidDeaths dea
Join PortfolioProjectCovid..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
  Where dea.continent is not null

  Select *, (RollingPeopleVaccinated/Population)*100
  From #PercentagePopulationvaccinated


--Creating view to store data for later visualizations

Create view PercentagePopulationvaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProjectCovid..CovidDeaths dea
Join PortfolioProjectCovid..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
  Where dea.continent is not null