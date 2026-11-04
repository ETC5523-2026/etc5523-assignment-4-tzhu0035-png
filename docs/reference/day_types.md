# Eight types of day, and who has them

A summary of the eight day types found by grouping the 2025 ATUS diary
days with survey-weighted k-means clustering on the 15 activity
categories. All percentages are survey-weighted.

## Usage

``` r
day_types
```

## Format

A tibble with 8 rows and 12 columns:

- day_type:

  Name of the day type.

- tagline:

  One-line description.

- n_respondents:

  Number of survey days of this type (unweighted).

- share:

  Estimated percentage of all days of the year that are of this type.

- pct_weekend:

  Percentage of these days that fall on a weekend.

- mean_age:

  Average age of the people having this type of day.

- pct_female:

  Percentage of these days had by women.

- pct_employed:

  Percentage had by employed people.

- pct_student:

  Percentage had by students.

- pct_child_under_6:

  Percentage had by people whose youngest child in the household is
  under 6.

- pct_aged_65_plus:

  Percentage had by people aged 65 and over.

- match_cutoff:

  The same for every type: 95% of the real survey days are no more than
  this many hours apart from their closest type (see
  [`match_my_day()`](https://etc5523-2026.github.io/etc5523-assignment-4-tzhu0035-png/reference/match_my_day.md)).
  Used to decide whether a match is close.

## Source

Derived from
[atus_days](https://etc5523-2026.github.io/etc5523-assignment-4-tzhu0035-png/reference/atus_days.md).
Prepared in `data-raw/atus_days.R`.

## Details

Days vary continuously, so the types are useful summaries rather than
sharp categories.
[`vignette("dayalike")`](https://etc5523-2026.github.io/etc5523-assignment-4-tzhu0035-png/articles/dayalike.md)
checks how well a day keeps its type when the time spent on each
activity is slightly off.
