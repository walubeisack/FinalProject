# Leveraging Geospatial Data to Analyze the Impact of Conflicts on Food Security in the Tigray Region, Ethiopia
## 1.0 Introduction
The Tigray region of Ethiopia faces significant challenges regarding food security, exacerbated by factors such as internal conflicts, climate variability, land degradation, and socio-economic disparities. According to Oxfam, about 3.5 million people in this region are facing acute hunger and need immediate food assistance (Oxfam, 2024).  Additionally, food shortages are a major problem facing this population, and the extent of this problem is likely to increase through 2024 (ibid.). In response to these challenges, this project aims to employ advanced geospatial techniques, such as network analysis to develop a strategy for addressing food insecurity in the region. By integrating diverse datasets, including population statistics, settlements, markets, and roads in Tigray, this project will be able to provide a detailed picture of the food accessibility landscape in this traditionally underserved region.


### 1.1 Objectives
1.	To analyze the accessibility of markets for the population of the Tigray region by calculating the distance between the markets and settlements.
2.	To identify the nearest food markets for settlements in underserved areas in the Tigray region and determine the average distance to the nearest market.
3.	To access the spatial distribution and extent of agricultural land in the region.



## 2.0 Data Acquisition, Processing, & Database Setup
▪	Vector Data
1.	Level 3 Administrative boundaries (woreda) 2021 [(https://data.humdata.org/dataset/cod-ab-eth?)]
2.	Ethiopia Settlements 2020 [https://www.ethiogis-mapserver.org/dataDownload.php]
3.	Ethiopia Subnational Population Statistics 2022 [https://data.humdata.org/dataset/cod-ps-eth]
4.	Ethiopia Markets 2020 [(https://data.kimetrica.com/dataset/ethiopia-markets)]

▪	Raster Data
1.	Ethiopia's land cover [(https://code.earthengine.google.com/3592b075f0441e86b67aa80946377869)]



### 2.1 Data Processing
The Ethiopia markets dataset was downloaded from Kimetrica Data as a csv file, and using ArcGIS Pro XY table to point tool, the markets were added onto the map, then clipped to remain with markets in the Tigray region using the clip tool. 

Demographics data, Ethiopia Subnational Population Statistics 2022 contains data regarding population statistics. The dataset was downloaded from the Ethiopia Data grid via Humanitarian Data Exchange. The original dataset contained the entire nation data (Ethiopia) it was therefore clipped down to the Tigray region using ArcGIS Pro. 
Level 3 Administrative boundaries (woredas) dataset was also downloaded from the same source and clipped to remain with data attributed to the Tigray region on ArcGIS Pro.
All the data layers were reprojected to WGQ 1984 UTM Zone 37N on ArcGIS Pro. 
Land cover data was downloaded and processed from ESA World Land Cover (10m) to Google Drive using Google Earth Engine using the code below.   
a rectangular polygon around the Tigray region was created. As exhibited in the code, the land cover data was clipped to remain with data attributed to the Tigray region extent.

```JAVA
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

The exported tiff file was then downloaded from Google Drive and added to ArcGIS Pro to define projection, and clip to remain with land cover in the Tigray region only.

![image](https://github.com/walubeisack/FinalProject/assets/165956747/bc52d797-c058-40bb-a208-84a75ac11fac)


A final project database 'FoodSecurity' was created using pgadmin. All the sql queries and analysis will be stored on this database. 


### 2.2 Data layers
 *Study Area*

![image](https://github.com/walubeisack/FinalProject/assets/165956747/32ab70fd-3ed3-4b77-9ffb-7fd6ae7e33ba)




## 3.0 Spatial Data and Normalization
The final polygon and point shapefiles from ArcGIS Pro were imported into the database through the command prompt using the command lines below:

**Woredas** are level 3 of Ethipia's administrative system with the country as the highest, at level 1.

shp2pgsql -s 4326 -I Database\Data\Woredas.shp public.Woredas > Database\Data\sql_tables\Woredas.sql 

psql -U postgres -d FoodSecurity -f Database\Data\sql_tables\Woredas.sql

**Markets**

shp2pgsql -s 4326 -I Database\Data\Markets.shp public.Markets > Database\Data\sql_tables\Markets.sql

psql -U postgres -d FoodSecurity -f Database\Data\sql_tables\Markets.sql

**Settlements**

shp2pgsql -s 4326 -I Database\Data\Markets.shp public.woredas > Database\Data\sql_tables\Settlements.sql

psql -U postgres -d FoodSecurity -f Database\Data\sql_tables\Settlements.sql

**Tigray land cover**

raster2pgsql -s 4326 -t 1000x1000 -I -C -M Database\FinalProject\FinalProject\FinalProject_ARCPRO\Tigray_Clip.tif > Database\Data\sql_tables\LandCover.sql

psql -U postgres -d FoodSecurity -f Database\Data\sql_tables\LandCover.sql



*Tables*

![image](https://github.com/walubeisack/FinalProject/assets/165956747/6b73a80a-f8e7-4d8b-b6bb-807ff08e2846)

### 3.1 Normalization

All the tables were already in 1NF but had redundant columns that would not be used in the analysis. New tables  with data to be used for analysis were therefore created as follows;


**Woredas table** 
```SQL
CREATE TABLE woredas AS 
SELECT 	
	objectid,
	w_name AS woreda,
	z_name AS zone,
	total AS total_population,
	shape_area,
	shape_leng,
	geom GEOMETRY
FROM woredas_21;

```

![image](https://github.com/walubeisack/FinalProject/assets/165956747/e291b90d-b863-4dda-84bf-50eb418cf441)


**Settlements table**

A new table 'settlements_clean' was created and populated using the script below. 

```SQL
CREATE TABLE tigray_settlements AS 
SELECT 	
	objectid,
	hierarchy,
	utm_z,
	easting,
	northing,
	geom GEOMETRY
FROM settlements;

```

![image](https://github.com/walubeisack/FinalProject/assets/165956747/73d09111-12e0-4831-9106-6085b5599dea)




**Markets table**

```SQL
CREATE TABLE tigray_markets AS
SELECT
	gid ,
	market,
	zone,
	latitude,
	longitude,
	geom GEOMETRY
FROM markets;
```

![image](https://github.com/walubeisack/FinalProject/assets/165956747/c0c9ad54-2ae8-4174-92fe-2f1928437f4c)




**Restricted Areas**
```SQL
CREATE TABLE restricted_areas AS 
SELECT 	
	gid,
	adm3_en AS woreda,
	adm2_en AS zone,
	shape_area,
	shape_leng,
	geom GEOMETRY
FROM access;
```

![image](https://github.com/walubeisack/FinalProject/assets/165956747/6194bcf3-49e4-4c9e-bc5e-f707d91a707f)



All these queries create new tables populated with data from the original tables.




## 3.1 Analysis

To find out the number of settlements close to the markets, 12km buffers were created around markets

```SQL
CREATE TABLE market_buffers AS
SELECT 
    tigray_markets.gid,
    ST_Buffer(tigray_markets.geometry, 12000) AS buffer_geom -- 12 km buffer
FROM tigray_markets;

-- An index on the buffered geometries for faster spatial operations
CREATE INDEX market_buffers_geom_idx ON market_buffers USING GIST (buffer_geom);

--Dissolve the buffers
CREATE TABLE dissolved_buffers AS
SELECT ST_Union(buffer_geom) AS dissolved_buffer
FROM market_buffers;

```

![12km_buffer](https://github.com/walubeisack/FinalProject/assets/165956747/4002f33e-f9bd-4f72-b150-8f0ac39ca70c)


The settlements within the buffer were counted using the following query;

```SQL
-- Count settlements within each buffer
SELECT 
    SUM(number_of_settlements) AS total_settlements
FROM (
SELECT market_buffers.gid,
COUNT(tigray_settlements.objectid) AS settlements_within_buffer
FROM market_buffers
LEFT JOIN tigray_settlements ON ST_Within(tigray_settlements.geometry, market_buffers.buffer_geom)
GROUP BY market_buffers.gid
) AS subquery;

```

We had earlier talked about the hard-to-reach areas, we would therefore like to find out how many markets and settlements are in hard-to-reach areas.


![Hard_to_Reach_areas](https://github.com/walubeisack/FinalProject/assets/165956747/adfe9333-b9ec-4af0-aecd-c8baefdffdba)

### Markets
```SQL
-- Number of Markets in the restricted /hard to reach areas by woreda

SELECT restricted_areas.woreda AS woreda, COUNT(tigray_markets.gid) AS number_of_markets
FROM restricted_areas
LEFT JOIN tigray_markets ON ST_Within(tigray_markets.geometry, restricted_areas.geometry)
GROUP BY restricted_areas.woreda
order by number_of_markets desc;

```

![markets_in_restricted_areas](https://github.com/walubeisack/FinalProject/assets/165956747/de6606fe-4912-46bb-97a0-11f3c4e10257)


![image](https://github.com/walubeisack/FinalProject/assets/165956747/75f9dab1-61ef-4181-bdb9-1e4598794b31)




### Settlements

```SQL
-- Settlements in the restricted /hard to reach areas by woreda
SELECT restricted_areas.woreda AS woreda, COUNT(tigray_settlements.objectid) AS number_of_settlements
FROM restricted_areas
LEFT JOIN tigray_settlements ON ST_Within(tigray_settlements.geometry, restricted_areas.geometry)
GROUP BY restricted_areas.woreda
order by number_of_settlements desc;

-- Number of Settlements in the restricted /hard to reach areas by woreda

SELECT 
    SUM(number_of_settlements) AS total_settlements
FROM (
   SELECT restricted_areas.woreda AS woreda, COUNT(tigray_settlements.objectid) AS number_of_settlements
FROM restricted_areas
LEFT JOIN tigray_settlements ON ST_Within(tigray_settlements.geometry, restricted_areas.geometry)
GROUP BY restricted_areas.woreda
order by number_of_settlements desc
) AS subquery;
```


![Settlements_in_restricted_areas](https://github.com/walubeisack/FinalProject/assets/165956747/6e3716eb-12d6-4869-9977-267f27065133)


![image](https://github.com/walubeisack/FinalProject/assets/165956747/ad4caf85-307d-40c5-84a5-86ec0311a8bb)


![image](https://github.com/walubeisack/FinalProject/assets/165956747/1eaff7ab-14de-4f06-aa94-358e49a4dd19)


### Landcover data

The average landcover value by woreda was obtained by;
```SQL
SELECT woredas.woreda, AVG((ST_SummaryStats(ST_Clip(rast.rast, woredas.geometry, TRUE))).mean) AS avg_lc2		
FROM public.tigray_lc2 AS rast, 
public.woredas AS woredas		 
WHERE ST_Intersects(rast.rast, woredas.geometry)		
GROUP BY woredas.woreda;
```

![image](https://github.com/walubeisack/FinalProject/assets/165956747/a2ff33ae-b506-4f1a-93f1-68f5aa55f9e4)


The average landcover value in the restricted areas by woreda was obtained by;

```SQL
SELECT restricted_areas.woreda, 
AVG((ST_SummaryStats(ST_Clip(rast.rast, restricted_areas.geometry, TRUE))).mean) AS avg_lc2		
public.restricted_areas AS restricted_areas		 
WHERE ST_Intersects(rast.rast, restricted_areas.geometry)		
GROUP BY restricted_areas.woreda;
```

![LC_in_Restricted_areas](https://github.com/walubeisack/FinalProject/assets/165956747/a2e32538-af08-4d29-b4bd-bf40d5bc1a5a)


![average_landcover_values_in_redzone](https://github.com/walubeisack/FinalProject/assets/165956747/c976ddae-465b-4c5c-ae20-1bdd479590be)


I am yet to find out how much cropland is in the the restricted area compared to cropland in restricted areas.
I made a land cover types and pixels count table using;

```SQL
CREATE TABLE lc_pixels AS
SELECT
    (ST_ValueCount(rast)).value AS land_cover_type,
    (ST_ValueCount(rast)).count AS number_of_pixels
FROM
    tigray_lc2;
```

![image](https://github.com/walubeisack/FinalProject/assets/165956747/dd2172ec-cc55-42dd-95bf-b02096f7103b)


compared the land_cover classes with the defined classes from the data source

![image](https://github.com/walubeisack/FinalProject/assets/165956747/bd4cbd62-c7ce-4d2d-9a38-db406089cbc3)


cropland is represented by value '40', and a table containing cropland values was created

```SQL
CREATE TABLE cropland AS
SELECT *
FROM pixels
WHERE land_cover_type = 40;
```

![image](https://github.com/walubeisack/FinalProject/assets/165956747/404e9d3b-4f5d-49ec-a3cf-6bc4d95bbcd1)









































