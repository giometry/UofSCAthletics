# Game Attendance Prediction Model

## Overview

In collegiate athletics, not all ticket purchasers attend the games they buy tickets for, leading to no-shows that negatively impact game-day experience and revenue. Empty seats contribute to a diminished atmosphere, lost concession sales, and a weaker overall fan experience.

Recognizing these challenges, the University of South Carolina (UofSC) Athletics Department aimed to better understand the drivers of attendance behavior and find ways to reduce no-shows. Our team collaborated with UofSC Athletics to develop a predictive model that estimates the likelihood of a ticket holder attending a specific game. This model helps identify at-risk ticket holders in advance, enabling targeted outreach and improved attendance strategies.

---

## User Guide

### 1. `Subset_Data.ipynb` (Python Notebook)

**Purpose**: Subset the original datasets for analysis.

**Inputs**:
- `fact_ticket.csv`
- `fan_factor.csv`

**Instructions**:
- Open `Subset_Data.ipynb`.
- In **Cell 2**, update the file path and filenames if needed.
- Modify the filtering logic as required.
- In the **last cell**, set your desired output file name.

**Output**:
- A CSV file containing the subsetted data.

---

### 2. `DataPrep.ipynb` (Python Notebook)

**Purpose**: Clean and transform the subsetted data for modeling.

**Input**:
- Subsetted dataset from step 1 (e.g., `subset_data.csv`)

**Instructions**:
- Open `DataPrep.ipynb`.
- In **Cell 2**, update the file path and filename to match the subsetted data.
- Review and edit any cleaning steps if needed.
- In the **last cell**, define your output file name.

**Output**:
- A cleaned dataset in CSV format.

---

### 3. R Model Script (e.g., `run_model.R`)

**Purpose**: Train a predictive model using the cleaned data.

**Input**:
- Cleaned dataset from step 2 (e.g., `clean_data.csv`)

**Instructions**:
- Open your R modeling script (e.g., `run_model.R`).
- Ensure it reads the cleaned CSV correctly.
- Run the script in R or RStudio.

**Output**:
- An `.rds` file containing model parameters and performance metrics.
