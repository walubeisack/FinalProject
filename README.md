# Leveraging Geospatial Data for Targeted Food Security Planning in the Tigray Region, Ethiopia
The Tigray region of Ethiopia faces significant challenges regarding food security, exacerbated by factors such as internal conflicts, climate variability, land degradation, and socio-economic disparities. According to Oxfam, about 3.5 million people in this region are facing acute hunger and need immediate food assistance (Oxfam, 2024).  Additionally, food shortages are a major problem facing this population, and the extent of this problem is likely to increase through 2024 (ibid.). In response to these challenges, this project aims to employ advanced geospatial techniques, such as network analysis to develop a strategy for addressing food insecurity in the region. By integrating diverse datasets, including population statistics, settlements, markets, and roads in Tigray, this project will be able to provide a detailed picture of the food accessibility landscape in this traditionally underserved region.

## Objectives
1.	To analyze the accessibility of markets for the population of the Tigray region by calculating the distance between the markets and settlements.
2.	To identify the nearest food markets for settlements in underserved areas in the Tigray region and determine the average distance to the nearest market.
3.	To access the spatial distribution and extent of agricultural land in the region.


## Data Acquisition, Processing, & Database Setup
▪	Vector Data
1.	Level 3 Administrative boundaries (woreda) 2021 [(https://data.humdata.org/dataset/cod-ab-eth?)]
2.	Ethiopia Settlements 2018 [https://www.ethiogis-mapserver.org/dataDownload.php]
3.	Roads 2018 [https://www.ethiogis-mapserver.org/dataDownload.php]
4.	Ethiopia Subnational Population Statistics 2022 [https://data.humdata.org/dataset/cod-ps-eth]
5.	Ethiopia Markets 2020 [(https://data.kimetrica.com/dataset/ethiopia-markets)]

▪	Raster Data
1.	Ethiopia's land cover [(https://code.earthengine.google.com/3592b075f0441e86b67aa80946377869)]


### Data Processing
The Ethiopia markets dataset was downloaded from Kimetrica Data as a csv file, and using ArcGIS Pro XY table to point tool, the markets were added onto the map, then clipped to remain with markets in the Tigray region using the clip tool. 

Demographics data, Ethiopia Subnational Population Statistics 2022 contains data regarding population statistics. The dataset was downloaded from the Ethiopia Data grid via Humanitarian Data Exchange. The original dataset contained the entire nation data (Ethiopia) it was therefore clipped down to the Tigray region using ArcGIS Pro. 
Level 3 Administrative boundaries (woredas) dataset was also downloaded from the same source and clipped to remain with data attributed to the Tigray region on ArcGIS Pro.
All the data layers were reprojected to WGQ 1984 UTM Zone 37N on ArcGIS Pro. 
Land cover data was downloaded and processed from ESA World Land Cover (10m) to Google Drive using Google Earth Engine using the code below.   

```
var dataset = ee.ImageCollection('ESA/WorldCover/v200').first();
var clippedDataset = dataset.clip(Tigray);

// Define a custom color palette
var customPalette = [
  '006400', // Tree cover
  'ffbb22', // Shrubland
  'ffff4c', // Grassland
  '7fff00', // Cropland (changed to light green)
  'fa0000', // Built-up
  'b4b4b4', // Bare / sparse vegetation
  'f0f0f0', // Snow and ice
  '0064c8', // Permanent water bodies
  '0096a0', // Herbaceous wetland
  '00cf75', // Mangroves
  'fae6a0'  // Moss and lichen
];

// Define visualization parameters
var visualization = {
  bands: ['Map'], // Use the 'Map' band
  min: 0, // Minimum value of land cover classes
  max: 100, // Maximum value of land cover classes
  palette: customPalette // Apply the custom color palette
};

// Add the clipped dataset to the map with the custom visualization parameters
Map.centerObject(Tigray);
Map.addLayer(clippedDataset, visualization, 'Landcover');

Export.image.toDrive({
  image: clippedDataset,
  folder: 'Landcover',
  description: 'image_export',
  scale: 10,
  maxPixels: 1207780470,
  region:Tigray
});
```
The exported tiff file was then downloaded and added to ArcGIS pro to define projection, and clip to remain with land cover in the Tigray region only.

A final project database 'FoodSecurity' was created using pgadmin. All the sql queries and analysis will be stored on this database. 


### Data layers
 *Study Area*

![image](https://github.com/walubeisack/FinalProject/assets/165956747/32ab70fd-3ed3-4b77-9ffb-7fd6ae7e33ba)



### Spatial Data and Normalization
The final polygon and point shapefiles were imported into the database through the command prompt using the command lines below:
Woredas are level 3 of Ethipia's administrative system with the country as the highest, at level 1.

shp2pgsql -s 32637 -I Database\Data\Woredas.shp public.Woredas > Database\Data\sql_tables\Woredas.sql 
psql -U postgres -d FoodSecurity -f Database\Data\sql_tables\Woredas.sql

Markets

shp2pgsql -s 32637 -I Database\Data\Markets.shp public.Markets > Database\Data\sql_tables\Markets.sql
psql -U postgres -d FoodSecurity -f Database\Data\sql_tables\Markets.sql

Settlements

shp2pgsql -s 32637 -I Database\Data\Markets.shp public.woredas > Database\Data\sql_tables\Settlements.sql
psql -U postgres -d FoodSecurity -f Database\Data\sql_tables\Settlements.sql

Tigray land cover

raster2pgsql -s 4326 -t 1000x1000 -I -C -M Database\FinalProject\FinalProject\FinalProject_ARCPRO\Tigray_Clip.tif > Database\Data\sql_tables\LandCover.sql
psql -U postgres -d FoodSecurity -f Database\Data\sql_tables\LandCover.sql



*Tables*
![image](https://github.com/walubeisack/FinalProject/assets/165956747/6b73a80a-f8e7-4d8b-b6bb-807ff08e2846)

All the tables were in 1NF already but had redundant columns that will not be used in the analysis. New tables with data to used for analysis were created;

**Woredas table**

```
CREATE TABLE Woredas_clean(
	gid int PRIMARY KEY,
	adm3_en VARCHAR(255),
	adm2_en VARCHAR(255),
	shape_area numeric,
	shape_leng numeric,
	geom GEOMETRY
);
-- populate the new table with columns
INSERT INTO Woredas_clean(gid, shape_leng, shape_area, adm3_en, adm2_en, geom)
SELECT gid, shape_leng, shape_area, adm3_en, adm2_en, geom
FROM woredas;
```
This SQL query deleted the columns; country and region from the Woredas table to remain with relevant data. 


**Settlements table**

A new table 'settlements_clean' was created and populated using the script below. 

```
CREATE TABLE settlements_clean(
	objectid int PRIMARY KEY,
	poptot numeric,
	hierarchy VARCHAR(255),
	utm_z numeric,
	easting numeric,
	northing numeric,
	geom GEOMETRY
);
-- populate the new table with columns
INSERT INTO settlements_clean(objectid, hierarchy, poptot, utm_z, easting, northing, geom)
SELECT objectid, hierarchy, poptot, utm_z, easting, northing, geom
FROM settlements;

```
**Markets table**

```
CREATE TABLE markets_clean(
	gid int PRIMARY KEY,
	market VARCHAR(255),
	zone VARCHAR(255),
	latitude numeric,
	longitude numeric,
	geom GEOMETRY
);
-- populate the new table with columns
INSERT INTO markets_clean(gid, market, zone, latitude, longitude, geom)
SELECT gid, market, zone, latitude,longitude,  geom
FROM markets;
```

*Original and updated tables*

![image](https://github.com/walubeisack/FinalProject/assets/165956747/802616d4-600a-4cf4-86a7-d512cad7f39b)













