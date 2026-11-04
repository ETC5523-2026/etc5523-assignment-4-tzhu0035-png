#' Find the day types that look most like your day
#'
#' Compares one day of your time use with the average day of each of the
#' eight day types in [day_type_profiles], and ranks the types from most to
#' least similar.
#'
#' Similarity is measured in hours: `hours_apart` is the number of hours of
#' your day that would have to move from one activity to another for your
#' day to look exactly like the average day of a type. It is half the sum of
#' the absolute differences across the 15 activity categories. The type with
#' the fewest hours apart is your best match.
#'
#' `close_match` is `TRUE` when `hours_apart` is no more than
#' `match_cutoff` in [day_types]: 95% of the real survey days are at most
#' that many hours from their closest type. If even the best match is not a
#' close match, your day is unusual compared with the survey days.
#'
#' @param day A named numeric vector of the hours spent in each activity
#'   category, e.g. `c(sleep = 8, work = 9)`. Names must come from
#'   `activity_categories$category`. Categories left out count as zero.
#'
#' @return A tibble with one row per day type, from most to least similar,
#'   with columns `rank`, `day_type`, `tagline`, `hours_apart` and
#'   `close_match`.
#'
#' @importFrom dplyr left_join group_by summarise select mutate arrange
#'   row_number
#' @export
#'
#' @examples
#' my_day <- c(sleep = 7.5, personal_care = 1, eating = 1, work = 9,
#'             housework = 1, screen = 2.5, travel = 1.5, exercise = 0.5)
#' match_my_day(my_day)
match_my_day <- function(day) {
  dayalike::day_type_profiles |>
    left_join(day_as_table(day), by = "category") |>
    group_by(day_type) |>
    summarise(hours_apart = sum(abs(you - minutes)) / 2 / 60) |>
    left_join(select(dayalike::day_types, day_type, tagline, match_cutoff),
              by = "day_type") |>
    mutate(close_match = hours_apart <= match_cutoff) |>
    arrange(hours_apart) |>
    mutate(rank = row_number()) |>
    select(rank, day_type, tagline, hours_apart, close_match)
}

#' Compare your day with one day type, activity by activity
#'
#' Shows how many more or fewer hours you spent in each activity category
#' than the average day of one day type. This explains why your day matched,
#' or did not match, a type in [match_my_day()].
#'
#' @param day A named numeric vector of the hours spent in each activity
#'   category, e.g. `c(sleep = 8, work = 9)`. Names must come from
#'   `activity_categories$category`. Categories left out count as zero.
#' @param type The day type to compare with, one of `day_types$day_type`.
#'
#' @return A tibble with one row per activity category and columns
#'   `category`, `label`, `you` and `typical` (hours) and `difference`
#'   (`you - typical`, hours), from the largest to the smallest absolute
#'   difference.
#'
#' @importFrom dplyr filter left_join select transmute arrange desc
#' @export
#'
#' @examples
#' my_day <- c(sleep = 7.5, personal_care = 1, eating = 1, work = 9,
#'             housework = 1, screen = 2.5, travel = 1.5, exercise = 0.5)
#' compare_day(my_day, "Work day")
compare_day <- function(day, type) {
  if (!type %in% levels(dayalike::day_types$day_type)) {
    stop("`type` must be one of: ",
         paste(levels(dayalike::day_types$day_type), collapse = ", "))
  }

  dayalike::day_type_profiles |>
    filter(day_type == type) |>
    left_join(day_as_table(day), by = "category") |>
    left_join(select(dayalike::activity_categories, category, label),
              by = "category") |>
    transmute(
      category,
      label,
      you = you / 60,
      typical = minutes / 60,
      difference = you - typical
    ) |>
    arrange(desc(abs(difference)))
}

#' @importFrom dplyr left_join mutate if_else
#' @importFrom tibble tibble
day_as_table <- function(day) {
  if (is.null(names(day)) ||
      !all(names(day) %in% dayalike::activity_categories$category)) {
    stop("`day` must be named with categories from ",
         "`activity_categories$category`, e.g. c(sleep = 8, work = 9).")
  }
  if (any(day < 0)) {
    stop("Hours spent cannot be negative.")
  }
  if (sum(day) == 0) {
    stop("Enter the hours spent on at least one activity.")
  }
  if (sum(day) > 24) {
    stop("Your day adds up to ", sum(day), " hours, but a day has only 24.")
  }

  your_day <- tibble(category = names(day), you = as.numeric(day) * 60)

  tibble(category = dayalike::activity_categories$category) |>
    left_join(your_day, by = "category") |>
    mutate(you = if_else(is.na(you), 0, you))
}
