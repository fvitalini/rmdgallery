gallery_div <- function(class, content) {
  if (!is.null(content)) {
    htmltools::div(
      class = class,
      if (is.character(content)) {
        htmltools::HTML(content)
      } else {
        content
      }
    )
  }
}


#' Gallery page content
#'
#' Create the content of a gallery page, comprising three `<div>` elements: one
#' initial wrapping around `before`, one main comprising the arbitrary
#' `htmltools::tagList(...)`, and one final wrapping around `after`. The three
#' elements have custom classes `"gallery-before"`, `"gallery-main"`,
#' `"gallery-after"`, and are wrapped in a parent `<div>` with class
#' `"gallery-container"` class plus the provided custom `class`.
#'
#' @param ... Unnamed items included in the main `<div>`
#' @param before,after The content of the `<div>` before and after
#'   the main. If character, the value is wrapped inside [htmltools::HTML()].
#' @param class Character vector of custom classes.
#'
#'
#' @inherit htmltools::tagList return
#'
#' @export
gallery_content <- function(..., before = NULL, after = NULL, class = NULL) {
  htmltools::div(
    class = paste(c("gallery-container", class), collapse = " "),
    gallery_div(
      class = "gallery-before",
      before
    ),
    gallery_div(
      class = "gallery-main",
      htmltools::tagList(...)
    ),
    gallery_div(
      class = "gallery-after",
      after
    )
  )
}


fill <- function(with, x) {
  y <- glue::glue_data(
    with,
    x,
    .open = "{{", .close = "}}"
  )
  class(y) <- class(x)
  y
}

fill_template <- function(meta, template) {
  if (length(meta$gallery$include_before) > 0L) {
    meta$gallery$include_before <- fill(meta, meta$gallery$include_before)
  }
  if (length(meta$gallery$include_after) > 0L) {
    meta$gallery$include_after <- fill(meta, meta$gallery$include_after)
  }
  filled <- fill(meta, paste(template, collapse = "\n"))
  knit_params <- names(knitr::knit_params(filled, evaluate = FALSE))
  attr(filled, "params") <- meta[names(meta) %in% knit_params]
  filled
}

find_template <- function(template, paths = character(0)) {
  paths = c(system.file("templates", package = "rmdgallery"), paths)
  basename <- sprintf("%s.Rmd", template)
  template_file <- NULL
  for (path in paths) {
    if (file.exists(file.path(path, basename))) {
      template_file <- file.path(path, basename)
    }
  }
  if (is.null(template_file)) {
    stop("No template found for ", sQuote(template), " in ", toString(sQuote(paths)))
  }
  template_file
}

from_template <- function(meta, paths = character(0)) {
  template <- find_template(meta$template, paths)
  fill_template(meta, readLines(template))
}
