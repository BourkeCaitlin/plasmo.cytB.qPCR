#' Classify direct species PCR
#'
#' @param sub_directory name of folder within RProj where you are working
#' @param project name of the project folder you specified in startNewProject()
#' @param assay if this is direct PCR you should specify `"direct_species"`
#' @param plate_folder the name of the folder where your direct PCR data is stored
#'
#' @return list object with plots and raw data
#' @export classifyDirectSpecies
#'
#' @examples
#' \dontrun{classifyDirectSpecies(sub_directory = "lab-molecular", project = "project_name", assay = "nested_species", plate_folder = "plate1")}

classifyDirectSpecies <- function(sub_directory, project, assay = "direct_species", plate_folder) {


  temperature_range_pf <- c(79, 81)
  temperature_range_pv <- c(75.2, 77)

  temperature_range_pm <- c(75.8, 77.55)
  temperature_range_po <- c(73.4, 75.3)



  QuantStudioData <- importQuantStudio(INPUT_PLATELAYOUT = specifyFolder(sub_directory, project, assay, plate_folder)[1],
                                       INPUT_QUANTSTUDIO = specifyFolder(sub_directory, project, assay, plate_folder)[2])


  species <- readxl::read_excel(specifyFolder(sub_directory, project, assay, plate_folder)[1],
                                sheet = "species_map",
                                col_names = T,
                                col_types = c("text")) %>%
    tidyr::pivot_longer(-1, names_to = "col", values_to = "direct_species")

  # add a column that is the name of the plate- as is written in the top corner of the excel file
  species <- species %>%
    dplyr::mutate(plate_name = colnames(species[1]))


  # make a new variable representing well - paste row and col together
  #now call column 1 name "row"
  colnames(species)[1] <- "row"

  species <-species %>%
    dplyr::mutate(well_position = paste0(row, col)) %>%
    dplyr::select(!plate_name)


  for (i in 1:3) {
    QuantStudioData[[i]] <- QuantStudioData[[i]] %>%
      dplyr::left_join(species )
  }



  max_melt <- QuantStudioData[[2]] %>%
    dplyr::filter((temperature>temperature_range_pf[1]  & direct_species=="Pf" & temperature< temperature_range_pf[2]) |
             (temperature>temperature_range_pv[1]  & direct_species=="Pv" & temperature< temperature_range_pv[2])|
             (temperature>temperature_range_pm[1]  & direct_species=="Pm" & temperature< temperature_range_pm[2]) |
             (temperature>temperature_range_po[1]  & direct_species=="Po" & temperature< temperature_range_po[2])) %>%
    dplyr::group_by(well_position) %>%
    dplyr::filter(derivative==max(derivative)) %>%
    dplyr::select(well_position, derivative_max = derivative, temperature_max = temperature, direct_species) %>%
    dplyr::distinct()

  #######################################################################################################

  QuantStudioData[[1]] <- QuantStudioData[[1]] %>%
    dplyr::left_join(max_melt)

  ######################
  ##### define positive samples

  QuantStudioData[[1]] <- QuantStudioData[[1]] %>%
    dplyr::mutate(classification = case_when(
      ct<=35 & tm1 > temperature_range_pf[1] & tm1 < temperature_range_pf[2] & direct_species=="Pf" & derivative_max > 2000 ~"Pf positive",
      ct<=35 & tm2 > temperature_range_pf[1] & tm2 < temperature_range_pf[2] & direct_species=="Pf" & derivative_max > 2000 ~"Pf positive",

      ct<=35 & tm1 > temperature_range_pv[1] & tm1 < temperature_range_pv[2] & direct_species=="Pv" & derivative_max >2000 ~"Pv positive",
      ct<=35 & tm2 > temperature_range_pv[1] & tm2 < temperature_range_pv[2] & direct_species=="Pv" & derivative_max >2000 ~"Pv positive",

      ct<=35 & tm1 > temperature_range_pm[1] & tm1 < temperature_range_pm[2] & direct_species=="Pm" & derivative_max > 2000 ~"Pm positive",
      ct<=35 & tm2 > temperature_range_pm[1] & tm2 < temperature_range_pm[2] & direct_species=="Pm" & derivative_max > 2000 ~"Pm positive",

      ct<=35 &  tm1 > temperature_range_po[1] & tm1 < temperature_range_po[2] & direct_species=="Po" & derivative_max > 2000 ~"Po positive",
      ct<=35 &  tm2 > temperature_range_po[1] & tm2 < temperature_range_po[2] & direct_species=="Po" & derivative_max > 2000 ~"Po positive",

      #############################
      TRUE ~"negative")) %>%
    dplyr::mutate(species_classification = factor(classification,
                                           levels = c("Pf positive", "Pv positive", "Pm positive", "Po positive", "negative"))) %>%
    dplyr::mutate(classification_global = case_when(str_detect(species_classification, "positive")~"positive",
                                             TRUE~"negative")) %>%
    dplyr::mutate(class_ct = case_when(
      ct<10 ~ "ct < 10",
      ct<20 & ct>=10 ~"10 <= ct < 20",
      ct<=35 & ct>=20 ~"20<= ct <= 35",
      TRUE~"no ct"
    )) %>%
    dplyr::mutate(class_ct= factor(class_ct, levels= c("ct < 10","10 <= ct < 20","20<= ct <= 35",  "no ct"))) %>%
    dplyr::mutate(classification_global = factor(classification_global, levels = c("positive", "negative")))

  ##### summary plots

  ########################
  ct_colours <- c("ct < 10"= "#1A4327","10 <= ct < 20"=  "#95c36e","20<= ct <= 35"= "#9E5590", "no ct"= "grey") %>%
    dplyr::as_tibble(rownames = "ct_cat")
  colour_named_ct <- ct_colours$value
  names(colour_named_ct) <- ct_colours$ct_cat

  cat_colours <- c("positive"= "#BC2728",  "negative"= "#BCD7FB") %>%
    dplyr::as_tibble(rownames = "classification")
  colour_named_classification <- cat_colours$value
  names(colour_named_classification) <- cat_colours$classification


  ##############################
  ###### melt plots


  all_melt_temps <- QuantStudioData[[2]] %>%
    dplyr::left_join(QuantStudioData[[1]] %>%
                dplyr::select(sample_id, well_position, classification,ct, plate_name, tm1, tm2, derivative_max, temperature_max, direct_species, class_ct, species_classification, classification_global))

  melt_plot_all <- all_melt_temps %>%
    ggplot2::ggplot(ggplot2::aes(x = temperature, y = derivative))+
    ggplot2::geom_line(ggplot2::aes(group = well_position,
                                    colour = factor(classification_global, levels = c("negative", "positive"))),
                       alpha = 0.7, size = 0.85)+
    ggplot2::scale_y_continuous(labels = scales::comma)+
    ggplot2::scale_colour_manual(values = colour_named_classification)+
    ggplot2::facet_wrap(~direct_species)+
    ggplot2::theme_minimal()+
    ggplot2::scale_y_continuous(labels = scales::comma)+
    ggplot2::labs(title = paste0("Melt temperature: qPCR direct species "), colour = "")


  ###########################################################################
  ## melt plots 2

  melt_plot_split <- all_melt_temps %>%
    ggplot2::ggplot(ggplot2::aes(x = temperature, y = derivative))+
    ggplot2::geom_line(data = dplyr::filter(all_melt_temps, class_ct=="ct < 10"), ggplot2::aes(group = well_position, colour = class_ct), alpha = 0.7, size = 0.85)+
    ggplot2::geom_line(data = dplyr::filter(all_melt_temps, class_ct=="10 <= ct < 20"), ggplot2::aes(group = well_position, colour = class_ct), alpha = 0.7, size = 0.85)+
    ggplot2::geom_line(data = dplyr::filter(all_melt_temps, class_ct=="20<= ct <= 35"), ggplot2::aes( group = well_position, colour = class_ct), alpha = 0.9, size = 0.85)+
    ggplot2::geom_line(data = dplyr::filter(all_melt_temps, class_ct=="no ct"), ggplot2::aes(group = well_position, colour = class_ct), alpha = 0.7, size = 0.85)+
    ggplot2::scale_y_continuous(labels = scales::comma)+
    ggplot2::scale_colour_manual(values = colour_named_ct)+
    ggplot2::facet_grid(classification_global~direct_species)+
    ggplot2::theme_minimal()+
    ggplot2::scale_y_continuous(labels = scales::comma)+
    ggplot2::labs(title = paste0("Melt temperature: qPCR nested species "), colour = "")

  ###########################################################################

  ## amplification plot 1

  amplification_plots <- QuantStudioData[[3]] %>%
    dplyr::left_join(QuantStudioData[[1]]) %>%
    ggplot2::ggplot(ggplot2::aes(x = cycle, y = rn))+
    ggplot2::geom_line(ggplot2::aes(group = well_position, colour = classification_global))+
    ggplot2::scale_colour_manual(values = colour_named_classification)+
    ggplot2::theme_minimal()+
    ggplot2::facet_grid(classification_global~direct_species)+
    ggplot2::scale_y_continuous(labels = scales::comma)+
    ggplot2::scale_y_log10(limits = c(0.09, 7))+
    ggplot2::labs(title = "Amplification Curves: qPCR nested species")



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
    ggplot2::ggplot(ggplot2::aes(x = col, y = forcats::fct_rev(row), fill = classification_global, text = paste0( "\nct= ", ct, "\ntm1 = ", tm1)))+
    ggplot2::geom_tile(colour = "white")+
    ggplot2::geom_text(ggplot2::aes(label = sample_id), colour = "black")+
    ggplot2::scale_fill_manual(values = colour_named_classification, label = c("empty" = NA))+
    ggplot2::theme_minimal()+
    ggplot2::scale_x_discrete(position = "top") +
    ggplot2::labs(title = paste0(unique(QuantStudioData[[1]]$plate_name), fill = " direct species classification"), y = "", x = "")+
    ggplot2::theme(legend.position = "bottom")

  ################# plate map of primers
  QuantStudioData[[1]]$direct_species
  plate_map_primers <- full_plate %>%
    dplyr::left_join(QuantStudioData[[1]]) %>%
    tidyr::separate(well_position, into = c("row", "col"), sep = "(?<=[A-Za-z])(?=[0-9])") %>%
    dplyr:: mutate(col = as.numeric(col)) %>%
    dplyr::mutate(col = as.factor(col)) %>%
    ggplot2::ggplot(ggplot2::aes(x = col, y = forcats::fct_rev(row)))+
    ggplot2::geom_tile(colour = "grey", fill = "white")+
    ggplot2::geom_text(ggplot2::aes(label = direct_species), colour = "black")+
    ggplot2::theme_minimal()+
    ggplot2:: scale_x_discrete(position = "top") +
    ggplot2::labs(title = paste0(unique(QuantStudioData[[1]]$plate_name), fill = " primers used"), y = "", x = "")+
    ggplot2::theme(legend.position = "bottom")

  return(list(melt_plot_all, melt_plot_split, amplification_plots, plate_map_plot,plate_map_primers, QuantStudioData))

}
