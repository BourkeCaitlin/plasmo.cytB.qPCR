#' Create report for nested species PCR
#'
#' @param sub_directory subdirectory you are working within
#' @param project name of the project
#' @param assay if nested PCR you should specify "nested_species"
#' @param plate_folder the name of the folder where you are storing your data
#' @param file_type specify either ".html" or ".pdf" according to what output format you would like
#'
#' @return a pdf and excel spreadsheet saved in results folder
#' @export nestedSpeciesReport
#'
#' @examples
#' \dontrun{nestedSpeciesReport(sub_directory = "lab-molecular",project = "project_name",  assay = "nested_species", plate_folder ="example-nestedspecies-plate1", file_type = ".pdf" )}

nestedSpeciesReport <- function(sub_directory, project, assay = "nested_species", plate_folder, file_type = ".pdf") {


suppressWarnings(rmarkdown::render(input = system.file("extdata/nested_species_report.Rmd",
                                        package="plasmo.cytB.qPCR"),
                    output_file = paste0(Sys.Date(),
                                         "_nestedspecies_classification_",
                                         project, "-", plate_folder, file_type),
                    output_dir = paste0(here::here(),"/", sub_directory,"/", project,"/results/", assay, "/report/"),
                    params = list("sub_directory" = sub_directory,
                                  "project" = paste0(project),
                                  "assay" = paste0(assay),
                                  "plate_folder" = paste0(plate_folder))))

  return(print("check the results/nested_species folder to find the results !"))
}
