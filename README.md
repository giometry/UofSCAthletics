Overview

In collegiate athletics, not all ticket purchasers attend the games they buy tickets for, leading to no-shows that negatively impact game-day experience and revenue. Empty seats contribute to a diminished atmosphere, lost concession sales, and a weaker overall fan experience. Recognizing these challenges, the University of South Carolina (UofSC) Athletics Department aimed to better understand the drivers of attendance behavior and find ways to reduce no-shows. Our team collaborated with UofSC Athletics to develop a predictive model that estimates the likelihood of a ticket holder attending a specific game. This model helps identify at-risk ticket holders in advance, enabling targeted outreach and improved attendance strategies.

User Guide:

1. Use Subset_Data.ipynb (Python Notebook)
Purpose: Subset the original datasets for analysis.
Inputs:
    fact_ticket.csv
    fan_factor.csv
Instructions:
    Open Subset_Data.ipynb.
    In Cell 2, change the file path and filenames (fact_ticket.csv, fan_factor.csv) if needed.
    Update filtering logic if required.
    In the last cell, change the output file name to your preferred file name.
Output:
    A CSV file with the subsetted data.

2. Use DataPrep.ipynb (Python Notebook)
Purpose: Clean and transform the subsetted data for modeling.
Input:
    Subsetted data file from step 1 (e.g., subset_data.csv)
Instructions:
    Open DataPrep.ipynb.
    In Cell 2, change the file path and filename to match your subsetted data.
    Review and adjust any data cleaning steps if needed.
    In the last cell, update the output file name as desired.
Output:
    A cleaned dataset in CSV format.

3. Run R Model Code (e.g., run_model.R)
Purpose: Train a model using the cleaned data.
Input:
    Cleaned dataset from step 2 (e.g., clean_data.csv)
Instructions:
    Open your R script for modeling.
    Make sure it reads the cleaned CSV correctly.
    Run the script in R or RStudio.
Output:
    An .rds file containing the model parameters and accuracy metrics.
