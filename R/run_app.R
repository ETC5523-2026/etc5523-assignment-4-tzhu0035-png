#' Launch the "Whose Day Is It?" Shiny app
#'
#' Opens the interactive app that ships with the package. Enter how you spent
#' a day, and the app finds the day types from the 2025 American Time Use
#' Survey that look most like it.
#'
#' @return Called for its side effect of launching the app.
#'
#' @importFrom shiny runApp
#' @export
#'
#' @examples
#' if (interactive()) {
#'   run_app()
#' }
run_app <- function() {
  app_dir <- system.file("app", package = "dayalike")
  runApp(app_dir, display.mode = "normal")
}
