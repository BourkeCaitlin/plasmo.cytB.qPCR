#' Classify screening results
#'
#' @param project the name given during project setup (that is the same as within results or data)
#' @param assay is this screening, nested_species or direct_species
#' @param plate_folder what is the name of the folder where the results are saved
#'
#' @return a list of results to be accessed to find plots, data etc
#' @export
#'
#' @examples
#'

classifyScreening <- function(project, assay = "screening", plate_folder) {
  temperature_range_screening <- c(76.5, 80.5)

  QuantStudioData <- importQuantStudio(INPUT_PLATELAYOUT = specifyFolder(project, assay, plate_folder)[1],
                                       INPUT_QUANTSTUDIO = specifyFolder(project, assay, plate_folder)[2])

  max_melt <- QuantStudioData[[2]] %>%
      dplyr::filter((temperature>temperature_range_screening[1]   & temperature< temperature_range_screening[2])) %>%
      dplyr::group_by(well_position) %>%
      dplyr::filter(derivative==max(derivative)) %>%
      dplyr::select(well_position, derivative_max = derivative, temperature_max = temperature) %>%
      dplyr::distinct()


  QuantStudioData[[1]] <- QuantStudioData[[1]] %>%
    dplyr::left_join(max_melt)



  ######################
  ##### define positive samples

  QuantStudioData[[1]] <- QuantStudioData[[1]] %>%
    dplyr::mutate(classification = dplyr::case_when(
      !is.na(ct) & derivative_max>15000 & tm1>temperature_range_screening[1] & tm1<temperature_range_screening[2]  ~ "positive",
      TRUE ~"negative")) %>%
    dplyr::mutate(classification = factor(classification,
                                   levels = c("positive",  "negative"))) %>%
    dplyr::mutate(class_ct = dplyr::case_when(
      ct<27 ~ "ct < 27",
      ct>=27 & ct<35 ~ "27 <=ct< 35",
      ct > 35 ~ "ct >= 35",
      TRUE~"no ct"
    )) %>%
    dplyr::mutate(class_ct= factor(class_ct,
                                   levels= c("ct < 27","27 <=ct< 35","ct >= 35",  "no ct" ))) %>%
    dplyr::mutate(classification_bind = dplyr::case_when(
      class_sample2=="control"~ paste0(classification, "-", class_sample2),
      TRUE ~classification
    )) %>%
    dplyr::mutate(classification_bind = factor(classification_bind,
                                        levels = c("positive", "negative", "negative-control", "positive-control")))  %>%
    dplyr::mutate(color_plot = dplyr::case_when(
      class_sample=="negative extraction control" & classification == "negative" ~"good control",
      class_sample=="pcr water control" & classification == "negative" ~"good control",
      class_sample=="positive extraction control" & classification == "positive" ~"good control",
      class_sample=="negative extraction control" & classification == "positive" ~"bad control",
      class_sample=="pcr water control" & classification == "positive" ~"bad control",
      class_sample=="positive extraction control" & classification == "negative" ~"bad control",
      TRUE ~classification
    ))%>%
    dplyr::mutate(color_plot = factor(color_plot,
                               levels = c("positive", "negative", "good control", "bad control")))

  QuantStudioData[[1]] %>% dplyr::select(color_plot, everything())


  ##### summary plots

  ########################
  # define colours

  ct_colours <- c("ct < 27"= "#1A4327", "27 <=ct< 35"=  "#95c36e","ct >= 35"= "#9E5590", "no ct"= "grey") %>%
    tibble::as_tibble(rownames = "ct_cat")
  colour_named_ct <- ct_colours$value
  names(colour_named_ct) <- ct_colours$ct_cat

  cat_colours <- c("positive"= "#BC2728","negative"= "#BCD7FB") %>%
    tibble::as_tibble(rownames = "classification")
  colour_named_classification <- cat_colours$value
  names(colour_named_classification) <- cat_colours$classification


  cat_colours_control <- c("positive"= "#BC2728","negative"= "#BCD7FB", "good control" = "#F2C12E", "bad control" = "#FF7A48") %>%
    tibble::as_tibble(rownames = "classification")
  colour_named_classification_control <- cat_colours_control$value
  names(colour_named_classification_control) <- cat_colours_control$classification


  ##############################
  ###### melt plots

  all_melt_temps <- QuantStudioData[[2]] %>%
    dplyr::left_join(QuantStudioData[[1]])


  melt_plot_all <- all_melt_temps %>%
    ggplot2::ggplot(ggplot2::aes(x = temperature, y = derivative))+
    ggplot2::geom_line(ggplot2::aes(group = well_position,
                  colour = color_plot),
              alpha = 0.7, size = 0.85)+
    ggplot2::scale_y_continuous(labels = scales::comma)+
    ggplot2::scale_colour_manual(values = colour_named_classification_control)+
    ggplot2::theme_minimal()+
    ggplot2::scale_y_continuous(labels = scales::comma)+
    ggplot2::labs(title = paste0("Melt temperature: qPCR screening"), colour = "")



  ###########################################################################
  ## melt plots 2

  melt_plot_split <- all_melt_temps %>%
    ggplot2::ggplot(ggplot2::aes(x = temperature, y = derivative))+
    ggplot2::geom_line(data = dplyr::filter(all_melt_temps, class_ct=="ct < 27"), ggplot2::aes(group = well_position, colour = class_ct), alpha = 0.7, size = 0.85)+
    ggplot2::geom_line(data = dplyr::filter(all_melt_temps, class_ct=="27 <=ct< 35"), ggplot2::aes(group = well_position, colour = class_ct), alpha = 0.7, size = 0.85)+
    ggplot2::geom_line(data = dplyr::filter(all_melt_temps, class_ct=="ct >= 35"), ggplot2::aes( group = well_position, colour = class_ct), alpha = 0.9, size = 0.85)+
    ggplot2::geom_line(data = dplyr::filter(all_melt_temps, class_ct=="no ct"), ggplot2::aes(group = well_position, colour = class_ct), alpha = 0.7, size = 0.85)+
    ggplot2::facet_wrap(~color_plot, ncol = 2)+
    ggplot2::theme_minimal()+
    ggplot2::scale_colour_manual(values = colour_named_ct, breaks = c("ct < 27", "27 <=ct< 35", "ct >= 35", "no ct"))+
    ggplot2::scale_y_continuous(labels = scales::comma)+
    ggplot2::labs(title = paste0("Melt temperature: qPCR screening"), colour = "")



  ###########################################################################

  ## amplification plot 1

  amplification_plots <- QuantStudioData[[3]] %>%
    dplyr::left_join(QuantStudioData[[1]]) %>%
    ggplot2::ggplot(ggplot2::aes(x = cycle, y = rn))+
    ggplot2::geom_line(ggplot2::aes(group = well_position, colour = color_plot))+
    ggplot2::scale_colour_manual(values = colour_named_classification_control)+
    ggplot2::theme_minimal()+
    ggplot2::facet_wrap(~classification, ncol = 2)+
    ggplot2::scale_y_continuous(labels = scales::comma)+
    ggplot2::scale_y_log10(limits = c(0.09, 7))+
    ggplot2::labs(title = "Amplification Curves: qPCR screening")+
    ggplot2::theme(legend.position = "bottom")





  #############################
  rows <- rep(c("A", "B", "C", "D", "E", "F", "G", "H"), 12)
  cols <- rep(c(1:12), each = 8)

  full_plate <- dplyr::bind_cols("well_position" = paste0(rows, cols), "rows" = rows, "cols" = cols)

  #common plots

  plate_map_plot <- full_plate %>%
    dplyr::left_join(QuantStudioData[[1]]) %>%
    tidyr::separate(well_position, into = c("row", "col"), sep = "(?<=[A-Za-z])(?=[0-9])") %>%
    dplyr:: mutate(col = as.numeric(col)) %>%
    dplyr::mutate(col = as.factor(col)) %>%
    ggplot2::ggplot(ggplot2::aes(x = col, y = forcats::fct_rev(row), fill = color_plot, text = paste0( "\nct= ", ct, "\ntm1 = ", tm1)))+
    ggplot2::geom_tile(colour = "white")+
    ggplot2::geom_text(ggplot2::aes(label = sample_id), colour = "black")+
    ggplot2::scale_fill_manual(values = colour_named_classification_control, label = c("empty" = NA))+
    ggplot2::theme_minimal()+
    ggplot2::scale_x_discrete(position = "top") +
    ggplot2::labs(title = paste0(unique(QuantStudioData[[1]]$plate_name),  " screening classification"), y = "", x = "")+
    ggplot2::theme(legend.position = "bottom")
  return(list(melt_plot_all, melt_plot_split, amplification_plots, plate_map_plot, QuantStudioData))
}
