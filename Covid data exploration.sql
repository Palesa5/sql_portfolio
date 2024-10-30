-- This is a data exploration project, wherein I use SQL to explore COVID-19 data to answer various questions in order to find trends and better understand the structure of the data
-- The data was downloaded from https://ourworldindata.org/covid-deaths 
-- Data was first formatted in excel, and then imported into BigQuery as `CovidDeaths` and `CovidVaccinations`

-- Q1: Total cases versus the total deaths?
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM `portfolio-projects-435818.Project_1_of_4.CovidDeaths` 
ORDER BY 1,2
-- The output of this script shows the likelihood of dying if contracted COVID-19 in a particular country on a particular day.


-- Q2: Total cases versus the total deaths in South Africa?
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM `portfolio-projects-435818.Project_1_of_4.CovidDeaths` 
WHERE location = 'South Africa'
ORDER BY date ASC
-- From the data output, it can be seen that the likelihood of dying (in South Africa) if you contracted COVID on 7 March 2023 was 2.53%. 


-- Q3: Total cases versus the population 
SELECT location, date, total_cases, population, (total_cases/population)*100 AS cases_population
FROM `portfolio-projects-435818.Project_1_of_4.CovidDeaths` 
WHERE location = 'South Africa'
ORDER BY date ASC
-- The output of this script shows the percentage of the population of South Africa that had COVID-19 on a particular day


-- Q4: Countries with highest infection rate compared to population
SELECT location, population, max(total_cases) AS highest_cases_per_country,  max((total_cases/population))*100 as percent_population_infected
FROM `portfolio-projects-435818.Project_1_of_4.CovidDeaths` 
Group by location, population
ORDER BY percent_population_infected DESC
-- The output of this script shows that Cyprus had the highest infection rate at 72.62%, which makes some sense, considering the small size of the population


-- Q5: Countries with highest death count per population
SELECT location, max(total_deaths) AS max_death
FROM `portfolio-projects-435818.Project_1_of_4.CovidDeaths` 
GROUP BY location
ORDER BY max_death DESC

-- The output of the script gives "World" as the location with the highest death count. But "World" is not a country. The location with the second highest death count is "High income", which is also not a country. There is clearly different groupings in the data set, whcih aren't countries, but are groupings of countries or groupings of particular people in a particular country. In order to understand this phenomenon further, the data is selected:

SELECT *
FROM `portfolio-projects-435818.Project_1_of_4.CovidDeaths` 
WHERE location = 'World' 
OR location = 'High income'

-- From the output to the above script, it can be seen that where the location is not a country, the continent column is put in as "null". So, in order to get data only for countries, and not groupings of particular countries or people, we can use the "where" function, stating that "where continent is not 'null'"

SELECT location, max(total_deaths) AS max_death
FROM `portfolio-projects-435818.Project_1_of_4.CovidDeaths` 
WHERE continent is not null
GROUP BY location
ORDER BY max_death DESC
-- This script gives the countries only, without a higher grouping and from the results, it can be seen that the country with the most deaths is the United States, with 1 122 599 deaths, and South Africa sits at number 18, with 102 595 deaths

-- Q5: Next, the total_deaths can be broken down by continent, instead of country, beginnign with continent with highest death count
SELECT continent, max(total_deaths) AS max_death
FROM `portfolio-projects-435818.Project_1_of_4.CovidDeaths` 
WHERE continent is not null
GROUP BY continent
ORDER BY max_death DESC

-- The output numbers do not look correct. For North America, the max_death value is 1 122 599, which is the max_deaths for America alone, as noted in question 4. This means that the script simplay took the value of the country with the maximum deaths in each continent, and assigned that value to said continent.
-- To calculate the max_deaths per continent, we can simply use the calculated grouped values in the data set:

SELECT location, max(total_deaths) AS max_death
FROM `portfolio-projects-435818.Project_1_of_4.CovidDeaths` 
WHERE continent is null
GROUP BY location
ORDER BY max_death DESC
-- This total shows not only the continent with highest death count, but also gives income status and the world total max_death value. The continent with the highest death count is Europe at 2 035 490.

-- Q6: Total number of new cases in the world each day (in order to calculate the total for each day, we sum up the new_cases for each day)
SELECT date, sum(new_cases) as world_wide_new_cases
FROM `portfolio-projects-435818.Project_1_of_4.CovidDeaths` 
WHERE continent is not null
GROUP BY date
ORDER BY date ASC
-- From the results, it can be seen that the number of reported new cases begins at zero, at the beginning of 2020, and begins incrasing from there


-- Q7: Total number of new cases, new deaths and the death percentage (that is the percentage of new deaths to new cases) in the world each day 
SELECT date,
      sum(new_cases) AS global_new_cases, -- Note 1
      sum(new_deaths) AS global_new_deaths, -- Note 2
      (sum(new_deaths)/sum(new_cases))*100 AS death_percentage -- Note 3
FROM `portfolio-projects-435818.Project_1_of_4.CovidDeaths` 
WHERE continent is not null
GROUP BY date
ORDER BY date ASC
-- Note 1 & 2: If one simply sums the total cases, cases will be added more than once, 'new_cases' is more accurate
-- Note 3: One cannot use a variable you just made to calculate a new variable, which is why the functions have to be used again
-- The results give the total cases which were reported that day, along with the deaths which occurred that day and the percentage of infected people who died. One can find the total global cases and deaths and death percentage by removing the date (and the grouping done by the date):

SELECT sum(new_cases) AS global_new_cases,
      sum(new_deaths) AS global_new_deaths, 
      (sum(new_deaths)/sum(new_cases))*100 AS death_percentage 
FROM `portfolio-projects-435818.Project_1_of_4.CovidDeaths` 
WHERE continent is not null
-- From the results, it can be seen that there were 674507739 global new cases within the range of this data, and 6840869 global new deaths and the death percentage was 1.0142017065870907%


-- Q8: Total population versus Number of vaccinations given (Note 1) 
SELECT dea.continent, dea.location, dea.date, population, new_vaccinations -- Note 2
FROM `portfolio-projects-435818.Project_1_of_4.CovidDeaths` AS dea
JOIN `portfolio-projects-435818.Project_1_of_4.CovidVaccinations` AS vac
  ON dea.location = vac.location 
  AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3
-- Note 1: In order to find the total population versus the number of vaccinations given, the CovidDeaths table and the CovidVaccinations need to be joined, since the population is in the one table and the vaccinations is in another table
-- Note 2: We need to specify the place where to find date, and location because this exists in both columns and it needs to know which one to fetch
-- From the results, it can be seen that Algeria started dping their vaccinations on 22 December 2024
-- To get a quick glance at South Africa and when vaccinations started in South Africa, the "where" function can be used to specify that location:

SELECT dea.continent, dea.location, dea.date, population, new_vaccinations 
FROM `portfolio-projects-435818.Project_1_of_4.CovidDeaths` AS dea
JOIN `portfolio-projects-435818.Project_1_of_4.CovidVaccinations` AS vac
  ON dea.location = vac.location 
  AND dea.date = vac.date
WHERE dea.continent is not null
AND dea.location = 'South Africa'
ORDER BY 1,2,3
-- From the results, it can be seen that South Africa started vaccinations on 19 February 2021


-- Q9: The previous query found the total new vaccinations per day. Now, we want to look at the total vaccinations done by a particular country up to the day in question (Note 1) which will require doing a rolling count
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated -- Note 2,3
FROM `portfolio-projects-435818.Project_1_of_4.CovidDeaths` AS dea
JOIN `portfolio-projects-435818.Project_1_of_4.CovidVaccinations` AS vac
  ON dea.location = vac.location 
  AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1, 2,3
-- Note 1: A table called "total vaccinations" does exist and this can be compared to the calculated values to check the accuracy of the calculation
-- Note 2: We partition by location first to make sure that the numbers are summed for a particular country, and then begin at zero for the next country; we do not want aggregate fuction to keep running
-- Note 3: Partitioning only by location gives the total sum of the total vaccinations and not a rolling number of total vaccinations up to that day


-- Q10: Total people vaccinated versus the population per day (Note 1)
SELECT *, (rolling_people_vaccinated/population)*100
FROM
      (SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
              SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
      FROM `portfolio-projects-435818.Project_1_of_4.CovidDeaths` AS dea
      JOIN `portfolio-projects-435818.Project_1_of_4.CovidVaccinations` AS vac
        ON dea.location = vac.location 
        AND dea.date = vac.date
      WHERE dea.continent is not null
      ORDER BY 1, 2,3)
-- Note 1: We want to calculate the rolling percentage of the percentage of the population vaccinated, but in order to find these values, we need to use the rolling_people_vaccinated column, but we cannot use a column that you've just created to calculate values in the next column. In order to circumvent this, a subquery that creates a new table with the rolling_people_vaccinated column is created, which can then be called now to populate the new table and calculate values in that table; 
-- From the results, it can be seen that as of 7 March 2023, 0.38% of the Algerian population had been vaccinated, while 33.42% of the South African population had been vaccinated


-- Q11: Create view to store data for later visualisation (in Tableau or Power BI)
CREATE VIEW Project_1_of_4.xyz AS -- Note 1
SELECT *, (rolling_people_vaccinated/population)*100 AS percent_population_vaccinated -- Note 2
FROM
      (SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
              SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
      FROM `portfolio-projects-435818.Project_1_of_4.CovidDeaths` AS dea
      JOIN `portfolio-projects-435818.Project_1_of_4.CovidVaccinations` AS vac
        ON dea.location = vac.location 
        AND dea.date = vac.date
      WHERE dea.continent is not null)
-- Note 1: A view is a table, which must be qualified with a dataset, which is why "Project_1_of_4" had to be added
-- Note 2: All the columns of a view have to be named, which is why this newly created column had to get a new name
-- Following this script, a new table was created, under the dataset "Project_1_of_4"
