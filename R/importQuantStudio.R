#' import files for QuantStudio
#'
#' @param INPUT_PLATELAYOUT an excel file in plate layout format
#' @param INPUT_QUANTSTUDIO the excel file exported from the quantstudio
#'
#' @return a list
#' @export importQuantStudio
#' @importFrom rlang .data
#'
#' @examples
#' \dontrun{importQuantStudio(INPUT_PLATELAYOUT = INPUT_PLATELAYOUT, INPUT_QUANTSTUDIO = INPUT_QUANTSTUDIO)}

importQuantStudio <- function(INPUT_PLATELAYOUT, INPUT_QUANTSTUDIO) {

  #import file and pivot longer on first column - record sample_ids in column `sample_id`
  plate_layout <-  readxl::read_excel(INPUT_PLATELAYOUT,
                                      col_names = T,
                                      col_types = c("text"),
                                      sheet = "map") %>%
    tidyr::pivot_longer(-1, names_to = "col", values_to = "sample_id")
  # add a column that is the name of the plate- as is written in the top corner of the excel file
  plate_layout <- plate_layout %>%
    dplyr::mutate(plate_name = colnames(plate_layout[1]))
  # make a new variable representing well - paste row and col together
  #now call column 1 name "row"
  colnames(plate_layout)[1] <- "row"
  plate_layout <-plate_layout %>%
    dplyr::mutate(well_position = paste0(row, col))
  plate_layout <- plate_layout %>%
    dplyr::mutate(class_sample = dplyr::case_when(
      .data$sample_id%in%c("ext control", "EXT", "CTR", "ctr extrc", "Insta SN", "ctr ext") ~ "negative extraction control",
      .data$sample_id%in%c("h2o", "water", "H2O", "H20") ~ "pcr water control",
      .data$sample_id%in%c("pf ctr", "ctr pf", "CTR Positif", "PF CTR", "Pf ctr") ~"positive extraction control",
      TRUE ~"samples"
    )) %>%
    dplyr::mutate(class_sample2 = dplyr::case_when(
      stringr::str_detect(class_sample, "control") ~ "control",
      TRUE ~"samples"
    ))
  #read in the file that is the export raw file from quantstudio
  quantstudio_results <- readxl::read_excel(INPUT_QUANTSTUDIO,
                                            sheet = "Results",
                                            col_names = F)
  skip_for_well <- which(quantstudio_results[,1]=="Well")
  experiment_date <- which(quantstudio_results[,1]=="Date Created")
  user <- which(quantstudio_results[,1]=="User Name")
  experiment_date <- quantstudio_results[experiment_date,2]
  user <- quantstudio_results[user,2]
  # re-read in the excel file but skipping the `skip_for_well` -1 to skip the header info
  quantstudio_results <- readxl::read_excel(INPUT_QUANTSTUDIO,
                                            sheet = "Results",
                                            col_names = T,
                                            skip = skip_for_well-1,
                                            na = "Undetermined") %>%
    janitor::clean_names() %>%
    dplyr::left_join(plate_layout) %>%
    tidyr::drop_na(.data$sample_id)

  quantstudio_melt_raw <- readxl::read_excel(INPUT_QUANTSTUDIO,
                                             sheet = "Melt Curve Raw Data",
                                             col_names = T,
                                             skip = skip_for_well-1) %>%
    janitor::clean_names() %>%
    dplyr::left_join(plate_layout) %>%
    tidyr::drop_na(sample_id)
  quantstudio_ampcurve <- readxl::read_excel(INPUT_QUANTSTUDIO,
                                             sheet = "Amplification Data",
                                             skip= skip_for_well-1) %>%
    janitor::clean_names() %>%
    dplyr::left_join(plate_layout) %>%
    tidyr::drop_na(.data$sample_id)
  QuantStudioList <- list(quantstudio_results, quantstudio_melt_raw, quantstudio_ampcurve, experiment_date, user)
  return(QuantStudioList)
}
