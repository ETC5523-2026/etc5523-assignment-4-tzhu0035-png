# Compare your day with one day type, activity by activity

Shows how many more or fewer hours you spent in each activity category
than the average day of one day type. This explains why your day
matched, or did not match, a type in
[`match_my_day()`](https://etc5523-2026.github.io/etc5523-assignment-4-tzhu0035-png/reference/match_my_day.md).

## Usage

``` r
compare_day(day, type)
```

## Arguments

- day:

  A named numeric vector of the hours spent in each activity category,
  e.g. `c(sleep = 8, work = 9)`. Names must come from
  `activity_categories$category`. Categories left out count as zero.

- type:

  The day type to compare with, one of `day_types$day_type`.

## Value

A tibble with one row per activity category and columns `category`,
`label`, `you` and `typical` (hours) and `difference` (`you - typical`,
hours), from the largest to the smallest absolute difference.

## Examples

``` r
my_day <- c(sleep = 7.5, personal_care = 1, eating = 1, work = 9,
            housework = 1, screen = 2.5, travel = 1.5, exercise = 0.5)
compare_day(my_day, "Work day")
#> # A tibble: 15 × 5
#>    category            label                      you typical difference
#>    <chr>               <chr>                    <dbl>   <dbl>      <dbl>
#>  1 screen              TV, gaming & computer      2.5  1.64      0.862  
#>  2 sleep               Sleep                      7.5  8.07     -0.565  
#>  3 work                Work                       9    8.53      0.474  
#>  4 other_leisure       Other leisure              0    0.409    -0.409  
#>  5 travel              Travel                     1.5  1.09      0.406  
#>  6 socialising         Socialising                0    0.355    -0.355  
#>  7 childcare           Caring for children        0    0.291    -0.291  
#>  8 exercise            Sport & exercise           0.5  0.255     0.245  
#>  9 personal_care       Personal care              1    0.794     0.206  
#> 10 shopping_services   Shopping & errands         0    0.175    -0.175  
#> 11 education           Study                      0    0.0944   -0.0944 
#> 12 religious_volunteer Religious & volunteering   0    0.0804   -0.0804 
#> 13 housework           Housework & home           1    0.947     0.0529 
#> 14 adult_care          Caring for adults          0    0.0439   -0.0439 
#> 15 eating              Eating & drinking          1    1.01     -0.00889
```
