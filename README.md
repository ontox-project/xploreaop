[![DOI](https://zenodo.org/badge/701327989.svg)](https://zenodo.org/doi/10.5281/zenodo.8416809)

# xploreaop

`{xploreaop}` is an R package and Shiny webapplication to visualize Adverse 
Outcome Pathway (AOP) networks. So far data has been included to interactively 
explore the AOPs for two liver outcomes: Cholestasis and Steatosis.

## Publication
This Shiny app was developed in conjunction with the scientific publication 

van Ertvelde, J., Verhoeven, A., Maerten, A., Cooreman, A., Santos Rodrigues, B. D., Sanz-Serrano, J., Mihajlovic, M., Tripodi, I., Teunis, M., Jover, R., Luechtefeld, T., Vanhaecke, T., Jiang, J., & Vinken, M. (2023). Optimization of an adverse outcome pathway network on chemical-induced cholestasis using an artificial intelligence-assisted data collection and confidence level quantification approach. Journal of biomedical informatics, 145, 104465. https://doi.org/10.1016/j.jbi.2023.104465

## Installation
This Github repository is an R package and can be installed in two ways:

 1. Cloning the repo to your local machine
 2. Installing directly from Github
 
We recommend installing directly from Github if you want to view the app. If you 
would like to review the code or adapt, we encourage forks and pull requests

To install the package directly from the Github repo, run in R:
```
install.packages("pak")
pak::pkg_install("ontox-project/xploreaop")
```

To install from a local clone, run in R from the root of the cloned repo:
```
install.packages("devtools")
devtools::install(".")
```

## Licence
This work comes with a permissive licence CC-BY 4.0 which can be viewed [here](https://github.com/ontox-project/xploreaop/blob/main/LICENSE.md)

## Furture work and development
This application is actively under development and we encourage people to contribute or reflect on the work. If you find a bug, would like a feature added, or have a great idea to add to this work, please create a new issue. 
We iniated a roadmap, based on reviewer comments and other peer feedback [here](https://github.com/ontox-project/xploreaop/blob/main/ROADMAP.md)





