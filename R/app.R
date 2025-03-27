#' Launch Shiny App
#'
#' @param name The name of the app to run
#' @param ... arguments to pass to shiny::runApp
#'
#' @export
#'
app <- function(name = "app", ...) {
  baseDir <- system.file("apps", package = "ROCpower")

  if (baseDir == "") {
    stop("The 'apps' directory does not exist in the ROCpower package.")
  }

  appPath <- file.path(baseDir, "app.R")  # Directly point to app.R

  if (file.exists(appPath)) {
    shiny::runApp(appPath, ...)
  } else {
    stop("The shiny app does not exist in ROCpower")
  }
}
