#' Specify file location
#'
#' @param project the name given during project setup (that is the same as within results or data)
#' @param assay is this screening, nested_species or direct_species
#' @param plate_folder what is the name of the folder where the results are saved
#' @param sub_directory are you working within a subdirectory at the root, if so, give it's name here, otherwise leave blank
#'
#' @return a vector with relative paths from R proj, first the plate map, second the Quantstudio export file
#' @export specifyFolder
#'
#' @examples
#' \dontrun{specifyFolder("example", "screening", "plate2-repeat")}


specifyFolder <- function(sub_directory, project, assay, plate_folder) {

  files <- list.files(here::here(paste0("/",sub_directory, "/data/", project, "/", assay, "/", plate_folder)))

  plate_map <- stringr::str_detect(files, "map")
  eds <- stringr::str_detect(files, "eds")
  quantstudio <- stringr::str_detect(files, ".xls") & stringr::str_detect(files, "map", negate = T)

  plate_map_file_name <-  files[plate_map]
  quantstudio_file_name <-  files[quantstudio]

  plate_map <- paste0(here::here(),"/",sub_directory,"/data/", project, "/", assay, "/", plate_folder, "/", files[plate_map])
  quantstudio <- paste0(here::here(),"/",sub_directory,"/data/", project, "/", assay, "/", plate_folder, "/", files[quantstudio])

  return(c(plate_map, quantstudio))
}

