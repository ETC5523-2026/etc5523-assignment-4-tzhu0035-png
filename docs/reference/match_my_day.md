# Find the day types that look most like your day

Compares one day of your time use with the average day of each of the
eight day types in
[day_type_profiles](https://etc5523-2026.github.io/etc5523-assignment-4-tzhu0035-png/reference/day_type_profiles.md),
and ranks the types from most to least similar.

## Usage

``` r
match_my_day(day)
```

## Arguments

- day:

  A named numeric vector of the hours spent in each activity category,
  e.g. `c(sleep = 8, work = 9)`. Names must come from
  `activity_categories$category`. Categories left out count as zero.

## Value

A tibble with one row per day type, from most to least similar, with
columns `rank`, `day_type`, `tagline`, `hours_apart` and `close_match`.

## Details

Similarity is measured in hours: `hours_apart` is the number of hours of
your day that would have to move from one activity to another for your
day to look exactly like the average day of a type. It is half the sum
of the absolute differences across the 15 activity categories. The type
with the fewest hours apart is your best match.

`close_match` is `TRUE` when `hours_apart` is no more than
`match_cutoff` in
[day_types](https://etc5523-2026.github.io/etc5523-assignment-4-tzhu0035-png/reference/day_types.md):
95% of the real survey days are at most that many hours from their
closest type. If even the best match is not a close match, your day is
unusual compared with the survey days.

## Examples

``` r
my_day <- c(sleep = 7.5, personal_care = 1, eating = 1, work = 9,
            housework = 1, screen = 2.5, travel = 1.5, exercise = 0.5)
match_my_day(my_day)
#> # A tibble: 8 × 5
#>    rank day_type      tagline                            hours_apart close_match
#>   <int> <fct>         <chr>                                    <dbl> <lgl>      
#> 1     1 Work day      Most of the day goes to paid work.        2.13 TRUE       
#> 2     2 On-the-go day Out and about: travel, errands an…        8.86 FALSE      
#> 3     3 Recharge day  A long sleep, well beyond the usu…        9.95 FALSE      
#> 4     4 Home day      Housework, cooking and looking af…       10.1  FALSE      
#> 5     5 Social day    Hours spent with friends, family …       10.1  FALSE      
#> 6     6 Hobby day     Time for reading, relaxing, music…       10.1  FALSE      
#> 7     7 Study day     Classes and study fill the day.          10.3  FALSE      
#> 8     8 Screen day    Long stretches of TV, gaming or c…       10.5  FALSE      
```
