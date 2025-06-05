
<!-- README.md is generated from README.Rmd. Please edit that file -->

# plasmo.cytB.qPCR

<!-- badges: start -->
<!-- badges: end -->

`plasmo.cytB.qPCR` is a series of functions to easily analyse and QC
real-time qPCR generated following the protocol published by [Canier *et
al. 2013*](https://doi.org/10.1186/1475-2875-12-405), with parameters
and cut-offs optimised for the QuantStudio.

## Installation

You can install the development version of plasmo.cytB.qPCR from
[GitHub](https://github.com/) with:

``` r
devtools::install_github("BourkeCaitlin/plasmo.cytB.qPCR")
```

## Begin

First load the library

``` r
library(plasmo.cytB.qPCR)
```

### Start new project

THe first function you might want to use is `startNewProject()`. This
creates the correct directory structure you will need to work with the
other functions.

**PLEASE MAKE SURE TO ALWAYS BE WORKING WITHIN AN RProject**

**`sub_directory`** if you are working within a directory relative to
where your RProject starts, this will be the folder name you specify as
the `sub_directory`.

**`project`** give the project you are working on a name. You will
continue to reference this in all the other commands of this package.

**`species_type`** the laboratory protocol can be adapted to determining
detecting species by either *direct PCR* or with a *nested PCR*. As
these two protocols require slightly different
interpretation/thresholds, you will specify this in your project setup
to create the correct sub-folders for storing data and results. **This
needs to be either `"nested"` or `"direct"`.**

Folders that exist already will not be overwritten.

``` r
startNewProject(sub_directory = "example_subdirectory", 
                project = "project_name", 
                species_type = "nested")
```

Your expected folder structure is:

``` r
fs::dir_tree(path = "example_subdirectory")
#> example_subdirectory
#> └── project_name
#>     ├── data
#>     │   ├── nested_species
#>     │   └── screening
#>     └── results
#>         ├── nested_species
#>         │   ├── report
#>         │   └── spreadsheet
#>         └── screening
#>             ├── report
#>             └── spreadsheet
```

## Create Screening Report

Having saved your files within the ‘data’ and corresponding *project*
folder, you can then use the function `screeningReport()` to generate
either a pdf or html report, and corresponding spreadsheet with the
results.

In this function you will specify

**project** this is the name you specified in the `startNewProject()`
(or is what is in your data folder as the folder project name) **assay**
for screening, specify **screening** **plate_folder** this is the name
of the folder where you have saved your results (that contain one
quantstudio file and one plate map file (containing ‘map’ in the
filename)) **file_type** either “.html” or “.pdf” (“.pdf”) is default if
nothing is specified

``` r
screeningReport(project = "project", assay = "screening", plate_folder = "plate1", file_type = ".pdf")
```

Running this line of code will generate a report and excel spreadsheet
saved within `results/project/screening/...`

If for some reason you may want to look at these results within R (not
just rendered in a report), you can use the function
`classifyScreening()`.

This requires exactly the same input, except for the file_type. This
function will instead return a list object containing the four plots
that are rendered in the report, and then all QuantStudio data including
the results, meltcurve data and then amplification curve data (in this
order) within a nested list.

``` r
classifyScreening(project = "project", assay = "screening", plate_folder = "plate1")
```
