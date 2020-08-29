AgriMap_TW
===

## Table of Contents

- [AgriMap_TW](#agrimap-tw)
  * [Table of Contents](#table-of-contents)
  * [Introduction](#introduction)
  * [Beginners Guide](#beginners-guide)
    + [環境建置](#----)
    + [下載AgriMap_TW與安裝相關package](#--agrimap-tw-----package)
    + [資料準備](#----)
    + [參數設定](#----)
    + [出圖](#--)
  * [Further Reading](#further-reading)
  * [Acknowledgment](#acknowledgment)
  * [Version Change Log](#version-change-log)
          + [tags: `GIS` `Documentation` `Agriculture` `Choropleth Map`](#tags---gis---documentation---agriculture---choropleth-map-)

<small><i><a href='http://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>

## Introduction

AgriMap_TW是一組用來快速、自動化製作面量圖的R script。面量圖是主題地圖的一種，其製作方法是根據統計數值的多寡來將不同的地理區域上色，如此可有效呈現地理區域間目標數值的分布情形，常使用於資料視覺化的各種應用場合，例如：縣市長全國選舉時用以呈現各縣市的勝選政黨。本專案主要利用R的package: tmap進行地圖繪製，使用者只需依指示將資料放入對應資料夾，設定好參數，執行後即可得到面量圖。目前的script會輸出四種型式的面量圖：.tiff檔、.png檔、.svg檔，與.shp檔；其中.svg檔可以使用向量編輯軟體進行細部修正，.shp檔則可以透過GIS軟體開啟、進行深入分析。

目前的版本雖未統合成R package的型式，但已嘗試進行初步的模組化，或許在未來版本的更新中可以升級成R package，或以獨立軟體的型式發布。



## Beginners Guide
### 環境建置
本script檔使用的R版本號為: 4.0.2，並建議透過Rstudio來執行。使用者請先至[R](https://www.r-project.org/)與[Rstudio](https://rstudio.com/)官網下載、安裝此二軟體。此外，為了使安裝設定中的devtools運作，也請安裝[Rtools40](https://cran.r-project.org/bin/windows/Rtools/)。

### 下載AgriMap_TW與安裝相關package
打包下載整個AgriMap_TW專案，載回的檔案應為整個資料夾，內部應有四個子資料夾、一個預設隱藏的資料夾(為.Rproj的使用者參數設定資料夾)、兩個Rscript檔，及"AgriMap_TW-0.2.Rproj"此專案檔，如圖1、圖2所示。

![](https://i.imgur.com/XuVx8ne.png)
圖1. AgriMap_TW專案，後方數字為版本號。
![](https://i.imgur.com/ZHRObkZ.png)
圖2. AgriMap_TW的專案結構。

雙擊「AgriMap_TW-0.2.Rproj」的Rstudio專案檔，透過Rstudio進入此專案。
![](https://i.imgur.com/Fs3jytl.png)
圖3. AgriMap_TW的Rstudio專案檔。

初次使用，請透過「File/Open File...」開啟同一個資料夾內的「setup.R」。

![](https://i.imgur.com/L2N1uSk.png)
圖4. 開啟「Open File...」功能。
![](https://i.imgur.com/e0WfIOw.png)
圖5. 選擇「setup.R」。

![](https://i.imgur.com/aebwy2s.png)
圖6. 「setup.R」的檔案內容。

執行「setup.R」的所有code，完成所需要的package的安裝。因為是用devtools安裝舊版本的package，過程需要Rtools40來重新編譯package，安裝時間會比一般安裝較久，請耐心等待。過程中若出現訊息詢問是否更新部分package，請選3.(皆不要)，方便控制環境，但若更新相依package應該也不至於有影響。

![](https://i.imgur.com/EBjYQl7.png)
圖7. 請輸入3.，並按下「Enter」。

※又或者，請開啟「main.R」。執行其中「Check the environment」的Block，也可以安裝好所需package。

![](https://i.imgur.com/FFr5KfA.png)
圖8. 執行「main.R」中的這個部分。

### 資料準備
本專案開發時，預設目的為製作各縣市農作物生產量之面量圖，若使用者想呈現他種資料只需將資料依據 Data/Template 內格式整理好，另存成.csv檔並置於Data資料夾內即可。

各縣市農作物生產量之資料可由[行政院農業委員會農糧署企劃組農情報告資源網](https://agr.afa.gov.tw/afa/afa_frame.jsp?fbclid=IwAR3BAfXkR34VfEKJnpdt9Is0t2PjVTvNcPsF-I-idkb1NKArNlMy5iWiLaU)下載。透過左方選單依序點選所需內容，即可載入該農作物的資料，
> - 農情調查資訊查詢
> -- 一般作物查詢
> --- 各項作物規模別排序查詢(全部鄉鎮)
#載入該網頁時,javascript會運作較長一段時間，跑完後才可正常查詢。

### 參數設定

![](https://i.imgur.com/GP5jTvQ.png)
圖9. 在「Set parameters」的Block中可以設定一些參數。相關細節寫於「main.R」中，使用者可以自行查閱。

### 出圖
確認相關packages已正常安裝，且設定好參數後，請執行第45行以下的全部程式碼。

![](https://i.imgur.com/ILbBJAq.png)
圖10. 此行以下請選取後執行。

![](https://i.imgur.com/1lJ1S9W.png)
圖11. 所有輸出結果會儲存於「Results」資料夾中。

![](https://i.imgur.com/tjbNaGs.png)
圖12. 順利輸出面量圖。

## Further Reading
* Lovelace, Robin, Jakub Nowosad and Jannes Muenchow (2019). Geocomputation with R. The R Series. CRC Press.
本專案參考此書內容所製作，Code細節可以參考這本開源書籍。此書[網路版頁面](https://geocompr.robinlovelace.net/)在此。


## Acknowledgment
謝謝 廖一璋(Liao, Yi Chang)學長 啟發我製作這個專案的點子。

## Version Change Log
* 2020/07/22-10:49 完成Version1.0及使用說明。




:::info
**Find this document incomplete?** Leave a comment!
:::

###### tags: `GIS` `Documentation` `Agriculture` `Choropleth Map`
