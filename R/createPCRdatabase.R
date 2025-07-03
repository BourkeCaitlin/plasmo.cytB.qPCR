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

  ctrl_names <- c("ext control", "EXT", "CTR", "ctr extrc", "Insta SN", "ctr ext", "water", "H2o", "H2O", "H20", "Pf ctr", "Pf CTR", "PF Ctr", "PF CTR", "h2o")

  screening <- list.files(here::here(paste0(sub_directory, "/", project, "/results/screening/spreadsheet")),full.names = T)
  species <- list.files(here::here(paste0(sub_directory, "/", project, "/results/",species_type,"/spreadsheet")), full.names = T)

 screening_results <- purrr::map(screening,readxl::read_excel) #read in all the files in the screening results
 species_results <- purrr::map(species,readxl::read_excel)#read in all the files in the species results



 species_results <- purrr::map(species_results, function(x) x %>%
              dplyr::filter(!x$sample_id%in%ctrl_names)) #removes the ctrl samples if present




 screening_results <- dplyr::bind_rows(screening_results) %>%
   dplyr::filter(!sample_id%in%ctrl_names) #bind the list to make one big dataset

 #use different method for species results because of species might be on different plates
if (length(species_results)<1) {
  print("there are no species results, results include just screening")

  merged <- screening_results
}else if (length(species_results)>=1) {
  ( species_results <- species_results%>%
      purrr::reduce(function(x, y) dplyr::full_join(x, y, by = c("sample_id"))))

  merged <- dplyr::full_join(screening_results, species_results, by = "sample_id")  #combine both screening and nested
  print("screening and species results are merged")

}



 ### write excel

 file_name <- paste0(Sys.Date(), "-", project, "-database-merged.xlsx")

 to_save <- merged %>%
   dplyr::select(sample_id, dplyr::contains("classification"), dplyr::everything())

 ## create classification_summary

 nested_summary = to_save %>%
   dplyr::select(sample_id, contains("class"), -contains("screen")) %>%
   tidyr::pivot_longer(-sample_id) %>%
   dplyr::mutate(name = stringr::str_sub(name, 16, 17)) %>%
   dplyr::filter(value=="positive") %>%
   dplyr::mutate(value = name) %>%
   tidyr::pivot_wider(names_from = name, values_from = value) %>%
   tidyr::unite(classification_summary, -1, sep = " & ") %>%
   dplyr::mutate(classification_summary = stringr::str_replace(classification_summary, " & NA|NA & ", ""))


 to_save <- to_save %>%
   dplyr::left_join(nested_summary) %>%
   dplyr::select(sample_id, classification_summary, contains("class"), everything()) %>%
   dplyr::mutate(classification_summary = dplyr::case_when(
     !is.na(classification_summary) ~ classification_summary,
     classification_screening=="positive" ~ "screening pos, need species",
     classification_screening=="negative" ~ "negative"
   )) %>%
   dplyr::mutate(classification_summary = dplyr::case_when(
     stringr::str_detect(classification_summary, "\\&") ~ paste0(classification_summary, " co-infection"),
     !stringr::str_detect(classification_summary, "neg") &!stringr::str_detect(classification_summary, "pos") ~ paste0(classification_summary, " infection"),
     T ~ classification_summary
   ))



 style_rounded = openxlsx::createStyle(numFmt="0,00")

 results <- openxlsx::createWorkbook()
 openxlsx::addWorksheet(results, "merged-database", gridLines = T)
 openxlsx::writeData(results, "merged-database", to_save)

 format_spp_pos <- openxlsx::createStyle(bgFill = "#BC2728")
 format_spp_neg <- openxlsx::createStyle(bgFill = "#BCD7FB")
 style_rounded = openxlsx::createStyle(numFmt="0.00")

 format_spp_pv<- openxlsx::createStyle(bgFill = "#f0de56")
 format_spp_copfpv<- openxlsx::createStyle(bgFill = "#FFA500")
 format_spp_pf<- openxlsx::createStyle(bgFill = "#f05b43")
 format_spp_screen<- openxlsx::createStyle(bgFill = "#c7a2b6")



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



 openxlsx::conditionalFormatting(results, "merged-database",
                                 1:ncol(to_save),
                                 rule = "pv",
                                 style = format_spp_pv,
                                 type = "contains",
                                 rows = 1:nrow(to_save)+1)

 openxlsx::conditionalFormatting(results, "merged-database",
                                 1:ncol(to_save),
                                 rule = "pf",
                                 style = format_spp_pf,
                                 type = "contains",
                                 rows = 1:nrow(to_save)+1)

 openxlsx::conditionalFormatting(results, "merged-database",
                                 1:ncol(to_save),
                                 rule = "co-infection",
                                 style = format_spp_copfpv,
                                 type = "contains",
                                 rows = 1:nrow(to_save)+1)

 openxlsx::conditionalFormatting(results, "merged-database",
                                 1:ncol(to_save),
                                 rule = "need",
                                 style = format_spp_screen,
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
