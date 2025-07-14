
<!-- README.md is generated from README.Rmd. Please edit that file -->

# plasmo.cytB.qPCR

<!-- badges: start -->
<!-- badges: end -->

`plasmo.cytB.qPCR` is a series of functions to easily analyse and QC
real-time qPCR generated following the protocol published by [Canier *et
al.* 2013](https://doi.org/10.1186/1475-2875-12-405), with parameters
and cut-offs optimised for the QuantStudio.

## Installation

You can install the development version of plasmo.cytB.qPCR from
[GitHub](https://github.com/) with:

``` r
devtools::install_github("BourkeCaitlin/plasmo.cytB.qPCR")
```

## Starting a new PCR project

First load the library when using functions from the package.

``` r
library(plasmo.cytB.qPCR)
```

The first function you will likely want to use is `startNewProject()`.
This creates the correct directory structure you will need to work with
the other functions.

**PLEASE ALSO MAKE SURE TO ALWAYS BE WORKING WITHIN AN RProject**.

You can use the same .Rproj for all PCR projects and specify the
different studies with the `project` variable (below), or if you prefer
you can have a different RProject for each study.

#### Key variables you need to specify:

**`sub_directory`** you need to specify a directory relative to where
your RProject starts, this will be the folder name you specify as the
`sub_directory`. Do not leave blank.

**`project`** give the project you are working on a name.

**`species_type`** the laboratory protocol can be adapted to determining
detecting species by either *direct PCR* or with a *nested PCR*. As
these two protocols require slightly different
interpretation/thresholds, you will specify this in your project setup
to create the correct sub-folders for storing data and results. **This
needs to be either “nested_species” or “direct_species”.**

**Folders that exist already will not be overwritten. **

``` r
startNewProject(sub_directory = "example_subdirectory", 
                project = "project_name", 
                species_type = "nested_species")
```

Your folder structure should look like this, without the raw data
folders. You will add these manually as you generate data.

    #> example_subdirectory
    #> └── project_name
    #>     ├── data
    #>     │   ├── nested_species
    #>     │   │   └── example-nestedspecies-plate1
    #>     │   ├── rejected_plates
    #>     │   └── screening
    #>     │       └── example-screening-plate1
    #>     └── results
    #>         ├── merged_database
    #>         ├── nested_species
    #>         │   ├── report
    #>         │   └── spreadsheet
    #>         └── screening
    #>             ├── report
    #>             └── spreadsheet

You will need to store your results (xls/xlsx Quantstudio file) and
plate map (containing the keyword **map** in the filename) **within a
folder (shown above)** inside the `screening` or `nested_species`
directories. This **folder name will be used** in subsequent functions.
Suggestion something similar to `plate1_initials`.

## Create Screening Report

Following a *screening PCR*, to analyse and QC these results, use the
`screeningReport()` function. This will generate within the
`results/screening` directories, a visual report (either html or pdf as
specified in the function) and an xlsx file in the report and
spreadsheet folders, respectively.

#### Key variables you need to specify:

**`sub_directory`** the same as above, as specified in
`startNewProject()`

**`project`** the same as above, as specified in `startNewProject()`

**`assay`** this is generating a report for the **screening** assay, so
specify `"screening"`

**`plate_folder`** the name of the folder with the `results/screening`
directory where the platemap (with **map** in the filename) and
Quantstudio xls/x export are stored. Suggestion something similar to
`plate1_initials`.

**`file_type`** here specify either **`".pdf"`** or **`".html"`**
depending on whether you want the output report to be in pdf or html
format (html will typically work if pdf throws you an error)

``` r
screeningReport(sub_directory = "example_subdirectory",
                project = "project_name", 
                assay = "screening", 
                plate_folder = "plate1", 
                file_type = ".pdf")
```

Provided there are no errors, this generates a report that is saved in
`results/screening/report` and an xlsx file in
`results/screening/spreadsheet`

## Interact with screening results while in R

There may be scenarios where you would like to look at the results while
in R and not just obtain the rendered report and spreadsheet.

If so, you can use the function `classifyScreening()`. It uses the exact
same input as above (just without the specification of file_type).

``` r
classifyScreening(sub_directory = "example_subdirectory",
                  project = "project_name", 
                  assay = "screening", 
                  plate_folder = "plate1")
```

This will return a `list` containing

1.  Melt curve plots
2.  Melt curve splits by category
3.  Amplification curves
4.  Colour platelayout
5.  Nested list of raw data
    1.  Consolidated results
    2.  All meltcurve data
    3.  All amplification curve data

## Create Nested Species Report

Just like for a screening PCR, following a nested PCR, generate a QC
summary (report) and spreadsheet using the `nestedSpeciesReport()`
function. Parameters are the same as above with the except specify
**`assay = "nested_species"`**

#### Key variables you need to specify:

**`sub_directory`** the same as above, as specified in
`startNewProject()`

**`project`** the same as above, as specified in `startNewProject()`

**`assay`** this is generating a report for the **nested_species**
assay, so specify `"nested_species"`

**`plate_folder`** the name of the folder with the
`results/nested_species` directory where the platemap (with **map** in
the filename) and Quantstudio file are stored. Suggestion something
similar to `plate1_initials`.

**`file_type`** here specify either **“.pdf”** or **“.html”**

## Interact with nested species results while in R

Like for screening, you can interact with the results while in R and to
do this use the `classifyNestedSpecies()` function with all the same
parameters as `nestedSpeciesReport()` but with no `file_type` specified.

``` r
classifyNestedSpecies(sub_directory = "example_subdirectory",
                  project = "project_name", 
                  assay = "nested_species", 
                  plate_folder = "plate1")
```

1.  Melt curve plots
2.  Melt curve splits by category
3.  Amplification curves
4.  Colour platelayout
5.  Map of species primers
6.  Nested list of raw data
    1.  Consolidated results
    2.  All meltcurve data
    3.  All amplification curve data

# File specifications

Within every results folder (specified with the `plate_folder`) you will
need two files.

First is the Quanstudio results file that is exported from the .eds
output of the machine. This will have a series of sheets automatically
generated including ‘Results’, ‘Melt Curve Raw Data’ and ‘Amplification
Data’. You do not need to modify this file in any way after exporting it
from the QuantStudio software.

Second, you will need to have a platemap file to designate the sample
layout in the 96 well plate format. This requires the sheet of the
platemap to be called **map** and if it is a species-specific PCR
(nested or direct) you will also need a second sheet named
**species_map** specifying which primers are in which wells (use Pf, Pv,
Pm or Po).

**A screening platemap will look approximately like:**

![](inst/images/screening_file_map.PNG)

**A species platemap will look approximately like:**

![](inst/images/nested-map1.PNG)

![](inst/images/nested-map2.PNG)

**FILE NAMING**

Only the platemap file MUST have the word ‘map’ in the filename. The
Quanstudio export does not have any naming requirements except to be the
only other xls or xlsx file accompanying the map-named file in the
folder. It is fine to store the original QuantStudio raw data (.eds)
file in this same folder.

A sporadic error appears to occur is the **folder name** of your data is
too long. Try reducing the length of the name you give for each plate
folder if you come accross this.

## Merge all results into one database

The `createPCRdatabase()` function is to be used when wanting to merge
results from one project into one project. This function has several
assumptions…

1.  If you have repeated a plate for QC purposes, you have stored the
    ‘rejected’ results somewhere else - **importantly, they are not
    stored in the results folder for screening or
    nested_species/direct_species**
2.  If for example you have one sample on plate that you had had to
    repeat, you modify the sampleID to flag this as a rejected sample
    with ‘-REJ’ for example. This prevents merging issues

### Usage

``` r
createPCRdatabase(sub_directory = "sub_directory",
                  project = "project_name",
                  species_type = "nested_species")
```

## Follow along with an example:

Example data and results are provided within the `example_subdirectory`
folder.

The following code can be used to regenerate the results in this folder.

Before starting **please start, or work within an Rproj and have the
`example_subdirectory` or renamed folder in the same location as your
.Rproj file**

``` r
library(plasmo.cytB.qPCR)
```

1.  `startNewProject()`, using ‘example_subdirectory’ as the
    sub_directory and `project-name` as project. If you are coping
    across `example_subdirectory` and all its contents, you can proceed
    to the next step. Otherwise, you can rename your sub_directory and
    project and put the raw data in the corresponding folders generated
    at this step.

``` r
startNewProject(sub_directory = "example_subdirectory", 
                project = "project_name", 
                species_type = "nested_species")
```

2.  Generate `screeningReport()`

-   to generate pdf report

``` r
screeningReport(sub_directory = "example_subdirectory", 
                project = "project_name", 
                assay = "screening",
                plate_folder = "example-screening-plate1",
                file_type = ".pdf")
#> processing file: screening_report.Rmd
#> output file: screening_report.knit.md
#> /Applications/RStudio.app/Contents/MacOS/quarto/bin/tools/pandoc +RTS -K512m -RTS screening_report.knit.md --to latex --from markdown+autolink_bare_uris+tex_math_single_backslash --output /Users/bourke.c/Documents/2025/plasmo.cytB.qPCR/example_subdirectory/project_name/results/screening/report/2025-07-14_screening_classification_project_name-example-screening-plate1.tex --lua-filter /Library/Frameworks/R.framework/Versions/4.2/Resources/library/rmarkdown/rmarkdown/lua/pagebreak.lua --lua-filter /Library/Frameworks/R.framework/Versions/4.2/Resources/library/rmarkdown/rmarkdown/lua/latex-div.lua --self-contained --highlight-style tango --pdf-engine pdflatex --variable graphics --include-in-header /var/folders/lb/_ccs_tw15mv9pjsy4qm4538m00039d/T//RtmpvTwIhY/rmarkdown-strc9e8d026692.html --variable 'geometry:margin=1in'
#> 
#> Output created: example_subdirectory/project_name/results/screening/report/2025-07-14_screening_classification_project_name-example-screening-plate1.pdf
#> [1] "check the results/screening folder to find the results !"
```

-   to generate html report (sometimes pdf will bug depending on
    computer, and html will usually work)

``` r
screeningReport(sub_directory = "example_subdirectory", 
                project = "project_name", 
                assay = "screening",
                plate_folder = "example-screening-plate1",
                file_type = ".html")
```

3.  Generate `nestedSpeciesReport()`

-   to generate pdf output

``` r
nestedSpeciesReport(sub_directory = "example_subdirectory", 
                project = "project_name", 
                assay = "nested_species",
                plate_folder = "example-nestedspecies-plate1",
                file_type = ".pdf")
#> processing file: nested_species_report.Rmd
#> output file: nested_species_report.knit.md
#> /Applications/RStudio.app/Contents/MacOS/quarto/bin/tools/pandoc +RTS -K512m -RTS nested_species_report.knit.md --to latex --from markdown+autolink_bare_uris+tex_math_single_backslash --output /Users/bourke.c/Documents/2025/plasmo.cytB.qPCR/example_subdirectory/project_name/results/nested_species/report/2025-07-14_nestedspecies_classification_project_name-example-nestedspecies-plate1.tex --lua-filter /Library/Frameworks/R.framework/Versions/4.2/Resources/library/rmarkdown/rmarkdown/lua/pagebreak.lua --lua-filter /Library/Frameworks/R.framework/Versions/4.2/Resources/library/rmarkdown/rmarkdown/lua/latex-div.lua --self-contained --highlight-style tango --pdf-engine pdflatex --variable graphics --include-in-header /var/folders/lb/_ccs_tw15mv9pjsy4qm4538m00039d/T//RtmpvTwIhY/rmarkdown-strc9e869e3e66e.html --variable 'geometry:margin=1in'
#> 
#> Output created: example_subdirectory/project_name/results/nested_species/report/2025-07-14_nestedspecies_classification_project_name-example-nestedspecies-plate1.pdf
#> [1] "check the results/nested_species folder to find the results !"
```

-   to generate html output

``` r
nestedSpeciesReport(sub_directory = "example_subdirectory", 
                project = "project_name",  
                assay = "nested_species",
                plate_folder = "example-nestedspecies-plate1",
                file_type = ".html")
```

4.  Summarise all results from project in validated plates

``` r
createPCRdatabase(sub_directory = "example_subdirectory", 
                project = "project_name", 
                  species_type = "nested_species")
```

This excel file is now in
`example_subdirectory/project_name/results/merged_database` saved with
the date generated.
