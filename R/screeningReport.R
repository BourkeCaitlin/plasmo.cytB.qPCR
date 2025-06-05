#' Generate a report of the screening experiment
#'
#' @param project same as the project name you gave in setup
#' @param assay if generating screening results, this shoudl be "screening"
#' @param file_type ".pdf" or ".html" depending on the output file you want
#' @param sub_directory specify the name of the sub_directory you save your data in, if working within a subfolder
#' @param plate_folder the name of the folder where your two key data files are stored
#'
#' @return pdf or html file of results
#' @export screeningReport
#'
#' @examples \dontrun{screeningReport(sub_directory = "lab-molecular", project = "example",
#' assay = "screening", plate_folder = "plate1", file_type = ".pdf")}
screeningReport <- function(sub_directory, project, assay, plate_folder, file_type = ".pdf") {


  rmarkdown::render(input = system.file("extdata/screening_report.Rmd",
                                        package="plasmo.cytB.qPCR"),
                    output_file = paste0(Sys.Date(),
                                         "_screening_classification_",
                                         project, "-", plate_folder, file_type),
                    output_dir = paste0(here::here(),"/", sub_directory,"/", project,"/results/", assay, "/report/"),
                    params = list("sub_directory" = sub_directory,
                                  "project" = paste0(project),
                                  "assay" = paste0(assay),
                                  "plate_folder" = paste0(plate_folder)))
}
