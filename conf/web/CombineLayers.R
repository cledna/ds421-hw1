#####################################################
## This file takes all the layer Rmd files and 
## writes them into a single Rmd file
#####################################################

## load relevant libraries
library(dplyr)
library(tidyr)

file.remove("eez/conf/web/layers_all.Rmd")

######################################################
### Rmd file header information
#######################################################
tmp <- capture.output(cat("---",
                          "\ntitle: Layers descriptions",
                          "\noutput:",
                          "\n  html_document:",
                          "\n    toc: true",
                          "\n    toc_depth: 1",
                          "\n    number_sections: false",
                          "\n    toc_float: yes",
                          "\n---"))

write(tmp, "eez/conf/web/layers_all.Rmd")



######################################################
### Load libraries in Rmd
### and get master list of layers
#######################################################

tmp <- capture.output( cat(paste0("\n```{r, message=FALSE, echo=FALSE, warning=FALSE, error=FALSE}"),
                           "\n",
                           "library(dplyr)",
                           "\n",
                           "library(tidyr)",
                           "\n",
                           "library(knitr)",
                           "\n",
                           "\n",
                           "layer_meta <- read.csv('https://raw.githubusercontent.com/OHI-Science/ohi-global/draft/eez_layers_meta_data/layers_eez_base.csv', stringsAsFactors = FALSE)",
                           "\n",
                           "layer_path <- 'https://github.com/OHI-Science/ohi-global/tree/draft/eez/layers'",
                           "\n",
                           "\n",
                           "\n```"))
                           
write(tmp, "eez/conf/web/layers_all.Rmd", append=TRUE)


######################################################
### Cycle through each layer and add to file
#######################################################

layer_path <- 'https://github.com/OHI-Science/ohi-global/tree/draft/eez/layers'

## make sure all the Rmd files are in there and no typos!
layers_Rmd <- list.files("global_supplement/layers_info")
layers_Rmd <- layers_Rmd[grep(".Rmd", layers_Rmd)]
layers_Rmd <- gsub(".Rmd", "", layers_Rmd)
layers <- read.csv("eez_layers_meta_data/layers_eez_base.csv", stringsAsFactors = FALSE)

## extra Rmd file (or is mislabeled)
## can ignore the "layers_all" file, but there should be no others:
setdiff(layers_Rmd, layers$layer)

## a layer that is missing an Rmd file
## Should be none:
setdiff(layers$layer, layers_Rmd)

### Grab each layer description and add to master Rmd file!

data <- layers %>%
  select(layer, name, units) %>%
  arrange(name)

for(layer_short in data$layer){ #layer_short="ao_need"

layer_long <- data$name[data$layer == layer_short]
units <- data$units[data$layer == layer_short]
layer_path <- 'https://github.com/OHI-Science/ohi-global/tree/draft/eez/layers'

tmp <- capture.output( cat("\n",  
                          paste0("\n#", layer_long),
                          
                          paste0("\n####[", layer_short, "]", "(", file.path(layer_path, layer_short), ".csv) {-}"),
                          
                          paste0("\n```{r, echo=FALSE, results='hide'}\n
                                  x <- tempfile(fileext = 'Rmd')\n
                                 on.exit(unlink(x))\n
                                 download.file(", "\"",
                                 sprintf('https://raw.githubusercontent.com/OHI-Science/ohi-global/draft/global_supplement/layers_info/%s.Rmd', 
                                         layer_short), "\", x)\n```\n"),
                          
                          paste0("\n```{r, child = x, echo=FALSE, results='asis'}"),
                          "\n",
                          "\n```",
                          "\n",
                          "\n####Units {-}",
                          "\n",
                          units
                          # ,
                          # "\n###References {-}"
                          ))

write(tmp, "eez/conf/web/layers_all.Rmd", append=TRUE)
}      

