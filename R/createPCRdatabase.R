#' Create one database of all the results generated so far and stored in the respective results folders
#'
#' @param sub_directory name of sub_directory folder relative to RProj
#' @param project project name
#' @param species_type have the results been generated with nested or direct species
#'
#' @return an excel spreadsheet stored in the merged_database folder
#' @export createPCRdatabase
#'
#' @examples \dontrun{createPCRdatabase(sub_directory = "lab-molecular", project = "test_project", species_type = "nested_species")}
createPCRdatabase <- function(sub_directory, project, species_type) {

  ctrl_names <- c("ext control", "EXT", "CTR", "ctr extrc", "Insta SN", "ctr ext", "water", "H2o", "H2O", "H20", "Pf ctr", "Pf CTR", "PF Ctr", "PF CTR")

  screening <- list.files(here::here(paste0(sub_directory, "/", project, "/results/screening/spreadsheet")),full.names = T)
  species <- list.files(here::here(paste0(sub_directory, "/", project, "/results/",species_type,"/spreadsheet")), full.names = T)

 screening_results <- purrr::map(screening,readxl::read_excel) #read in all the files in the screening results
 species_results <- purrr::map(species,readxl::read_excel)#read in all the files in the species results

 screening_results <- dplyr::bind_rows(screening_results) %>%
   dplyr::filter(!sample_id%in%ctrl_names) #bind the list to make one big dataset
 species_results <- dplyr::bind_rows(species_results)%>%
   dplyr::filter(!sample_id%in%ctrl_names)#bind the list to make one big dataset

 merged <- dplyr::full_join(screening_results, species_results, by = "sample_id")  #combine both screening and nested


 ### write excel

 file_name <- paste0(Sys.Date(), "-", project, "-database-merged.xlsx")

 to_save <- merged %>%
   dplyr::select(sample_id, dplyr::contains("classification"), dplyr::everything())

 style_rounded = openxlsx::createStyle(numFmt="0,00")

 results <- openxlsx::createWorkbook()
 openxlsx::addWorksheet(results, "merged-database", gridLines = T)
 openxlsx::writeData(results, "merged-database", to_save)

 format_spp_pos <- openxlsx::createStyle(bgFill = "#BC2728")
 format_spp_neg <- openxlsx::createStyle(bgFill = "#BCD7FB")
 style_rounded = openxlsx::createStyle(numFmt="0.00")


 openxlsx::conditionalFormatting(results, "merged-database", 1:ncol(to_save),
                                 rule = "positive",
                                 style = format_spp_pos,
                                 type = "contains",
                                 rows = 1:nrow(to_save)+1)


 openxlsx::conditionalFormatting(results, "merged-database",
                                 1:ncol(to_save),
                                 rule = "negative",
                                 style = format_spp_neg,
                                 type = "contains",
                                 rows = 1:nrow(to_save)+1)

 # openxlsx::addStyle(results, "merged-database", style_rounded, rows = 1:nrow(to_save)+1, cols = 4)
 # openxlsx::addStyle(results, "merged-database", style_rounded, rows = 1:nrow(to_save)+1, cols = 5)
 # openxlsx::addStyle(results, "merged-database", style_rounded, rows = 1:nrow(to_save)+1, cols = 6)
 # openxlsx::addStyle(results, "merged-database", style_rounded, rows = 1:nrow(to_save)+1, cols = 7)


 openxlsx::writeDataTable(results, "merged-database", to_save, startRow = 1, startCol = 1, tableStyle = "TableStyleLight9")


suppressWarnings( width_vec <- apply(to_save, 2, function(x) max(nchar(as.character(x)) + 2, na.rm = TRUE)))

 dth_vec_header <- nchar(colnames(to_save))  + 2

 width_vec <- dplyr::bind_cols(text = width_vec, header = dth_vec_header) %>%
   dplyr::mutate(col_no = paste0("col", 1:length((to_save)))) %>%
   tidyr::pivot_longer(-col_no) %>%
   dplyr::mutate(value = dplyr::case_when(
     value==Inf ~0,
     TRUE~value))  %>%
   dplyr::group_by(col_no) %>%
   dplyr::filter(value == max(value)) %>%
   dplyr::ungroup() %>%
   dplyr::select(col_no, value) %>%
   dplyr::distinct()
 #
 openxlsx::setColWidths(results, "merged-database", cols = 1:ncol(to_save), widths = width_vec$value)


 dir.create(here::here(sub_directory, "/", project, "/results/merged_database"),showWarnings = F)
 openxlsx::saveWorkbook(results,
                        file = here::here(sub_directory, "/",
                                          project,
                                          "results/merged_database", file_name), overwrite = T )
}
