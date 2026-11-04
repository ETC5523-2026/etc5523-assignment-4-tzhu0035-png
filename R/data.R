#' One day in the life of 6,146 Americans
#'
#' How each respondent to the 2025 American Time Use Survey (ATUS) spent the
#' 24 hours of their diary day, collapsed into 15 everyday activity
#' categories, together with a few characteristics of the respondent and the
#' day type the day was assigned to.
#'
#' Each row is one person's diary for one day (4am to 4am), so a "day type"
#' describes a day, not a person. Weekends are over-sampled in the ATUS: use
#' `weight` for any estimate about the population.
#'
#' @format A tibble with 6,146 rows and 25 columns:
#' \describe{
#'   \item{id}{ATUS case identifier (`TUCASEID`).}
#'   \item{weight}{ATUS final survey weight (`TUFINLWGT`).}
#'   \item{age}{Age in years (`TEAGE`; 80 to 84 recorded as 80, 85 and over
#'     as 85).}
#'   \item{sex}{Sex, `"Male"` or `"Female"` (`TESEX`).}
#'   \item{employed}{Is the respondent employed (`TELFS` 1 or 2)?}
#'   \item{student}{Is the respondent enrolled in high school, college or
#'     university (`TESCHENR`)? Only asked of people aged 15 to 49; others
#'     are `FALSE`.}
#'   \item{youngest_child_age}{Age of the youngest own child under 18 in the
#'     household (`TRYHHCHILD`); `NA` if none.}
#'   \item{weekend}{Was the diary day a Saturday or Sunday?}
#'   \item{sleep, personal_care, eating, work, education, housework, childcare,
#'     adult_care, shopping_services, socialising, screen, other_leisure,
#'     exercise, religious_volunteer, travel}{Minutes spent in each activity
#'     category; see [activity_categories].}
#'   \item{other}{Minutes that could not be coded (ATUS codes 50xxxx).}
#'   \item{day_type}{Day type the day was assigned to; see [day_types].}
#' }
#' The 15 activity columns plus `other` add up to 1,440 minutes for every row.
#'
#' @source U.S. Bureau of Labor Statistics, American Time Use Survey 2025,
#'   Activity Summary file, <https://www.bls.gov/tus/data/datafiles-2025.htm>.
#'   BLS data are in the public domain. Prepared in `data-raw/atus_days.R`.
"atus_days"

#' Eight types of day, and who has them
#'
#' A summary of the eight day types found by grouping the 2025 ATUS diary
#' days with survey-weighted k-means clustering on the 15 activity
#' categories. All percentages are survey-weighted.
#'
#' @format A tibble with 8 rows and 12 columns:
#' \describe{
#'   \item{day_type}{Name of the day type.}
#'   \item{tagline}{One-line description.}
#'   \item{n_respondents}{Number of survey days of this type (unweighted).}
#'   \item{share}{Estimated percentage of all days of the year that are of
#'     this type.}
#'   \item{pct_weekend}{Percentage of these days that fall on a weekend.}
#'   \item{mean_age}{Average age of the people having this type of day.}
#'   \item{pct_female}{Percentage of these days had by women.}
#'   \item{pct_employed}{Percentage had by employed people.}
#'   \item{pct_student}{Percentage had by students.}
#'   \item{pct_child_under_6}{Percentage had by people whose youngest child
#'     in the household is under 6.}
#'   \item{pct_aged_65_plus}{Percentage had by people aged 65 and over.}
#'   \item{match_cutoff}{The same for every type: 95% of the real survey
#'     days are no more than this many hours apart from their closest type
#'     (see [match_my_day()]). Used to decide whether a match is close.}
#' }
#'
#' @details Days vary continuously, so the types are useful summaries rather
#'   than sharp categories. `vignette("dayalike")` checks how well a day keeps
#'   its type when the time spent on each activity is slightly off.
#'
#' @source Derived from [atus_days]. Prepared in `data-raw/atus_days.R`.
"day_types"

#' The average day of each day type
#'
#' Survey-weighted average minutes spent in each activity category for each
#' of the eight day types. These are the profiles that [match_my_day()]
#' compares your day with.
#'
#' @format A tibble with 120 rows (8 day types x 15 categories) and 3
#'   columns:
#' \describe{
#'   \item{day_type}{Name of the day type.}
#'   \item{category}{Activity category; see [activity_categories].}
#'   \item{minutes}{Average minutes per day.}
#' }
#' @source Derived from [atus_days]. Prepared in `data-raw/atus_days.R`.
"day_type_profiles"

#' The 15 activity categories
#'
#' How the several hundred detailed ATUS activity codes were grouped into 15
#' everyday categories.
#'
#' @format A tibble with 15 rows and 3 columns:
#' \describe{
#'   \item{category}{Short name used in the data and functions.}
#'   \item{label}{Readable name used in the app.}
#'   \item{description}{What the category includes.}
#' }
#' @source Based on the ATUS 2025 Activity Coding Lexicon,
#'   <https://www.bls.gov/tus/lexicons/lexiconnoex2025.pdf>.
"activity_categories"
