# Leveraging Geospatial Data and Network Analysis for Targeted Food Security Planning in the Tigray Region, Ethiopia
The Tigray region of Ethiopia faces significant challenges regarding food security, exacerbated by factors such as internal conflicts, climate variability, land degradation, and socio-economic disparities. According to Oxfam, about 3.5 million people in this region are facing acute hunger and need immediate food assistance (Oxfam, 2024).  Additionally, food shortages are a major problem facing this population, and the extent of this problem is likely to increase through 2024 (ibid.). In response to these challenges, this project aims to employ advanced geospatial techniques, such as network analysis to develop a strategy for addressing food insecurity in the region. By integrating diverse datasets, including population statistics, settlements, markets, and roads in Tigray, this project will be able to provide a detailed picture of the food accessibility landscape in this traditionally underserved region.

## Objectives
1.	To analyze the accessibility of markets for the population of the Tigray region by calculating the distance between the markets and settlements.
2.	To identify the nearest food markets for settlements in underserved areas in the Tigray region and determine the average distance to the nearest market.
3.	To access the spatial distribution and extent of agricultural land in the region.


## Data Acquisition, Processing, & Database Setup
▪	Vector Data
1.	Level 3 Administrative boundaries (woreda) 2021 [https://data.humdata.org/dataset/cod-ps-eth]
2.	Ethiopia Settlements 2018 [https://www.ethiogis-mapserver.org/dataDownload.php]
3.	Roads 2018 [https://www.ethiogis-mapserver.org/dataDownload.php]
4.	Ethiopia Subnational Population Statistics 2022 [https://data.humdata.org/dataset/cod-ps-eth]
5.	Ethiopia Markets 2020 [(https://data.kimetrica.com/dataset/ethiopia-markets)]

▪	Raster Data
1.	Ethiopia's land cover [https://code.earthengine.google.com/?scriptPath=Examples%3ADatasets%2FGOOGLE%2FGOOGLE_DYNAMICWORLD_V1]


### Data Processing
The Ethiopia markets dataset was downloaded from Kimetrica Data, and using ArcGIS pro, the markets in Tigray were selected and exported. 

Demographics data, Ethiopia Subnational Population Statistics 2022 contains data regarding population statistics. The dataset was downloaded from the Ethiopia Data grid via Humanitarian Data exchange. The original dataset contained the entire nation data (Ethiopia) it was therefore clipped down to the Tigray region using ArcGIS Pro. 
Level 3 Administrative boundaries (woredas) dataset was also downloaded from the same source and clipped to remain with data attributed to the Tigray region on ArcGIS Pro.

### Data layers

![image](https://github.com/walubeisack/FinalProject/assets/165956747/32ab70fd-3ed3-4b77-9ffb-7fd6ae7e33ba)


### Spatial queries

SELECT settlement_id, market_id, MIN(ST_Distance(settlements(geometry), market(geometry)) AS distance
FROM settlements_data
CROSS JOIN markets_data
GROUP BY settlement_id;

SELECT 
    land_cover_type,
    ST_AsText(land_cover_type(geometry)) AS land_cover_geometry,
    ST_Area(land_cover_type(geometry)) AS land_area
FROM 
    land_cover_data
WHERE 
    land_cover_type = 'Agricultural';
