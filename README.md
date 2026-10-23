# Traffic Accident Analysis

Road-safety analytics project using MySQL and Power BI to examine which road, weather and lighting conditions are associated with higher injury and crash severity.

## Project Overview

This project analyzes 209,275 cleaned traffic-crash records using SQL and Power BI.

The analysis focuses on a key road-safety question:

> Which road, weather and lighting conditions are associated with more injuries and more serious crashes?

Rather than relying only on raw injury counts, the project compares injury rates across conditions because the number of crashes varies substantially by weather, lighting and road conditions.

## Business Problem

A city transport agency wants to understand which conditions are associated with more injuries and more serious crashes so that road-safety measures can be targeted where they may have the greatest impact.

Counting injuries alone can be misleading because most driving occurs in common conditions such as clear weather, daylight and dry roads.

The analysis therefore combines:

- Crash counts
- Injury counts
- Injury rates
- Incapacitating-injury rates
- Condition-level comparisons

## Dataset

- Dataset: Traffic_accidents Dataset
- Original records: 209,306
- Final analytical records: 209,275
- Columns: 24
- Coverage: 2013–2025 (2013 and 2025 are partial years)

Key fields include:

- Crash date
- Weather condition
- Lighting condition
- Road surface
- Crash type
- Primary contributory cause
- Total injuries
- Incapacitating injuries
- Fatalities


## Data Preparation

SQL was used as the primary analytical layer.

The preparation workflow included:

- Inspecting table structure and data quality
- Identifying and removing duplicate records
- Reviewing unknown values in key categorical fields
- Preparing date fields
- Validating the cleaned analytical table

The dataset was reduced from 209,306 original records to 209,275 final analytical records.

## Business Questions

1. Which weather condition has the highest total injuries?
2. Which lighting condition has the highest and lowest incapacitating injuries?
3. Which road surface has the most crashes, and what is the most common primary cause within it?
4. What is the most common first crash type?
5. In which months does the most common crash type occur most and least?

Because raw counts can be influenced by how frequently a condition occurs, the analysis also asks:

6. Which weather condition has the highest injury rate per 100 crashes?
7. Which lighting condition has the highest incapacitating-injury rate per 1,000 crashes?
8. What share of dry-road crashes have no determined cause?

## Key Findings

### Weather

Clear weather recorded the most injuries:

- 64,288 injuries
- Approximately 80% of all injuries
- Clear weather accounted for approximately 79% of crashes

However, Rain had the highest injury rate:

- 41.2 injuries per 100 crashes
- Overall rate: about 38 injuries per 100 crashes (clear weather: 39.0)

This shows why injury rates provide additional context beyond raw counts.
The gap is modest: rain is about 8% above the overall rate, so it is a signal to investigate, not proof of a large effect.

### Lighting

Daylight recorded the most incapacitating injuries:

- 4,557 incapacitating injuries

However, Darkness, lighted road had the highest incapacitating-injury rate:

- 49.3 incapacitating injuries per 1,000 crashes

The Unknown lighting category had the fewest incapacitating injuries, but its small size makes it unsuitable for strong interpretation.

### Road Surface and Contributory Cause

Dry roads recorded the most crashes.

Within dry-road crashes, the most common primary cause was Unable to determine:

- 41,610 crashes
- 26.7% of dry-road crashes

This represents a data-quality gap because the largest cause category does not explain why the crashes occurred.

### Crash Type

Turning was the most common first crash type:

- 64,150 crashes
- 30.7% of all crashes

### Monthly Pattern

The most common crash type, No injury / drive away, occurred most often in October:

- 11,136 crashes

It occurred least often in April:

- 8,463 crashes

Monthly comparisons should be interpreted carefully because month length and the number of years represented affect raw counts, and 2025 is a partial year.

## Recommendations

1. Prioritize safety measures for Rain and Darkness, lighted road, where risk per crash is highest rather than focusing only on conditions with the most crashes.
2. Improve crash-cause recording because a large share of records have no determined cause.
3. Investigate Turning crashes, particularly at intersections, because Turning is the most common first crash type.

## Dashboard

The Power BI dashboard presents the analyzed traffic-accident patterns through interactive visualizations covering:

- Weather
- Lighting
- Road surface
- Crash type
- Contributory cause
- Injury rates
- Monthly patterns

## Limitations

- This is observational data. The findings show associations, not causal relationships.
- Crash counts reflect how much driving occurs in each condition.
- The dataset does not contain traffic-volume figures, so crash rates per vehicle or per mile cannot be calculated.
- 2013 and 2025 are partial years, so monthly and annual comparisons may be affected.
- Unknown categories should be interpreted cautiously, especially where the number of records is small.

## Tools

- MySQL
- MySQL Workbench
- SQL
- Power BI
- DAX

## Project Files

- SQL data-cleaning script
- SQL exploratory data-analysis script
- Traffic accidents dataset
- Power BI report
- Dashboard screenshot
- Project documentation

## Outcome

The project demonstrates an end-to-end road-safety analytics workflow:

SQL data cleaning → Exploratory analysis → Rate-based risk analysis → Power BI visualization → Business recommendations

## Author

Sofeeyah Adekunle
Data Analyst
