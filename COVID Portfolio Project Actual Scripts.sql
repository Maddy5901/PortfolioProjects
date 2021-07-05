Select *
From PortfolioProject..CovidDeaths
Where continent Is Not Null
Order By 3,4

-- Select *
-- From PortfolioProject..CovidVaccinations
-- Order By 3,4

-- Select Data that we are going to be using 

Select location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths
Order By 1,2


-- Looking at Total Cases Vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS "Death Percentage"
From PortfolioProject..CovidDeaths
Where location like '%India%'
Order By 1,2


-- Looking at Total Cases Vs Population
-- Shows what percentage of population contracted covid

Select location,date,total_cases,(total_cases/population)*100 AS "TestPos_Percentage"
From PortfolioProject..CovidDeaths
-- Where location like '%India%'
Order By 1,2

-- Countries with the highest infection rate compared to population

Select location, population, MAX(total_cases) AS Highest_Infection_Rate, MAX((total_cases/population))*100 AS Highest_TestPos_Percentage
From PortfolioProject..CovidDeaths
-- Where location like '%India%'
Group By location, population
Order By Highest_TestPos_Percentage DESC


-- Showing countries with the highest death count per population

Select location, MAX(Cast(total_deaths As int)) As Total_Death_Count
From PortfolioProject..CovidDeaths
-- Where location like '%India%'
Where continent Is Not Null
Group By location
Order By Total_Death_Count DESC

-- Breaking things down by continent

-- Select continent, MAX(Cast(total_deaths As int)) As Total_Death_Count
-- From PortfolioProject..CovidDeaths
-- Where continent Is Not Null
-- Group By continent
-- Order By Total_Death_Count Desc

Select continent, MAX(Cast(total_deaths As int)) As Total_Death_Count
From PortfolioProject..CovidDeaths
-- Where location like '%India%'
Where continent Is Not Null
Group By continent
Order By Total_Death_Count Desc

-- Select location, MAX(Cast(total_deaths As int)) As Total_Death_Count
-- From PortfolioProject..CovidDeaths
-- Where continent Is Null
-- Group By location
-- Order By Total_Death_Count Desc


-- Showing the continents with the highest death count per population

Select continent, MAX(Cast(total_deaths As int)) As Total_Death_Count
From PortfolioProject..CovidDeaths
-- Where location like '%India%'
Where continent Is Not Null
Group By continent
Order By Total_Death_Count Desc


-- Global Numbers

Select date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS int)) AS Total_New_Deaths,
 SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%India%'
Where continent Is Not Null
Group By date
Order By 1,2

-- Death Percentage across the world

Select SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS int)) AS Total_New_Deaths,
 SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
-- Where location like '%India%'
Where continent Is Not Null
-- Group By date
Order By 1,2

-- Looking at Total Population Vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition By dea.location Order By dea.location, dea.date) AS Rolling_People_Vaccinated
 -- OR CONVERT(int,vac.new_vaccinations)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   On dea.location=vac.location
   and dea.date=vac.date
Where dea.continent Is Not Null
Order By 2,3

-- USE CTE

With PopvsVac (continent, location, date, population,new_vaccinations, Rolling_People_Vaccinated)
As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition By dea.location Order By dea.location, dea.date) AS Rolling_People_Vaccinated
 -- OR CONVERT(int,vac.new_vaccinations)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   On dea.location=vac.location
   and dea.date=vac.date
Where dea.continent Is Not Null
-- Order By 2,3
)

Select *, (Rolling_People_Vaccinated/population)*100 AS Rolling_People_Vaccinated_Percent
From PopvsVac


-- Temp Table
DROP Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
Rolling_People_Vaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition By dea.location Order By dea.location, dea.date) AS Rolling_People_Vaccinated
 -- OR CONVERT(int,vac.new_vaccinations)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   On dea.location=vac.location
   and dea.date=vac.date
   Where dea.continent Is Not Null
-- Order By 2,3

Select *, (Rolling_People_Vaccinated/population)*100 AS Rolling_People_Vaccinated_Percent
From #PercentPopulationVaccinated


-- Creating View to store data for later visualization

Create View PercentPopulationInfected As
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition By dea.location Order By dea.location, dea.date) AS Rolling_People_Vaccinated
 -- OR CONVERT(int,vac.new_vaccinations)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   On dea.location=vac.location
   and dea.date=vac.date
Where dea.continent Is Not Null
--Order By 2,3

