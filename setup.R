##使用R version: 4.0.2

#安裝並載入package: devtools.
install.packages("devtools")
library(devtools)


###----------Check the environment---------------------------###

# 存取所有已安裝packages.
Packages <- installed.packages()
Packages <- as.data.frame(Packages[, 1])
rownames(Packages) <- c()
colnames(Packages) <- c("Package")

#Packages <- installed.packages() %>% 
#  as.data.frame() %>% 
#  dplyr::select(Package)
#rownames(Packages) <- c()
## 去除rownames.

Needed_Packages <- list(
  sf = c("sf", "0.9.4"),
  raster = c("raster", "3.1-5"),
  dplyr = c("dplyr", "1.0.0"),
  tmap = c("tmap", "3.0"),
  ggplot2 = c("ggplot2", "3.3.2"),
  readr = c("readr", "1.3.1"),
  tmaptools = c("tmaptools", "3.0"),
  rmapshaper = c("rmapshaper", "0.4.4")
)
## 建立需要的packages的list.


# 確認各package的版本是否正確，若無或有缺漏則安裝正確版本的packages.
for (i in 1:length(Needed_Packages)) {
  name <- Needed_Packages[[i]][1]
  version <- Needed_Packages[[i]][2]
  
  TRY <- try(packageVersion(name) != version)
  
  if (is.logical(TRY) == TRUE) {
    if (packageVersion(name) != version) {
      if (length(which(Packages == name)) == 1) {
        remove.packages(name)
        install_version(name, version = version, repos = "http://cran.us.r-project.org")
        }else{
        install_version(name, version = version, repos = "http://cran.us.r-project.org")  
        }
      }else{
      }
    }else{
      install_version(name, version = version, repos = "http://cran.us.r-project.org")  
    }
}

###---------------------------------------------------###