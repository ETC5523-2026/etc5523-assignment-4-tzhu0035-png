# One day in the life of 6,146 Americans

How each respondent to the 2025 American Time Use Survey (ATUS) spent
the 24 hours of their diary day, collapsed into 15 everyday activity
categories, together with a few characteristics of the respondent and
the day type the day was assigned to.

## Usage

``` r
atus_days
```

## Format

A tibble with 6,146 rows and 25 columns:

- id:

  ATUS case identifier (`TUCASEID`).

- weight:

  ATUS final survey weight (`TUFINLWGT`).

- age:

  Age in years (`TEAGE`; 80 to 84 recorded as 80, 85 and over as 85).

- sex:

  Sex, `"Male"` or `"Female"` (`TESEX`).

- employed:

  Is the respondent employed (`TELFS` 1 or 2)?

- student:

  Is the respondent enrolled in high school, college or university
  (`TESCHENR`)? Only asked of people aged 15 to 49; others are `FALSE`.

- youngest_child_age:

  Age of the youngest own child under 18 in the household
  (`TRYHHCHILD`); `NA` if none.

- weekend:

  Was the diary day a Saturday or Sunday?

- sleep, personal_care, eating, work, education, housework, childcare,
  adult_care, shopping_services, socialising, screen, other_leisure,
  exercise, religious_volunteer, travel:

  Minutes spent in each activity category; see
  [activity_categories](https://etc5523-2026.github.io/etc5523-assignment-4-tzhu0035-png/reference/activity_categories.md).

- other:

  Minutes that could not be coded (ATUS codes 50xxxx).

- day_type:

  Day type the day was assigned to; see
  [day_types](https://etc5523-2026.github.io/etc5523-assignment-4-tzhu0035-png/reference/day_types.md).

The 15 activity columns plus `other` add up to 1,440 minutes for every
row.

## Source

U.S. Bureau of Labor Statistics, American Time Use Survey 2025, Activity
Summary file, <https://www.bls.gov/tus/data/datafiles-2025.htm>. BLS
data are in the public domain. Prepared in `data-raw/atus_days.R`.

## Details

Each row is one person's diary for one day (4am to 4am), so a "day type"
describes a day, not a person. Weekends are over-sampled in the ATUS:
use `weight` for any estimate about the population.
