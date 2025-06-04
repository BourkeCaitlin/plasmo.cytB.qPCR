#' ---
#' title: Plasmodium Screening: Run Summary
#' header-includes:
#'- \usepackage[default]{sourcesanspro}
#'- \usepackage[T1]{fontenc}
#' output:
#'   pdf_document: default
#'     classoption: landscape
#' ---

#+ setup, include=FALSE
knitr::opts_chunk$set(echo = FALSE, fig.width=12, fig.height=7, warning = F)

data <- classifyScreening(project = project, plate_folder = plate_folder)




#+ plate map
data[[4]]


#+ melt temperatures 1
data[[1]]


#+ melt temperatures 2
data[[2]]


#+ amplification curve
data[[3]]


