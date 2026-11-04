# The average day of each day type

Survey-weighted average minutes spent in each activity category for each
of the eight day types. These are the profiles that
[`match_my_day()`](https://etc5523-2026.github.io/etc5523-assignment-4-tzhu0035-png/reference/match_my_day.md)
compares your day with.

## Usage

``` r
day_type_profiles
```

## Format

A tibble with 120 rows (8 day types x 15 categories) and 3 columns:

- day_type:

  Name of the day type.

- category:

  Activity category; see
  [activity_categories](https://etc5523-2026.github.io/etc5523-assignment-4-tzhu0035-png/reference/activity_categories.md).

- minutes:

  Average minutes per day.

## Source

Derived from
[atus_days](https://etc5523-2026.github.io/etc5523-assignment-4-tzhu0035-png/reference/atus_days.md).
Prepared in `data-raw/atus_days.R`.
