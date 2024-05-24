# Ethan's Data Analytics Capstone Project

I decided to take the [Google Data Analytics Coursera Course](https://www.coursera.org/professional-certificates/google-data-analytics) to formalize my coding skills in SQL and begin expanding my coding skills in Python. As part of this course, I completed the following case study analyzing bike usage data to demonstrate what I learned using the Pandas Framework.

## Business Task

A bike-share program, Cyclistic, has decided that annual members of it's service are much more profitable than causal riders. 

A revenue generating goal has been identified to create a marketing compaign targeted to casual riders and incentivize them to convert to an annual membership. 

The team is interested in answering the following questions by analyzing trends in historical bike trip data. The first question will be answered by this study to help the business understand how each type of rider's bike usage differs.

1. #### How do annual members and casual riders use Cyclistic bikes dierently? 
1. #### Why would casual riders buy Cyclistic annual memberships?
1. #### How can Cyclistic use digital media to influence casual riders to become members?

> For more information see [the full case study here](/rstudio/capstone/Case-Study-1_How-does-a-bike-shared-navigate-speedy-success_-2.pdf)

## Data Sources

The data was publically sourced under the name 'Divvy' as collected and provided by Chicago Department of Transportation ("Provider") under [this license](https://divvybikes.com/data-license-agreement) and is being stored using Google BigQuery (location: *us-central-1*) for the purposes of this analysis.

This case study reports on bike data between *__March 2020  - February 2024__*, more recent data is available [here](https://divvy-tripdata.s3.amazonaws.com/index.html).

> Data Source: <https://divvy-tripdata.s3.amazonaws.com/index.html>

> Divvy System Data: <https://divvybikes.com/system-data>

-----

### Project Tables

`tripdata` - The original data ingested and collected into a single table using [this schema](/rstudio/capstone/table_schema.json)

| Info                    |                                                          |
| :---------------------  | :------------------------------------------------------- |
| Table ID                | gwg-capstone-419217.cyclistic.tripdata             |
| Created                 | May 13, 2024, 11:04:50 PM UTC-6                          |
| Last modified           | May 13, 2024, 11:04:50 PM UTC-6                          |
| Data location           | us-central1                                              |
| Default rounding mode   | ROUNDING_MODE_UNSPECIFIED                                |
| Number of rows          | 19,304,267                                               |
| Total logical bytes     | 2.69 GB                                                  |

`cleaned-tripdata` - The cleaned trip data accorsing to the cleaning process below.

| Info                    |                                                          |
| :---------------------  | :------------------------------------------------------- |
| Table ID                | gwg-capstone-419217.cyclistic.cleaned-tripdata     |
| Created                 | May 13, 2024, 11:05:26 PM UTC-6                          |
| Last modified           | May 13, 2024, 11:05:26 PM UTC-6                          |
| Data location           | us-central1                                              |
| Default rounding mode   | ROUNDING_MODE_UNSPECIFIED                                |
| Number of rows          | 19,304,267                                               |
| Total logical bytes     | 3.4 GB                                                   |

`cleaned_stations` - An additional table of cleaned station names and unique IDs.

| Info                    |                                                          |
| :---------------------  | :------------------------------------------------------- |
| Table ID                | gwg-capstone-419217.cyclistic.cleaned_stations           |
| Created                 | May 13, 2024, 11:07:03 PM UTC-6                          |
| Last modified           | May 13, 2024, 11:07:03 PM UTC-6                          |
| Data location           | us-central1                                              |
| Default rounding mode   | ROUNDING_MODE_UNSPECIFIED                                |
| Number of rows          | 3,193                                                    |
| Total logical bytes     | 255.64 KB                                                |

### Cleaning Process

The original data downloaded from the Provider contained 45 individual CSV files, one for each month of public trip data. I decided to use Google BigQuery to house the data for an easy way to clean the data, begin an analysis and document my process.

#### Create New Trip Data Table

> Reference [create_cleaned_tripdata.sql](/rstudio/capstone/queries/create_cleaned_tripdata.sql) for the below cleaning process.

The following fields were created using calculations from existing columns:

* trip_duration
* trip_duration_seconds
* start_day_of_week

#### Create Station Table

> Reference [create_stations.sql](/rstudio/capstone/queries/create_stations.sql) for the below cleaning process.

Upon further analysis, I realized that not all rides had valid station info.

* Some rides had a start station identified but not an end station and vice versa.
* Some station IDs had a trailing '.0' which I removed.
* Some stations were missing a name and ID but had a valid latitude and longitude, I used a concenated integer of the lat/long to give those stations unique names.
* Some stations had multiple IDs, inconsistently formatted names/IDs or were missing one of the two aspects.

Each cleaned station was then given a universally unique identifier (UUID) which was added back into the original trip data table for start and end stations.

Stations and their ridership trends were not analyzed as part of this phase of the project.

## Analysis

> Reference [analysis.py](/rstudio/capstone/analysis.py) for the below analysis.

[daily_summary.sql](/rstudio/capstone/queries/daily_summary.sql)

Creates a JSON-formatted result for each month of trip data and breaks down ride information by day of the week.

[monthly_member_stats.sql](/rstudio/capstone/queries/monthly_member_stats.sql)

Creates a JSON-formatted result that details system usage per member type for trip summary statistics, number of total rides and top stations during each month.

[random_sampling.sql](/rstudio/capstone/queries/random_sampling.sql)

Pulls a random sample for one percent of the total trip data to be analyzed in the different charts used in this study.

## Conclusion

### System usage by Member Type

Overall, annual members take more rides versus casual members.

![Member Type Breakdown](/rstudio/capstone/figures/member_type_breakdown.png)

### Bike Type Usage by Member Type

Which type of bikes are used is relatively similar per member type.

![Member Type Breakdown](/rstudio/capstone/figures/bike_type_breakdown.png)

Casual members typically use __electronic bikes__ which have a total of __3,268,968__ rides.

Annual members typically use __classic bikes__ which have a total of __5,422,506__ rides.

### Average trip durations per Member Type

While casual members take less bike trips overall, they tend to have a longer trip duration when compared to annual members. Overall, average trip duration has been declining for casual members while trip duration for annual members is steady between 10 and 25 minutes.

![Average trip duration](/rstudio/capstone/figures/avg_duration.png)

__Casual Members:__ 32 minutes 21 seconds
__Annual Members:__ 12 minutes 43 seconds

### Total rides per Member Type

Number of trips taken is directly coorelated to the season. July - October are peak usage months for the Cyclistic system.

![Total rides per member type](/rstudio/capstone/figures/total_rides.png)

### Top Start Stations per Member Type

The aid a targeted marketing campaing, it would be helpful to know which stations riders most frequently start their trips at.

![Top Start Stations per Member Type](/rstudio/capstone/figures/top_start_stations_per_member_type.png)

This chart is ordered by total number of trips taken despite member type but overall but we can see that casual riders mainly start their trips at the __Streeter Dr and Graned Ave__ station.

### Campaign Recommendations

The project asked to provide recommendations for my "manager" as they consider options for creating the marketing campaign to convert casual riders into annual members based on how their usage of the system differs.

1. Place advertisements at or around the top stations where casual riders typically start their trips such as the __Streeter Dr and Graned Ave__ station.
1.  Time these campaigns during the peak usage months of July and October.
1. Since annual members typically hav shorter trips, created a targeted messaging around "quick trips around the city".
1. Once trips are completed, the company could send a follow up message to the casual rider with an offer for a discounted membership.

### Next Steps

* Turn this into a Jupyter Notebook
* Continue answering the remaining questions from the project overview
* Reformat charts...
    * Trip distribution box plots
    * Bike Type Breakdown into pie charts instead of bar charts
* Script clean up
    * Add an argument to use the local user or service account
    * Reference the local job results in the dataframe if already downloaded
    * Check if the saved Job ID is expired
    * If the Job ID is expired, then run a new job and update the local cache
    * Update the progress bar for downloading query cache to show request size
    * Add console logging to note which steps are occuring
* Additional Data
    * Append user data that is included with some monthly reports
    * Stream in new months of data as they are published by the source