#COVID 19 Data Exploration

#Skills used: Joins, Aggregate Function, Creating Views, Converting Data Types, Window Function, CTE

/*SELECT * FROM PortfolioProject.coviddeaths ORDER BY 3,4
SELECT * FROM PortfolioProject.covidvax ORDER BY 3,4*/


/* Select data that we are going to be starting with */

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.coviddeaths;


/* Looking at Total Cases vs Total Deaths 
Shows likelihood of dying if you contract Covid in your country*/

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.coviddeaths
WHERE location like '%states%';


/* Total Cases vs Population 
Shows what percentage of population infected with Covid*/

SELECT location, date, Population, total_cases, (total_cases/Population)*100 as CasePercentage 
FROM PortfolioProject.coviddeaths
WHERE location like '%states%';


/* Countries with highest infection rate compared to population*/

SELECT location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentInfected
FROM PortfolioProject.coviddeaths
/* WHERE location like '%states%'*/
GROUP BY location, Population
ORDER BY PercentInfected desc;


/* Countries with highest death count per population*/

SELECT location, MAX(CAST(total_deaths AS SIGNED)) as TotalDeathCount
FROM PortfolioProject.coviddeaths
/* WHERE location like '%states%'*/
WHERE continent != ''
GROUP BY location
ORDER BY TotalDeathCount desc;


/* Let's break things down by continent
Showing continents with the highest death count per population
CONVERT(SIGNED, total_deaths)*/

SELECT location, MAX(CAST(total_deaths AS SIGNED)) as TotalDeathCount
FROM PortfolioProject.coviddeaths
/* WHERE location like '%states%'*/
WHERE continent = ''
GROUP BY location
ORDER BY TotalDeathCount desc;


/* Global numbers*/

SELECT date, SUM(new_cases) as totalcases, SUM(cast(new_deaths AS SIGNED)) as totaldeaths, SUM(cast(new_deaths as SIGNED))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.coviddeaths
WHERE continent != ''
GROUP BY date;

SELECT SUM(new_cases) as totalcases, SUM(cast(new_deaths AS SIGNED)) as totaldeaths, SUM(cast(new_deaths as SIGNED))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.coviddeaths
WHERE continent != '';


/* Join*/

SELECT * 
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvax vax
	ON dea.location = vax.location
    AND dea.date = vax.date; 
    
    
# Total Population vs Vaccinations
# Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations 
, SUM(vax.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVax
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvax vax
	ON dea.location = vax.location
    AND dea.date = vax.date
WHERE dea.continent != '';


# Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinate AS
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations 
, SUM(vax.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVax
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvax vax
	ON dea.location = vax.location
    AND dea.date = vax.date
WHERE dea.continent != '';


#Window Function showing the rolling people vaccinated 

Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(CAST(vax.new_vaccinations AS UNSIGNED)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
#--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.coviddeaths dea
Join PortfolioProject.covidvax vax
	On dea.location = vax.location
	and dea.date = vax.date;
    

#CTE to perform calculation on Partition By
WITH PopvsVax AS(
	SELECT dea.location, dea.date, dea.population, vax.new_vaccinations, SUM(vax.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
    From PortfolioProject.coviddeaths dea
	Join PortfolioProject.covidvax vax
    GROUP BY 1)

SELECT location, (RollingPeopleVaccinated/population)*100
FROM PopvsVax;



# Queries used for Tableau Project
# 1

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as SIGNED)) as total_deaths, SUM(cast(new_deaths as SIGNED))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject.coviddeaths
#Where location like '%states%'
where continent is not null 
#Group By date
order by 1,2; 

# 2
# We take these out as they are not included as countries

Select location, SUM(cast(new_deaths as SIGNED)) as TotalDeathCount
From PortfolioProject.coviddeaths
#Where location like '%states%'
Where location in ('Asia','Africa','Europe','North America','South America','Oceania') 
Group by location
order by TotalDeathCount desc;

SELECT location, SUM(cast(new_deaths as SIGNED)) as TotalDeathCount
From PortfolioProject.coviddeaths
Where continent != ''
Group by location
order by TotalDeathCount desc;

#3

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.coviddeaths
#Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc;

#4

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.coviddeaths
Where continent != ''
#Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc;




