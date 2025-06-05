#' Generate folder structure to save results
#'
#' @param project project name to use in folder structure
#' @param species_type either 'nested_species' or 'direct_species' depending on the type of species protocol to be use for the project
#' @param sub_directory if working within a folder at the root, specify this here. if not, leave blank
#'
#' @return folder structure at current working directory
#' @export startNewProject
#'
#' @examples
#' \dontrun{startNewProject(project = "example", sub_directory = "lab-molecular", species_type = "nested_species")}
#'
startNewProject <- function(project, sub_directory="", species_type) {
  dir.create(here::here(sub_directory), showWarnings = F)
  dir.create(here::here(paste0(sub_directory, "/", project, "/")), showWarnings = F)
  dir.create(here::here(paste0(sub_directory, "/", project, "/data/")), showWarnings = F)
  dir.create(here::here(paste0(sub_directory, "/", project, "/results/")), showWarnings = F)

  dir.create(here::here(paste0(sub_directory, "/", project, "/results/screening/")), showWarnings = F)
  dir.create(here::here(paste0(sub_directory, "/", project, "/data/screening/")), showWarnings = F)

  dir.create(here::here(paste0(sub_directory, "/", project, "/results/screening/report")), showWarnings = F)
  dir.create(here::here(paste0(sub_directory, "/", project, "/results/screening/spreadsheet")), showWarnings = F)

  if (species_type=="nested_species") {
    dir.create(here::here(paste0(sub_directory,"/", project, "/data/nested_species")),showWarnings = F)
    dir.create(here::here(paste0(sub_directory,"/", project, "/results/nested_species")),showWarnings = F)

    dir.create(here::here(paste0(sub_directory,"/", project, "/results/nested_species/report")),showWarnings = F)
    dir.create(here::here(paste0(sub_directory,"/", project, "/results/nested_species/spreadsheet")),showWarnings = F)

  }else if (species_type=="direct_species") {
    dir.create(here::here(paste0(sub_directory,"/", project, "/data/direct_species")),showWarnings = F)
    dir.create(here::here(paste0(sub_directory,"/", project, "/results/direct_species")),showWarnings = F)

    dir.create(here::here(paste0(sub_directory,"/", project, "/results/direct_species/report")),showWarnings = F)
    dir.create(here::here(paste0(sub_directory,"/", project, "/results/direct_species/spreadsheet")),showWarnings = F)
    }
  else if(!species_type%in%c("direct", "nested")){
    print("please specify either 'nested' or 'direct' according to project plans")
    }
}


