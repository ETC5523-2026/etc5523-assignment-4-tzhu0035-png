library(dplyr)
library(tidyr)
library(readr)

atus_raw <- read_csv(
  "data-raw/atussum-2025.zip",
  col_types = cols(TUCASEID = col_character(), .default = col_double())
)

categorise_activity <- function(code) {
  tier1 <- substr(code, 1, 2)
  tier2 <- substr(code, 1, 4)
  case_when(
    tier2 == "0101" ~ "sleep",
    tier1 == "01" ~ "personal_care",
    tier1 == "11" ~ "eating",
    tier1 == "05" ~ "work",
    tier1 == "06" ~ "education",
    tier1 == "02" ~ "housework",
    tier2 %in% c("0301", "0302", "0303", "0401", "0402", "0403") ~ "childcare",
    tier1 %in% c("03", "04") ~ "adult_care",
    tier1 %in% c("07", "08", "09", "10") ~ "shopping_services",
    tier2 %in% c("1201", "1202") | tier1 == "16" ~ "socialising",
    code %in% c("120303", "120304", "120307", "120308") ~ "screen",
    tier1 == "12" ~ "other_leisure",
    tier1 == "13" ~ "exercise",
    tier1 %in% c("14", "15") ~ "religious_volunteer",
    tier1 == "18" ~ "travel",
    TRUE ~ "other"
  )
}

activity_categories <- tribble(
  ~category,             ~label,                       ~description,
  "sleep",               "Sleep",                      "Sleeping, including naps and sleeplessness.",
  "personal_care",       "Personal care",              "Washing, dressing, grooming, own health care and other personal activities.",
  "eating",              "Eating & drinking",          "Meals, snacks and drinks (not as part of work).",
  "work",                "Work",                       "Paid work and work-related activities, including job search.",
  "education",           "Study",                      "Attending classes, homework and research for a course.",
  "housework",           "Housework & home",           "Cleaning, laundry, cooking, home maintenance, gardening, pets and household management.",
  "childcare",           "Caring for children",        "Caring for and helping children, in or outside the household.",
  "adult_care",          "Caring for adults",          "Caring for and helping adults, in or outside the household.",
  "shopping_services",   "Shopping & errands",         "Shopping and using professional, household and government services.",
  "socialising",         "Socialising",                "Spending time with others in person, attending social events and phone calls.",
  "screen",              "TV, gaming & computer",      "Watching TV or movies, playing games and using a computer for leisure.",
  "other_leisure",       "Other leisure",              "Relaxing, reading, music, hobbies, arts and entertainment outside the home.",
  "exercise",            "Sport & exercise",           "Playing sports, exercising and attending sporting events.",
  "religious_volunteer", "Religious & volunteering",   "Religious and spiritual activities and volunteering.",
  "travel",              "Travel",                     "Travel and commuting for any purpose."
)

atus_minutes <- atus_raw |>
  select(TUCASEID, starts_with("t", ignore.case = FALSE)) |>
  pivot_longer(-TUCASEID, names_to = "code", values_to = "minutes") |>
  mutate(category = categorise_activity(substr(code, 2, 7))) |>
  group_by(TUCASEID, category) |>
  summarise(minutes = sum(minutes), .groups = "drop") |>
  pivot_wider(names_from = category, values_from = minutes)

atus_days <- atus_raw |>
  transmute(
    id = TUCASEID,
    weight = TUFINLWGT,
    age = TEAGE,
    sex = factor(TESEX, 1:2, c("Male", "Female")),
    employed = TELFS %in% c(1, 2),
    student = TESCHENR == 1,
    youngest_child_age = if_else(TRYHHCHILD < 0, NA_real_, TRYHHCHILD),
    weekend = TUDIARYDAY %in% c(1, 7)
  ) |>
  left_join(atus_minutes, by = c("id" = "TUCASEID")) |>
  relocate(all_of(activity_categories$category), other, .after = weekend)

weighted_kmeans <- function(x, w, k, n_start = 50, max_iter = 100) {
  best <- NULL
  for (s in 1:n_start) {
    centres <- x[sample(nrow(x), k), , drop = FALSE]
    for (i in 1:max_iter) {
      d <- matrix(0, nrow = nrow(x), ncol = k)
      for (j in 1:k) {
        d[, j] <- colSums((t(x) - centres[j, ])^2)
      }
      cluster <- max.col(-d, ties.method = "first")
      new_centres <- centres
      for (j in 1:k) {
        in_j <- cluster == j
        if (any(in_j)) {
          new_centres[j, ] <- colSums(x[in_j, , drop = FALSE] * w[in_j]) /
            sum(w[in_j])
        }
      }
      if (max(abs(new_centres - centres)) < 1e-6) break
      centres <- new_centres
    }
    wss <- sum(w * d[cbind(1:nrow(x), cluster)])
    if (is.null(best) || wss < best$wss) {
      best <- list(cluster = cluster, centres = centres, wss = wss)
    }
  }
  best
}

features <- activity_categories$category
x <- as.matrix(atus_days[features])

set.seed(5523)
fit <- weighted_kmeans(x, atus_days$weight, k = 8)

overall <- colSums(x * atus_days$weight) / sum(atus_days$weight)
signature <- c()
for (j in 1:8) {
  signature[j] <- features[which.max(fit$centres[j, ] - overall)]
}

type_names <- c(
  work = "Work day",
  screen = "Screen day",
  housework = "Home day",
  sleep = "Recharge day",
  other_leisure = "Hobby day",
  socialising = "Social day",
  education = "Study day",
  travel = "On-the-go day",
  childcare = "On-the-go day",
  shopping_services = "On-the-go day"
)

type_levels <- c(
  "Work day", "Study day", "On-the-go day", "Home day",
  "Screen day", "Hobby day", "Social day", "Recharge day"
)
atus_days$day_type <- factor(unname(type_names[signature])[fit$cluster],
                             levels = type_levels)

day_type_profiles <- atus_days |>
  pivot_longer(all_of(features), names_to = "category", values_to = "minutes") |>
  group_by(day_type, category) |>
  summarise(minutes = weighted.mean(minutes, weight), .groups = "drop") |>
  arrange(day_type, match(category, features))

hours_to_closest_type <- atus_days |>
  select(id, weight, all_of(features)) |>
  pivot_longer(all_of(features), names_to = "category", values_to = "you") |>
  left_join(day_type_profiles, by = "category",
            relationship = "many-to-many") |>
  group_by(id, weight, day_type) |>
  summarise(hours_apart = sum(abs(you - minutes)) / 2 / 60, .groups = "drop") |>
  group_by(id, weight) |>
  summarise(hours_apart = min(hours_apart), .groups = "drop")

match_cutoff <- hours_to_closest_type |>
  arrange(hours_apart) |>
  mutate(share_of_days = cumsum(weight) / sum(weight)) |>
  filter(share_of_days >= 0.95) |>
  slice(1) |>
  pull(hours_apart)

taglines <- c(
  "Work day"      = "Most of the day goes to paid work.",
  "Study day"     = "Classes and study fill the day.",
  "On-the-go day" = "Out and about: travel, errands and caring for others.",
  "Home day"      = "Housework, cooking and looking after the home.",
  "Screen day"    = "Long stretches of TV, gaming or computer time.",
  "Hobby day"     = "Time for reading, relaxing, music and hobbies.",
  "Social day"    = "Hours spent with friends, family or at social events.",
  "Recharge day"  = "A long sleep, well beyond the usual."
)

day_types <- atus_days |>
  group_by(day_type) |>
  summarise(
    n_respondents = n(),
    share = sum(weight),
    pct_weekend = weighted.mean(weekend, weight) * 100,
    mean_age = weighted.mean(age, weight),
    pct_female = weighted.mean(sex == "Female", weight) * 100,
    pct_employed = weighted.mean(employed, weight) * 100,
    pct_student = weighted.mean(student, weight) * 100,
    pct_child_under_6 = weighted.mean(
      !is.na(youngest_child_age) & youngest_child_age < 6, weight
    ) * 100,
    pct_aged_65_plus = weighted.mean(age >= 65, weight) * 100,
    match_cutoff = match_cutoff
  ) |>
  mutate(
    share = share / sum(share) * 100,
    tagline = unname(taglines[as.character(day_type)]),
    .after = day_type
  )

usethis::use_data(atus_days, day_types, day_type_profiles, activity_categories,
                  overwrite = TRUE)
