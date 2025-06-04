#' Generate a report of the screening experiment
#'
#' @param project same as the project name you gave in setup
#' @param assay if generating screening results, this shoudl be "screening"
#' @param plaste_folder the name of the folder where your files are stored
#' @param file_type ".pdf" or ".html" depending on the output file you want
#'
#' @return pdf or html file of results
#' @export
#'
#' @examples \dontrun{screeningReport("example", "screening", "plate1", ".pdf")}
screeningReport <- function(project, assay, plate_folder, file_type = ".pdf") {


  rmarkdown::render(input = system.file("extdata/screening_report.Rmd",
                                        package="plasmo.cytB.qPCR"),
                    output_file = paste0(Sys.Date(),
                                         "_screening_classification_",
                                         project, "-", plate_folder, file_type),
                    output_dir = paste0(here::here(), "/results/", project, "/", assay, "/report/"),
                    params = list("project" = paste0(project),
                                  "assay" = paste0(assay),
                                  "plate_folder" = paste0(plate_folder)))
}
