import os
# import sys
import argparse
import requests
import logging
import time
import json
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import google.auth
from dotenv import load_dotenv
from tqdm import tqdm
from google.cloud import bigquery
from google.oauth2 import service_account
from google.auth.transport.requests import Request

# Argument Parser
parser = argparse.ArgumentParser(
    "GDA Capstone Analysis",
    "Analyze the cyclistic bike share data.",
)

# parser.add_argument(
#     "--svc",
#     action="store",
#     dest="svc_act",
#     help="Decide whether or not to use the service account credentials.",
#     type=bool,
# )

args = parser.parse_args()
# use_svc = args.svc_act

## INITIALIZE VARIABLES
path = os.path.dirname(__file__)
load_dotenv(f'{path}/.env')
project = os.getenv('GCP_PROJECT')
location = os.getenv('LOCATION')
key_path = f'{path}/gwg-capstone-419217-9b387d6160ee.json'
ms_job_id = os.getenv('MS_JOB_ID')
td_job_id = os.getenv('TD_JOB_ID')
ms_local = os.getenv('MS_LOCAL')
td_local = os.getenv('TD_LOCAL')

# if use_svc:
credentials = service_account.Credentials.from_service_account_file(key_path)
scoped_credentials = credentials.with_scopes(['https://www.googleapis.com/auth/cloud-platform'])
client = bigquery.Client(project=project, location=location, credentials=scoped_credentials)
# else:
#     client = bigquery.Client(project=project, location=location)

# Load the SQL Queries

if ms_local:
    job = client.get_job(ms_job_id)
    ms = job.result().to_dataframe(progress_bar_type='tqdm')
    # ms = pd.read_csv(f'{path}/data_dl/{ms_local}')
else:
    mem_sum = open(f'{path}/queries/monthly_member_stats.sql', 'r').read()
    job = client.query(mem_sum)
    ms =  job.to_dataframe(progress_bar_type='tqdm')
    ms.to_csv(f'{path}/data_dl/member_stats.csv', index=False)
    os.environ['MS_JOB_ID'] = job.job_id
    os.environ['MS_LOCAL'] = 'member_stats.csv'
    print('\nSaved local Member Stats from Job ID:\n', job.job_id, '\n')

if td_local:
    job = client.get_job(td_job_id)
    td = job.result().to_dataframe(progress_bar_type='tqdm')
    # td = pd.read_csv(f'{path}/data_dl/{td_local}')
else:
    tripdata = open(f'{path}/queries/random_sampling.sql', 'r').read()
    job = client.query(tripdata)
    td =  job.result().to_dataframe(progress_bar_type='tqdm')
    td.to_csv(f'{path}/data_dl/tripdata.csv', index=False)
    os.environ['TD_JOB_ID'] = job.job_id
    os.environ['TD_LOCAL'] = 'tripdata.csv'
    print('\nSaved local Trip Data from Job ID:\n', job.job_id, '\n')

print('\n################## MEMBER STATS ##################')
print(ms, '\n')

print('\n################## TRIP DATA ##################')
print(td, '\n')


# Parse the member_stats data
data = json.loads(ms.to_json())

member_stats = []
for i, year_month in data['year_month'].items():
    for usage in data['member_usage'][i]:
        member_stats.append({
            "year_month": year_month,
            "member_type": usage["member_type"],
            "total_rides": usage["total_rides"],
            "max_duration": usage["max_duration"],
            "avg_duration": usage["avg_duration"]
        })

# Create and format the dataframes

ms_df = pd.DataFrame(member_stats)
td_df = pd.DataFrame(td)
ms_df['year_month'] = pd.to_datetime(ms_df['year_month'])
ms_df['total_rides'] = ms_df['total_rides'] / 100000
ms_df['avg_duration'] = pd.to_timedelta(ms_df['avg_duration'])
ms_df['avg_duration_minutes'] = ms_df['avg_duration'] / pd.Timedelta(minutes=1)
ms_df.set_index('year_month', inplace=True)

# Plot the number of rides per month per member_type

ms_df_pivot = ms_df.pivot(columns='member_type', values='total_rides')
ms_df_pivot.plot(kind='line')
plt.title('Number of rides per month per member_type')
plt.xlabel('Month')
plt.ylabel('Number of rides (per 100,000)')
plt.legend()
plt.savefig(f'{path}/figures/total_rides.png')

# Plot the average trip duration per month per member_type

ms_df_pivot = ms_df.pivot(columns='member_type', values='avg_duration_minutes')
ms_df_pivot.plot(kind='line')
plt.title('Average trip duration per month per member_type')
plt.xlabel('Month')
plt.ylabel('Duration (mins)')
plt.legend()
plt.savefig(f'{path}/figures/avg_duration.png')

# User Type Distribution

td_df['member_type'].value_counts().plot(kind='pie', autopct='%1.1f%%')
plt.title('Distribution of Member Types')
plt.xlabel('')
plt.ylabel('')
plt.legend().remove()
plt.savefig(f'{path}/figures/member_type_breakdown.png')

# # Breakfown of Bike Type per Member Type

td_df_pivot = td_df.pivot_table(index='member_type', columns='rideable_type', values='ride_id', aggfunc='count')
td_df_pivot.plot(kind='bar', stacked=True)
# td_df_pivot.value_counts().plot(kind='pie', autopct='%1.1f%%')
plt.title('Bike Type Breakdown per Member Type')
plt.xlabel('Member Type')
plt.ylabel('Number of Rides')
plt.xticks(rotation=45, ha='right')
plt.legend(title='Bike Type')
plt.savefig(f'{path}/figures/bike_type_breakdown.png')

# Top Start Stations per Member Type

td_df_pivot = td_df.pivot_table(index='start_station_name', columns='member_type', values='ride_id', aggfunc='count')
td_df_pivot = td_df_pivot.fillna(0)
td_df_pivot['Total'] = td_df_pivot.sum(axis=1)
td_df_pivot = td_df_pivot.sort_values(by='Total', ascending=False).head(10)
td_df_pivot.drop(columns='Total', inplace=True)
td_df_pivot.plot(kind='bar', stacked=True)
plt.title('Top Start Stations per Member Type')
plt.xlabel('Start Station')
plt.ylabel('Number of Rides')
plt.legend(title='Member Type')
plt.xticks(rotation=45, ha='right')
plt.tight_layout()
plt.savefig(f'{path}/figures/top_start_stations_per_member_type.png')

# # Trip Duration Distribution

# td_df['trip_duration_minutes'].plot(kind='hist', bins=50)
# plt.title('Trip Duration Distribution')
# plt.xlabel('Duration (mins)')
# plt.ylabel('Number of Rides')
# plt.savefig(f'{path}/figures/trip_duration_distribution.png')

# # Trip Duration Distribution per Member Type

# td_df.boxplot(column='trip_duration_minutes', by='member_type')
# plt.title('Trip Duration Distribution per Member Type')
# plt.suptitle('')
# plt.xlabel('Member Type')
# plt.ylabel('Duration (mins)')
# plt.savefig(f'{path}/figures/trip_duration_distribution_per_member_type.png')

# # Trip Duration Distribution per Bike Type

# td_df.boxplot(column='trip_duration_minutes', by='rideable_type')
# plt.title('Trip Duration Distribution per Bike Type')
# plt.suptitle('')
# plt.xlabel('Bike Type')
# plt.ylabel('Duration (mins)')
# plt.savefig(f'{path}/figures/trip_duration_distribution_per_bike_type.png')

# # Bell Curve of Trip Duration

# td_df['trip_duration_minutes'].plot(kind='hist', bins=50, density=True, alpha=0.6)
# td_df['trip_duration_minutes'].plot(kind='kde')
# plt.title('Trip Duration Distribution')
# plt.xlabel('Duration (mins)')
# plt.ylabel('Density')
# plt.savefig(f'{path}/figures/trip_duration_bell_curve.png')

# Show all the figures
plt.show()

# print(df.columns)
# # print('\n################## SUMMARY STATISTICS ##################')
# # print(df.describe(include='all'))
# print('\n################## CUSTOMIZED SUMMARY STATISTICS ##################')
# print('Total Rides: ', len(df['ride_id']))
# print('Shortest Trip Duration (min):', df['trip_duration_minutes'].min().round(2))
# print('Average Trip Duration (min):', df['trip_duration_minutes'].mean().round(2))
# print('Longest Trip Duration (min):', df['trip_duration_minutes'].max().round(2))
# print('Top Start Station (Frequency):', df["start_station_name"].value_counts().head(1))
# print('First Trip: ', df.reset_index()["started_at"].min())
# print('Last Trip: ', df.reset_index()["started_at"].max())

# print('\n################## AVG TRIP DURATION PER MEMBER TYPE ##################')
# print(df.groupby('member_type')['trip_duration_minutes'].mean())