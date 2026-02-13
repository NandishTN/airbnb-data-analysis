import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

# Load data
df = pd.read_csv(r"C:\Users\nandi\OneDrive\Desktop\airbnb data\listings.csv.gz")

# Quick overview
print(df.head())
print(df.info())
print(df.describe())
print(df.isnull().sum())

# Clean price column
df['price'] = df['price'].replace('[£$,]', '', regex=True).astype(float)

# Select relevant columns
df = df[['id','price','room_type','neighbourhood',
         'minimum_nights','number_of_reviews',
         'availability_365']]

# Remove missing values
df.dropna(inplace=True)

# Price distribution
sns.histplot(df['price'], bins=50)
plt.title("UK Airbnb Price Distribution")
plt.show()

# Room type vs price
sns.boxplot(x='room_type', y='price', data=df)
plt.title("Room Type vs Price")
plt.show()

# Save cleaned data
df.to_csv(r"C:\Users\nandi\OneDrive\Desktop\airbnb data\uk_airbnb_cleaned.csv", index=False)
