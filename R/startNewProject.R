#' Generate folder structure to save results
#'
#' @param project_name project name to use in folder structure
#' @param species_type either 'nested' or 'direct' depending on the type of species protocol to be use for the project
#'
#' @return folder structure at current working directory
#' @export
#'
#' @examples
#' \dontrun{startNewProject("STATEM", "nested")}
#'
startNewProject <- function(project_name, species_type) {
  dir.create(here::here("results"),showWarnings = F)
  dir.create(here::here(paste0("results/", name)),showWarnings = F)

  dir.create(here::here("data"),showWarnings = F)
  dir.create(here::here(paste0("data/", name)),showWarnings = F)

  dir.create(here::here(paste0("results/", name, "/screening")),showWarnings = F)
  dir.create(here::here(paste0("data/", name, "/screening")),showWarnings = F)

  dir.create(here::here(paste0("results/", name, "/screening/report")),showWarnings = F)
  dir.create(here::here(paste0("results/", name, "/screening/spreadsheet")),showWarnings = F)

  if (species_type=="nested") {
    dir.create(here::here(paste0("results/", name, "/nested_species")),showWarnings = F)
    dir.create(here::here(paste0("data/", name, "/nested_species")),showWarnings = F)

    dir.create(here::here(paste0("results/", name, "/nested_species/report")),showWarnings = F)
    dir.create(here::here(paste0("results/", name, "/nested_species/spreadsheet")),showWarnings = F)
  }else if (species_type=="direct") {
      dir.create(here::here(paste0("results/", name, "/direct_species")),showWarnings = F)
    dir.create(here::here(paste0("data/", name, "/direct_species")),showWarnings = F)

      dir.create(here::here(paste0("results/", name, "/direct_species/report")),showWarnings = F)
      dir.create(here::here(paste0("results/", name, "/direct_species/spreadsheet")),showWarnings = F)
    }
  else if(!species_type%in%c("direct", "nested")){
    print("please specify either 'nested' or 'direct' according to project plans")
    }
}


