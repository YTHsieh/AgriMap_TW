##使用R version: 4.0.2


##初次使用時安裝.
###----------Check the environment---------------------------###
source("setup.R")
## 自動檢查R package的環境，如果不符合開發時package-
## 的版本，則自動重新安裝對應版本.
###----------------------------------------------------------###

##----------Set parameters---------------------------##

Data <- "108_Tea.csv"
## 指定用於作圖的data.
## 僅能使用.csv檔.
## 格式請參見模板.

Image_Name <- "test"
## 用於存檔的檔名
## 預設一次會存三種格式: .tiff, .png, .svg.
### .svg 為向量格式，可以用Adobe Illustrator或Inkscape等編輯軟體打開，調整後重新輸出.

Shpfile_Name <- "108_Tea.shp"
## 另存的shapefile的檔名.
## 結尾須為".shp".

Map_Breaks <- c(0, 500, 1000, 1200, Inf)
## 主題地圖的顏色分級.
## 中間的數字可以隨意.
#### 最後一個值為"Inf"代表多餘倒數第二個數.

Color = "BuGn"
## 設定地圖的色階
## 基本上R內支援的色階都可以使用
## 詳細參考，請透過Google搜尋: R palette.


Records <- "108_Machilus_test.csv"
## 採集點位紀錄的檔名.
## 僅能使用.csv檔, UTF-8編碼.
## 僅能有四欄: ID、緯度、經度、測量值.
## 請使用Google地圖座標(WGS84).

##---------------------------------------------------##


#載入所需package
library(sf)
library(raster)
library(spData)
library(dplyr)
library(tmap)
library(GADMTools)
library(ggplot2)
library(readr)
library(grid)
library(tmaptools)
library(rmapshaper)

#農情資料下載
#行政院農業委員會農糧署企劃組農情報告資源網, URL: https://agr.afa.gov.tw/afa/afa_frame.jsp?fbclid=IwAR3P7iAu8iUP55jPgu0OKPRgwPRBH57X1vHIXsCa893jr_M2zLHVpf8thi0
# > 農情調查資訊查詢
#  > 一般作物查詢
#   > 各項作物規模別排序查詢(全部鄉鎮)
#載入該網頁時,javascript會運作較長一段時間，跑完後才可正常查詢。 


#清理農情資料
crop_raw <- read_csv(paste(getwd(), "Data", Data, sep = "/"), col_names = FALSE, locale = locale( encoding = "UTF-8"),
                     col_types = cols(X1= col_character(), X2 = col_number(), X3 = col_number(), X4 = col_number(), X5 = col_number()), skip = 3)
## 需先手動將excel匯出成".csv" file. 若打開呈現亂碼，請用記事本或notepad++將".csv"檔 - 
## 轉換成"UTF-8"編碼.
## col_character()指定該欄為character; col_number()指定該欄為number.



colnames(crop_raw) <- c("Region_Name", "Plant_Area", "Crop_Area", "Gain_per_ha", "Gain_Total")
## 更改欄位名稱

crop_proc <- crop_raw %>% 
             mutate(County_Name = substr(crop_raw$Region_Name, 1, 3),
                    Third_Name = substr(crop_raw$Region_Name, 4, length(crop_raw$Region_Name))) %>%
             subset(select = -Region_Name ) %>% 
             select(County_Name, Third_Name, Plant_Area, Crop_Area, Gain_per_ha, Gain_Total)
## 清理raw data至可用版本


#透過Package: sf，讀入電腦硬碟內的.shp檔，存成class: "sf".
TW_boundary <- st_read(paste(getwd(), "TW_boundary/3rd_regions_TWD97/mapdata20190107/TOWN_MOI_1080617.shp", sep = "/"))
## 測試用鄉鎮界下載URL: https://data.gov.tw/dataset/7441


#依據主鍵: 鄉鎮名, 將圖資與農情資料對應起來。
Crop_Map <-  left_join(TW_boundary, crop_proc, by = c("TOWNNAME" = "Third_Name", "COUNTYNAME" = "County_Name"))
## TW_boundary中的鄉鎮名: TOWNNAME.
## crop_proc中的鄉鎮名: Third_Name.
## 加上第二組: 縣市名，的配對鍵值; type = AND.



#獨立出金門、馬祖地區圖資
TW_Main <- Crop_Map %>% subset(!COUNTYNAME %in% c("金門縣","連江縣")) %>% simplify_shape(0.2)
TW_KM <- Crop_Map %>% subset(COUNTYNAME == "金門縣") %>% simplify_shape(0.2)
TW_LJ <- Crop_Map %>% subset(COUNTYNAME == "連江縣") %>% simplify_shape(0.2)

TW_Main_boundary <- TW_Main %>% 
                   group_by(COUNTYNAME) %>% 
                   summarise() %>% 
                   ungroup()
KM_boundary <- TW_KM %>% 
               group_by(COUNTYNAME) %>% 
               summarise() %>% 
               ungroup()
LJ_boundary <- TW_LJ %>% 
               group_by(COUNTYNAME) %>% 
               summarise() %>% 
               ungroup()

#重設出圖界線
Main_bbox_new <- st_bbox(TW_Main) 
KM_bbox_new <- st_bbox(TW_KM)
LJ_bbox_new <- st_bbox(TW_LJ)
## 抽出目前的bounding box

#指定本島bounding box.
Main_bbox_new["xmin"] <- 118
Main_bbox_new["ymin"] <- 21.5
Main_bbox_new["xmax"] <- 124
Main_bbox_new["ymax"] <- 25.5

#指定金門bounding box.
KM_bbox_new["xmin"] <- 118.19
KM_bbox_new["ymin"] <- 24.35
KM_bbox_new["xmax"] <- 118.60
KM_bbox_new["ymax"] <- 24.54

#指定連江bounding box.
LJ_bbox_new["xmin"] <- 119.88
LJ_bbox_new["ymin"] <- 25.92
LJ_bbox_new["xmax"] <- 120.55
LJ_bbox_new["ymax"] <- 26.40
## 指定新的bounding box的界線


vp_KM <- viewport(x = 0.2, y = 0.3, width = 0.3, height = 0.3)
vp_LJ <- viewport(x = 0.2, y = 0.8, width = 0.3, height = 0.3)
## 指定金門、馬祖於圖上的位置.

#依據有無點位資料，判斷是否輸出點位至地圖上.
if ( nchar(Records) != 0 ) {
  
  ##---------調查紀錄點位處理---------------------##
  
  Sample_Point <- read_csv(paste(getwd(), "Data", Records, sep = "/"), col_names = FALSE, locale = locale( encoding = "UTF-8"),
                           col_types = cols(X1= col_character(), X2 = col_number(), X3 = col_number(), X4 = col_number()), skip = 1)
  ## 讀入點位資料.
  colnames(Sample_Point) <- c("ID", "Latitude", "Longitude", "Measurement")
  ## 修改欄位名稱.
  
  Sample_Point_sf <- sf::st_as_sf(Sample_Point, coords = c("Longitude", "Latitude"), crs = 4326)
  ## 將讀入的點位轉換成sf object.
  ## 同時指定crs為WGS84(=TWD97): EPSG4326.
  ##----------------------------------------------##
  
  ##--------地圖物件的生成------------##
  
  #嘗試tmap作圖
  tmap_mode("plot")
  ## package: tmap的繪圖模式.
  
  #嘗試拼接三個區域的地圖
  m_TW_main <- tm_shape(TW_Main, bbox = Main_bbox_new) +
    tm_polygons("Plant_Area", title = "", showNA = TRUE, border.col = "gray50", border.alpha = 0.3, lwd = 0.7,breaks = Map_Breaks, palette = Color) + 
    tm_shape(TW_Main_boundary) +
    tm_borders(lwd = 0.7, col = "black", alpha = 1.0) +
    tm_layout(title = "108 plant area size of Tea",
              title.position = c(0.5, 0.95),
              title.size = 1,
              legend.position = c("right", "center"), frame = FALSE,
              inner.margins = c(0.05, 0.1, 0.05, 0.05)) +
    tm_compass(type = "arrow", position = c("right", "top")) +
    tm_scale_bar(breaks = c(0, 50, 100), text.size = 0.8, position = c("right", "bottom")) +
    tm_credits(paste0("Data @ Agriculture and Food Agency Council of Agriculture, Council of Agriculture\n",
                      "Shape @ National Land Surveying and Mapping Center, Ministry of the Interior"), size = 0.4, position = c("right", "bottom")) +
    tm_shape(Sample_Point_sf) +
    tm_symbols(col = "black", border.col = "white", size = 0.1) 
  
  m_KM <- tm_shape(TW_KM, bbox = KM_bbox_new) +
    tm_polygons("Plant_Area", title = "", showNA = TRUE, border.col = "gray50", border.alpha = 0.3, lwd = 0.7, breaks = Map_Breaks, palette = Color) + 
    tm_shape(KM_boundary) +
    tm_borders(lwd = 0.7, col = "black", alpha = 1.0) +
    tm_layout(title = "Kinmen",
              title.position = c("right", "top"),
              title.size = 0.7,
              legend.show = FALSE) +
    tm_shape(Sample_Point_sf) +
    tm_symbols(col = "black", border.col = "white", size = 0.1) 
  
  m_LJ <- tm_shape(TW_LJ, bbox = LJ_bbox_new) +
    tm_polygons("Plant_Area", title = "", showNA = TRUE, border.col = "gray50", border.alpha = 0.3, lwd = 0.7, breaks = Map_Breaks, palette = Color) + 
    tm_shape(LJ_boundary) +
    tm_borders(lwd = 0.7, col = "black", alpha = 1.0) +
    tm_layout(title = "Lianjiang",
              title.position = c("right", "bottom"),
              title.size = 0.7,
              legend.show = FALSE) +
    tm_shape(Sample_Point_sf) +
    tm_symbols(col = "black", border.col = "white", size = 0.1) 
  ## 另存三tmap objects.
  ##-----------------------------------------##

}else{
  
  ##--------地圖物件的生成------------##
  
  #嘗試tmap作圖
  tmap_mode("plot")
  ## package: tmap的繪圖模式.
  
  #嘗試拼接三個區域的地圖
  m_TW_main <- tm_shape(TW_Main, bbox = Main_bbox_new) +
    tm_polygons("Plant_Area", title = "", showNA = TRUE, border.col = "gray50", border.alpha = 0.3, lwd = 0.7,breaks = Map_Breaks, palette = Color) + 
    tm_shape(TW_Main_boundary) +
    tm_borders(lwd = 0.7, col = "black", alpha = 1.0) +
    tm_layout(title = "108 plant area size of Tea",
              title.position = c(0.5, 0.95),
              title.size = 1,
              legend.position = c("right", "center"), frame = FALSE,
              inner.margins = c(0.05, 0.1, 0.05, 0.05)) +
    tm_compass(type = "arrow", position = c("right", "top")) +
    tm_scale_bar(breaks = c(0, 50, 100), text.size = 0.8, position = c("right", "bottom")) +
    tm_credits(paste0("Data @ Agriculture and Food Agency Council of Agriculture, Council of Agriculture\n",
                      "Shape @ National Land Surveying and Mapping Center, Ministry of the Interior"), size = 0.4, position = c("right", "bottom")) 
  
  m_KM <- tm_shape(TW_KM, bbox = KM_bbox_new) +
    tm_polygons("Plant_Area", title = "", showNA = TRUE, border.col = "gray50", border.alpha = 0.3, lwd = 0.7, breaks = Map_Breaks, palette = Color) + 
    tm_shape(KM_boundary) +
    tm_borders(lwd = 0.7, col = "black", alpha = 1.0) +
    tm_layout(title = "Kinmen",
              title.position = c("right", "top"),
              title.size = 0.7,
              legend.show = FALSE)
  
  m_LJ <- tm_shape(TW_LJ, bbox = LJ_bbox_new) +
    tm_polygons("Plant_Area", title = "", showNA = TRUE, border.col = "gray50", border.alpha = 0.3, lwd = 0.7, breaks = Map_Breaks, palette = Color) + 
    tm_shape(LJ_boundary) +
    tm_borders(lwd = 0.7, col = "black", alpha = 1.0) +
    tm_layout(title = "Lianjiang",
              title.position = c("right", "bottom"),
              title.size = 0.7,
              legend.show = FALSE)
  ## 另存三tmap objects.
  ##-----------------------------------------##

}

##---------------------畫圖存檔設定---------------##
## Tiff檔

Image_Tiff <- paste(Image_Name, ".tiff", sep = "")
tiff(paste(getwd(), "Results", Image_Tiff, sep = "/"), units="in", width=5, height=5, res=300)
## Turn on the saving board for the thematic map.

m_TW_main
## 畫出主圖.
print(m_KM, vp = vp_KM)
## 加上金門縣.
print(m_LJ, vp = vp_LJ)
## 加上連江縣.

dev.off()
## Turn off the saving board. 

## PNG檔

Image_PNG <- paste(Image_Name, ".png", sep = "")
png(paste(getwd(), "Results", Image_PNG, sep = "/"), units="in", width=5, height=5, res=300)
## Turn on the saving board for the thematic map.

m_TW_main
## 畫出主圖.
print(m_KM, vp = vp_KM)
## 加上金門縣.
print(m_LJ, vp = vp_LJ)
## 加上連江縣.

dev.off()
## Turn off the saving board. 

## SVG檔

Image_SVG <- paste(Image_Name, ".svg", sep = "")
svg(paste(getwd(), "Results", Image_SVG, sep = "/"), width=5, height=5, pointsize=12)
## Turn on the saving board for the thematic map.

m_TW_main
## 畫出主圖.
print(m_KM, vp = vp_KM)
## 加上金門縣.
print(m_LJ, vp = vp_LJ)
## 加上連江縣.

dev.off()
## Turn off the saving board. 



#輸出Thematic map的.shp檔.

st_write(Crop_Map, paste(getwd(), "Results", Shpfile_Name, sep = "/"), driver="ESRI Shapefile", layer_options = "ENCODING=UTF-8", delete_layer = TRUE)  
## create to a shapefile 
## 輸出的.shp，由於shapefile檔格式本身的限制，原本R內的column name過長的將會被自動縮寫. 
test_export <- st_read(paste(getwd(), "Results", Shpfile_Name, sep = "/"))

##------------------------------------------------##
