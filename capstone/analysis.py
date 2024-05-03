from google.cloud import bigquery
import pandas as pd
import matplotlib.pyplot as plt

project = 'gwg-capstone-419217' # Project ID inserted based on the query results selected to explore
dataset = 'cyclistic' # Dataset ID inserted based on the query results selected to explore
table = 'cleaned-divvy-tripdata' # Table ID inserted based on the query results selected to explore
location = 'us-central1' # Location inserted based on the query results selected to explore
client = bigquery.Client(project=project, location=location)

# Query to select the data from the table
query = f"""
SELECT *
FROM `{dataset}.{table}`
LIMIT 1000
"""

# Load the data into a DataFrame
df = client.query(query).result().to_dataframe()

# Display the summary statistics
df.describe()

# Display the average trip duration per member_type
df.groupby('member_type')['trip_duration'].mean()

# Plot the number of rides over time
df.set_index('started_at', inplace=True)

monthly_rides = df.groupby('member_type').resample('M').size()

monthly_rides = monthly_rides.reset_index()

monthly_rides_pivot = monthly_rides.pivot(index='started_at', columns='member_type', values=0,)

plt.figure(figsize=(12, 6))  # Set the figure size to be wider

monthly_rides_pivot.plot(kind='line')
plt.title('Number of rides per month per member_type')
plt.xlabel('Month')
plt.ylabel('Number of rides')
plt.show()