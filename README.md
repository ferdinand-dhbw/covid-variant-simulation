# covid-variant-simulation

Disclaimer: This is just a script for data exploration. Code might not be idempotent.

Simulations and data can be found in the *netlogo* folder.
The presentation is available as *VirusVariants.pdf*.

## Abstract
This is a project in the course Computational Life Sciences at the Baden-Wuerttemberg Cooperative State University Stuttgart (DHBW Stuttgart). Inspired by the rise of the novel corona-variant ‚Omikron‘, the main research question was: How do two similar variants behave when they are initially put in the same environment. Do they coexist or compete? An SEIRD-model is used, which was created with NetLogo. The stochastic exploration of data using R shows that the chance of emerging competition between two similar variants is very high.


## Getting started - set up ```renv```
See https://www.rstudio.com/blog/renv-project-environments-for-r/.

In R-Console:

Setup renv:
1. load renv ```library(renv)``` (make sure that renv is installed first ```install.packages("renv")```)
2. ```renv::restore()```

To save the current env: ```renv::snapshot()```


## Execution time 
Approx. 10 min for 2nd experiment