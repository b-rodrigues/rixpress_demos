# functions.py
import pandas as pd
import numpy as np
import pickle

# Function to read CSV, used by rxp_py_file implicitly via lambda,
# but good practice to define standard readers if needed elsewhere.
def read_csv_pandas(path):
  """Reads a CSV file using pandas."""
  # Note: rxp_py_file copies the file to the build sandbox root
  # So we just use the basename derived from the target name.
  # If path were a folder, it would copy the folder content.
  return pd.read_csv(path)

# --- Preprocessing Functions ---

def drop_cols(df):
  """Drops Cabin and Ticket columns."""
  df = df.drop(['Cabin', 'Ticket'], axis=1, errors='ignore') # errors='ignore' for safety
  return df

def fill_embarked(df):
  """Fills missing Embarked with 'S'."""
  df['Embarked'] = df['Embarked'].fillna("S")
  return df

def handle_age(df):
  """Fills missing Age, creates AgeGroup."""
  df["Age"] = df["Age"].fillna(-0.5)
  bins = [-1, 0, 5, 12, 18, 24, 35, 60, np.inf]
  labels = ['Unknown', 'Baby', 'Child', 'Teenager', 'Student', 'Young Adult', 'Adult', 'Senior']
  df['AgeGroup'] = pd.cut(df["Age"], bins, labels=labels)
  return df

def extract_title(df):
  """Extracts Title from Name."""
  df['Title'] = df.Name.str.extract(' ([A-Za-z]+)\.', expand=False)
  # Handle potential NaN titles if pattern doesn't match
  df['Title'] = df['Title'].fillna('Unknown')
  return df

def clean_map_title(df):
  """Cleans and maps Title."""
  df['Title'] = df['Title'].replace(['Lady', 'Capt', 'Col', 'Don', 'Dr', 'Major', 'Rev', 'Jonkheer', 'Dona'], 'Rare')
  df['Title'] = df['Title'].replace(['Countess', 'Sir'], 'Royal') # Removed Lady as it's Rare now
  df['Title'] = df['Title'].replace('Mlle', 'Miss')
  df['Title'] = df['Title'].replace('Ms', 'Miss')
  df['Title'] = df['Title'].replace('Mme', 'Mrs')

  title_mapping = {"Mr": 1, "Miss": 2, "Mrs": 3, "Master": 4, "Royal": 5, "Rare": 6, "Unknown": 0} # Added Unknown
  df['Title'] = df['Title'].map(title_mapping)
  # Fill any remaining NaNs (e.g., if a new title appeared not covered above)
  df['Title'] = df['Title'].fillna(0)
  return df

def calculate_age_modes(train_df):
    """Calculates the mode AgeGroup for each Title in the training data."""
    # Ensure AgeGroup is calculated first
    if 'AgeGroup' not in train_df.columns:
        train_df = handle_age(train_df)
    if 'Title' not in train_df.columns:
        # Need Name column temporarily if Title not yet extracted
        temp_name_col = 'Name' in train_df.columns
        if not temp_name_col:
             raise ValueError("Need 'Name' column to extract 'Title' if not present")
        train_df = extract_title(train_df)
        train_df = clean_map_title(train_df)
        if not temp_name_col: # Remove Name if we added it
             train_df = train_df.drop('Name', axis=1)


    # Calculate modes safely, handling cases where a title might not exist
    modes = {}
    for title_code in range(7): # 0 to 6
        subset = train_df[train_df["Title"] == title_code]["AgeGroup"]
        if not subset.empty:
            modes[title_code] = subset.mode()[0] if not subset.mode().empty else 'Unknown' # Default if mode fails
        else:
            modes[title_code] = 'Unknown' # Default if title code not found

    # Default mapping based on analysis in the original code
    age_title_mapping = {
        1: modes.get(1, "Young Adult"), # Mr
        2: modes.get(2, "Student"),     # Miss
        3: modes.get(3, "Adult"),       # Mrs
        4: modes.get(4, "Baby"),        # Master
        5: modes.get(5, "Adult"),       # Royal
        6: modes.get(6, "Adult"),       # Rare
        0: "Unknown"                    # Unknown Title
    }
    return age_title_mapping


def impute_age_group(df, age_title_mapping):
  """Imputes 'Unknown' AgeGroup based on Title using the provided mapping."""
  # Ensure AgeGroup and Title exist
  if 'AgeGroup' not in df.columns or 'Title' not in df.columns:
      raise ValueError("DataFrame must have 'AgeGroup' and 'Title' columns for imputation.")

  # Use .loc for safe assignment
  unknown_age_mask = df["AgeGroup"] == "Unknown"
  # Create a series mapping titles to imputed ages for rows needing imputation
  imputed_ages = df.loc[unknown_age_mask, "Title"].map(age_title_mapping)
  # Assign the imputed values
  df.loc[unknown_age_mask, "AgeGroup"] = imputed_ages
  # Handle any titles that might not have been in the mapping (shouldn't happen with defaults)
  df['AgeGroup'] = df['AgeGroup'].fillna('Unknown')
  return df


def map_age_group(df):
  """Maps AgeGroup categories to numerical values."""
  age_mapping = {'Baby': 1, 'Child': 2, 'Teenager': 3, 'Student': 4,
                 'Young Adult': 5, 'Adult': 6, 'Senior': 7, 'Unknown': 0} # Added Unknown mapping
  # Ensure all values in AgeGroup are strings before mapping
  df['AgeGroup'] = df['AgeGroup'].astype(str)
  df['AgeGroup'] = df['AgeGroup'].map(age_mapping)
  # Fill NaN if any category wasn't in the mapping (safety)
  df['AgeGroup'] = df['AgeGroup'].fillna(0)
  return df


def drop_age_name(df):
  """Drops the original Age and Name columns."""
  df = df.drop(['Age', 'Name'], axis=1, errors='ignore')
  return df

def map_sex(df):
  """Maps Sex to numerical values."""
  sex_mapping = {"male": 0, "female": 1}
  df['Sex'] = df['Sex'].map(sex_mapping)
  # Handle potential NaNs or unexpected values
  df['Sex'] = df['Sex'].fillna(-1) # Or another placeholder
  return df

def map_embarked(df):
  """Maps Embarked to numerical values."""
  embarked_mapping = {"S": 1, "C": 2, "Q": 3}
  df['Embarked'] = df['Embarked'].map(embarked_mapping)
  # Handle potential NaNs or unexpected values
  df['Embarked'] = df['Embarked'].fillna(0) # Or another placeholder
  return df


def calculate_fare_means(train_df):
    """Calculates the mean Fare for each Pclass in the training data."""
    # Ensure 'Fare' and 'Pclass' exist
    if 'Fare' not in train_df.columns or 'Pclass' not in train_df.columns:
        raise ValueError("DataFrame must have 'Fare' and 'Pclass' columns.")

    fare_means = {}
    for pclass in train_df['Pclass'].unique():
        mean_fare = train_df[train_df["Pclass"] == pclass]["Fare"].mean()
        fare_means[pclass] = round(mean_fare, 4) if pd.notnull(mean_fare) else 0 # Default to 0 if mean is NaN

    # Ensure all potential Pclasses (1, 2, 3) have a default value if not in data
    for pclass in [1, 2, 3]:
        if pclass not in fare_means:
            fare_means[pclass] = 0

    return fare_means


def impute_fare(df, fare_means_map):
  """Imputes missing Fare based on Pclass using the provided mean map."""
  if 'Fare' not in df.columns or 'Pclass' not in df.columns:
      raise ValueError("DataFrame must have 'Fare' and 'Pclass' columns.")

  missing_fare_mask = df["Fare"].isnull()
  # Create a series mapping Pclass to imputed fares for rows needing imputation
  imputed_fares = df.loc[missing_fare_mask, "Pclass"].map(fare_means_map)
  # Assign the imputed values
  df.loc[missing_fare_mask, "Fare"] = imputed_fares
  # Handle cases where Pclass might not be in the map (e.g., Pclass 0?) - fill with global mean or 0
  df['Fare'] = df['Fare'].fillna(df['Fare'].mean()) # Fallback
  return df


def create_fare_band(df):
  """Creates FareBand by quantizing Fare."""
  # Ensure Fare is numeric and handle infinities or very large values if necessary
  df['Fare'] = pd.to_numeric(df['Fare'], errors='coerce').fillna(0)
  # Use qcut safely, handling potential duplicate edges
  try:
      df['FareBand'] = pd.qcut(df['Fare'], 4, labels=[1, 2, 3, 4], duplicates='drop')
  except ValueError:
      # Fallback if qcut fails (e.g., not enough unique values)
      # You might assign bands based on fixed values or just assign a default
      print("Warning: qcut failed for FareBand, using fixed bands or default.")
      # Example fallback: Assign based on quartiles manually or just put everything in one band
      q1 = df['Fare'].quantile(0.25)
      q2 = df['Fare'].quantile(0.5)
      q3 = df['Fare'].quantile(0.75)
      bins = [-np.inf, q1, q2, q3, np.inf]
      df['FareBand'] = pd.cut(df['Fare'], bins=bins, labels=[1, 2, 3, 4], right=False, duplicates='drop')
      df['FareBand'] = df['FareBand'].fillna(1) # Fill NaNs resulting from cut

  # Convert FareBand to integer, handling potential NaNs from qcut/cut
  df['FareBand'] = df['FareBand'].astype(float).fillna(1).astype(int)
  return df

def drop_fare(df):
  """Drops the original Fare column."""
  df = df.drop(['Fare'], axis=1, errors='ignore')
  return df

# --- Combined Preprocessing ---
# It might be better to call these sequentially in the pipeline
# for clarity, but here's a combined function example:

def preprocess_dataframe(df, is_train=True, train_stats=None):
    """Applies all preprocessing steps."""
    df = drop_cols(df)
    df = fill_embarked(df)
    df = handle_age(df) # Creates AgeGroup
    df = extract_title(df) # Creates Title
    df = clean_map_title(df) # Maps Title

    calculated_stats = {}
    if is_train:
        age_title_mapping = calculate_age_modes(df.copy()) # Use copy to avoid side effects if df is reused
        fare_means_map = calculate_fare_means(df.copy())
        calculated_stats['age_title_mapping'] = age_title_mapping
        calculated_stats['fare_means_map'] = fare_means_map
    else:
        if train_stats is None:
            raise ValueError("train_stats must be provided when is_train=False")
        age_title_mapping = train_stats['age_title_mapping']
        fare_means_map = train_stats['fare_means_map']

    df = impute_age_group(df, age_title_mapping) # Imputes AgeGroup using Title
    df = map_age_group(df) # Maps AgeGroup to numbers
    df = drop_age_name(df) # Drops Age, Name
    df = map_sex(df) # Maps Sex
    df = map_embarked(df) # Maps Embarked

    df = impute_fare(df, fare_means_map) # Imputes Fare using Pclass means
    df = create_fare_band(df) # Creates FareBand
    df = drop_fare(df) # Drops Fare

    if is_train:
        return df, calculated_stats
    else:
        return df


# --- ML Functions ---
def split_predictors_target(df):
  """Splits DataFrame into predictors (X) and target (y)."""
  if 'Survived' not in df.columns:
      raise ValueError("DataFrame must have 'Survived' column to split.")
  predictors = df.drop(['Survived', 'PassengerId'], axis=1)
  target = df["Survived"]
  return predictors, target

# --- Custom Serialization for Final CSV ---
def write_dataframe_to_csv(df, path):
  """Writes a pandas DataFrame to CSV."""
  # The 'path' provided by rixpress will be the derivation name.
  # We want the output file to be specifically 'resultfile.csv'.
  # So, we ignore the 'path' argument here and write to the fixed name.
  # The Nix derivation will capture this file.
  df.to_csv('resultfile.csv', index=False)
  # We still need to create the 'path' file expected by rixpress
  # It can be empty or contain metadata. Let's make it empty.
  with open(path, 'w') as f:
      f.write('') # Create the empty file named after the derivation
