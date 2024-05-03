# Leveraging Geospatial Data to Analyze the Impact of Conflicts on Food Security in the Tigray Region, Ethiopia
## 1.0 Introduction
The Tigray region of Ethiopia faces significant challenges regarding food security, exacerbated by factors such as internal conflicts, climate variability, land degradation, and socio-economic disparities. According to Oxfam, about 3.5 million people in this region are facing acute hunger and need immediate food assistance (Oxfam, 2024).  Additionally, food shortages are a major problem facing this population, and the extent of this problem is likely to increase through 2024 (ibid.). In response to these challenges, this project aims to employ advanced geospatial techniques, such as network analysis to develop a strategy for addressing food insecurity in the region. By integrating diverse datasets, including population statistics, settlements, markets, and roads in Tigray, this project will be able to provide a detailed picture of the food accessibility landscape in this traditionally underserved region.
Internal conflicts in Ethiopia are attributed to the former ruling party, Tigray People's Liberation Party(TPLF) fighting against the Ethiopian government over political and ethnic matters causing a severe humanitarian crisis in the region. 

### 1.1 Objectives
1.	To analyze the accessibility of markets for the population of the Tigray region by calculating the distance between the markets and settlements.
2.	To identify the nearest food markets for settlements in underserved areas in the Tigray region and determine the average distance to the nearest market.
3.	To access the spatial distribution and extent of agricultural land in the region.
   


   	*Study Area*
  	
![Study_area](https://github.com/walubeisack/FinalProject/assets/165956747/a6813eef-588a-487d-beb3-d05ade710c6f)




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


A final project database 'FoodSecurity' was created using pgadmin. All the tables used for analysis will be stored on this database. 


### 2.2 Data layers
 *Study Area*

![image](https://github.com/walubeisack/FinalProject/assets/165956747/32ab70fd-3ed3-4b77-9ffb-7fd6ae7e33ba)




## 3.0 Spatial Data and Normalization
The final polygon and point shapefiles from ArcGIS Pro were imported into the database through the command prompt using the command lines below:

**Woredas** are level 3 of Ethipia's administrative system with the country as the highest, at level 1.

```SQL
shp2pgsql -s 4326 -I Database\Data\Woredas.shp public.Woredas > Database\Data\sql_tables\Woredas.sql

psql -U postgres -d FoodSecurity -f Database\Data\sql_tables\Woredas.sql
```

**Markets**

```SQL
shp2pgsql -s 4326 -I Database\Data\Markets.shp public.Markets > Database\Data\sql_tables\Markets.sql

psql -U postgres -d FoodSecurity -f Database\Data\sql_tables\Markets.sql

```
**Settlements**

```SQL
shp2pgsql -s 4326 -I Database\Data\Markets.shp public.woredas > Database\Data\sql_tables\Settlements.sql

psql -U postgres -d FoodSecurity -f Database\Data\sql_tables\Settlements.sql

```
**Tigray land cover**

```SQL
raster2pgsql -s 4326 -t 1000x1000 -I -C -M Database\FinalProject\FinalProject\FinalProject_ARCPRO\Tigray_Clip.tif > Database\Data\sql_tables\LandCover.sql

psql -U postgres -d FoodSecurity -f Database\Data\sql_tables\LandCover.sql
```



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

A new table 'tigray_settlements' was created and populated using the script below. 

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

![Settlements_in_buffers](https://github.com/walubeisack/FinalProject/assets/165956747/0db9ffd5-2b0f-42b6-86ad-8b7186bb50bb)


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



### What land cover types are in restricted areas?

### How much cropland is there in these Woredas?

Land_cover classes with defined bands from the data source

![image](https://github.com/walubeisack/FinalProject/assets/165956747/bd4cbd62-c7ce-4d2d-9a38-db406089cbc3)


STEP 1. Create a table containing landcover type and their pixel counts

```SQL
CREATE TABLE lc_pixels AS
SELECT
    (ST_ValueCount(rast)).value AS land_cover_type,
    (ST_ValueCount(rast)).count AS number_of_pixels
FROM
    tigray_lc2;
```

![image](https://github.com/walubeisack/FinalProject/assets/165956747/5ba23caf-a7eb-4b97-ba5c-3636f8d234bf)


Step 2. Create a new table to summarize land cover types

```SQL
CREATE TABLE landcover_summary(
landcover_type TEXT,
pixel_count INTEGER
);
INSERT INTO landcover_summary (landcover_type, pixel_count)
SELECT 
	CASE
		WHEN land_cover_type = 10 THEN 'Tree cover'
		WHEN land_cover_type = 20 THEN 'Shrubland'
		WHEN land_cover_type = 30 THEN 'Grassland'
		WHEN land_cover_type = 40 THEN 'Cropland'
		WHEN land_cover_type = 50 THEN 'Built-up'
		WHEN land_cover_type = 60 THEN 'Bare'
		WHEN land_cover_type = 70 THEN 'Snow and ice'
		WHEN land_cover_type = 80 THEN 'Permanent water bodies'
		WHEN land_cover_type = 90 THEN 'Herbaceous wetland'
		WHEN land_cover_type = 95 THEN 'Mangroves'
		WHEN land_cover_type = 100 THEN 'Moss and lichen'
		ELSE 'Other'
	END AS landcover_type,
	number_of_pixels AS pixel_count 
FROM
	(SELECT
	 	land_cover_type,
	 	number_of_pixels
	 FROM
	 	lc_pixels
	 ) AS v;
```

![image](https://github.com/walubeisack/FinalProject/assets/165956747/579316e4-9a75-4fe2-a2f3-c5f5507044aa)


Step 3. Create a new table containing the total pixel count for different landcover_types

```SQL
CREATE TABLE land_cover_summary AS
SELECT 
    landcover_type,
    SUM(pixel_count) AS total_pixel_count
FROM 
    landcover_summary
GROUP BY 
    landcover_type
ORDER BY total_pixel_count DESC;
```

![image](https://github.com/walubeisack/FinalProject/assets/165956747/e5907496-a76a-4d42-9c69-88670db347a1)


Step 4. Calculate the landcover area

-- Get total pixels, use to calculate area per pixel, total area for different landcover type
```SQL
CREATE TABLE landcover_area AS
WITH pixel_SUMMARY as (
	SELECT SUM(total_pixel_count) as total_pixels
	FROM landcover_summary
)
SELECT 
    SUM(ST_Area(rast::geometry::geography)) / (1000000.0 * total_pixels) AS area_per_pixel_sq_km,
    	(SELECT number_of_pixels FROM lc_pixels WHERE land_cover_type = 10)* SUM(ST_Area(rast::geometry::geography)) / (1000000.0 * total_pixels) AS total_area_treecover_sq_km,
	(SELECT number_of_pixels FROM lc_pixels WHERE land_cover_type = 20)* SUM(ST_Area(rast::geometry::geography)) / (1000000.0 * total_pixels) AS total_area_shrubland_sq_km,    
	(SELECT number_of_pixels FROM lc_pixels WHERE land_cover_type = 30)* SUM(ST_Area(rast::geometry::geography)) / (1000000.0 * total_pixels) AS total_area_grassland_sq_km,
	(SELECT number_of_pixels FROM lc_pixels WHERE land_cover_type = 40)* SUM(ST_Area(rast::geometry::geography)) / (1000000.0 * total_pixels) AS total_area_cropland_sq_km,
	(SELECT number_of_pixels FROM lc_pixels WHERE land_cover_type = 50)* SUM(ST_Area(rast::geometry::geography)) / (1000000.0 * total_pixels) AS total_area_builtup_sq_km,
	(SELECT number_of_pixels FROM lc_pixels WHERE land_cover_type = 60)* SUM(ST_Area(rast::geometry::geography)) / (1000000.0 * total_pixels) AS total_area_bare_sq_km,
	(SELECT number_of_pixels FROM lc_pixels WHERE land_cover_type = 70)* SUM(ST_Area(rast::geometry::geography)) / (1000000.0 * total_pixels) AS total_area_snow_ice_sq_km,
	(SELECT number_of_pixels FROM lc_pixels WHERE land_cover_type = 80)* SUM(ST_Area(rast::geometry::geography)) / (1000000.0 * total_pixels) AS total_area_permanentwaterb_sq_km,
	(SELECT number_of_pixels FROM lc_pixels WHERE land_cover_type = 90)* SUM(ST_Area(rast::geometry::geography)) / (1000000.0 * total_pixels) AS total_area_herbaceous_sq_km,
	(SELECT number_of_pixels FROM lc_pixels WHERE land_cover_type = 95)* SUM(ST_Area(rast::geometry::geography)) / (1000000.0 * total_pixels) AS total_area_mangroves_sq_km,	
	(SELECT number_of_pixels FROM lc_pixels WHERE land_cover_type = 100)* SUM(ST_Area(rast::geometry::geography)) / (1000000.0 * total_pixels) AS total_area_moss_lichen_sq_km
	FROM tigray_lc2, pixel_summary
GROUP BY total_pixels;
```

I encountered an error because my original raster file had multiple  rows with the same values, and there was no way of seeing the contents of the table after creation. 

![image](https://github.com/walubeisack/FinalProject/assets/165956747/5b4773f2-e4ea-454a-bf01-3da6185fd639)

Fixed the query by adding by adding 'sum' on the selected columns to return the total pixels fro each landcover type.

```SQL
CREATE TABLE tigraylandcover AS
WITH pixel_SUMMARY AS (
    SELECT SUM(total_pixel_count) AS total_pixels
    FROM redcover_summary
)
SELECT 
	-- Calculate total area covered by each land cover type in square kilometers
    (SELECT SUM(number_of_pixels) FROM lc_pixels WHERE land_cover_type = 10) * SUM(ST_Area(rast::geometry::geography)) / (1000000.0 * total_pixels) AS total_area_treecover_sq_km,
    (SELECT SUM(number_of_pixels) FROM lc_pixels WHERE land_cover_type = 20) * SUM(ST_Area(rast::geometry::geography)) / (1000000.0 * total_pixels) AS total_area_shrubland_sq_km,    
    (SELECT SUM(number_of_pixels) FROM lc_pixels WHERE land_cover_type = 30) * SUM(ST_Area(rast::geometry::geography)) / (1000000.0 * total_pixels) AS total_area_grassland_sq_km,
    (SELECT SUM(number_of_pixels) FROM lc_pixels WHERE land_cover_type = 40) * SUM(ST_Area(rast::geometry::geography)) / (1000000.0 * total_pixels) AS total_area_cropland_sq_km,
    (SELECT SUM(number_of_pixels) FROM lc_pixels WHERE land_cover_type = 50) * SUM(ST_Area(rast::geometry::geography)) / (1000000.0 * total_pixels) AS total_area_builtup_sq_km,
    (SELECT SUM(number_of_pixels) FROM lc_pixels WHERE land_cover_type = 60) * SUM(ST_Area(rast::geometry::geography)) / (1000000.0 * total_pixels) AS total_area_bare_sq_km,
    (SELECT SUM(number_of_pixels) FROM lc_pixels WHERE land_cover_type = 70) * SUM(ST_Area(rast::geometry::geography)) / (1000000.0 * total_pixels) AS total_area_snow_ice_sq_km,
    (SELECT SUM(number_of_pixels) FROM lc_pixels WHERE land_cover_type = 80) * SUM(ST_Area(rast::geometry::geography)) / (1000000.0 * total_pixels) AS total_area_permanentwaterb_sq_km,
    (SELECT SUM(number_of_pixels) FROM lc_pixels WHERE land_cover_type = 90) * SUM(ST_Area(rast::geometry::geography)) / (1000000.0 * total_pixels) AS total_area_herbaceous_sq_km,
    (SELECT SUM(number_of_pixels) FROM lc_pixels WHERE land_cover_type = 95) * SUM(ST_Area(rast::geometry::geography)) / (1000000.0 * total_pixels) AS total_area_mangroves_sq_km,    
    (SELECT SUM(number_of_pixels) FROM lc_pixels WHERE land_cover_type = 100) * SUM(ST_Area(rast::geometry::geography)) / (1000000.0 * total_pixels) AS total_area_moss_lichen_sq_km
FROM tigray_landcover, pixel_summary
GROUP BY total_pixels;
```
This table shows the ttal area fro each landcover type in Tigray region.

![image](https://github.com/walubeisack/FinalProject/assets/165956747/c7a0b299-f2d4-4eb8-b757-85a3184baf24)


*** 
### Switched focus onto the amount of cropland in restricted areas

Step 1. Created a table containing landcover in the restricted areas 

```SQL
CREATE TABLE redzone_cover(
landcover_type TEXT,
pixel_count INTEGER
);
INSERT INTO redzone_cover_ (landcover_type, pixel_count)
SELECT 
	CASE
		WHEN land_cover_type = 10 THEN 'Tree cover'
		WHEN land_cover_type = 20 THEN 'Shrubland'
		WHEN land_cover_type = 30 THEN 'Grassland'
		WHEN land_cover_type = 40 THEN 'Cropland'
		WHEN land_cover_type = 50 THEN 'Built-up'
		WHEN land_cover_type = 60 THEN 'Bare'
		WHEN land_cover_type = 70 THEN 'Snow and ice'
		WHEN land_cover_type = 80 THEN 'Permanent water bodies'
		WHEN land_cover_type = 90 THEN 'Herbaceous wetland'
		WHEN land_cover_type = 95 THEN 'Mangroves'
		WHEN land_cover_type = 100 THEN 'Moss and lichen'
		ELSE 'Other'
	END AS landcover_type,
	number_of_pixels AS pixel_count 
FROM
	(SELECT
	 	land_cover_type,
	 	number_of_pixels
	 FROM
	 	lc_pixels
	 ) AS v;
```

![image](https://github.com/walubeisack/FinalProject/assets/165956747/e859a2a5-2aab-4c91-ac19-056e2fe442b6)





Step 3. Create a new table containing the total area for different landcover_types in restricted areas

```SQL
CREATE TABLE redzone_cover_area AS
WITH pixel_SUMMARY AS (
    SELECT SUM(total_pixel_count) AS total_pixels
    FROM redcover_summary
)
SELECT 
	-- Calculate total area covered by each land cover type in square kilometers
    (SELECT SUM(number_of_pixels) FROM lc_pixels WHERE land_cover_type = 10) * SUM(ST_Area(rast::geometry::geography)) / (1000000.0 * total_pixels) AS total_area_treecover_sq_km,
    (SELECT SUM(number_of_pixels) FROM lc_pixels WHERE land_cover_type = 20) * SUM(ST_Area(rast::geometry::geography)) / (1000000.0 * total_pixels) AS total_area_shrubland_sq_km,    
    (SELECT SUM(number_of_pixels) FROM lc_pixels WHERE land_cover_type = 30) * SUM(ST_Area(rast::geometry::geography)) / (1000000.0 * total_pixels) AS total_area_grassland_sq_km,
    (SELECT SUM(number_of_pixels) FROM lc_pixels WHERE land_cover_type = 40) * SUM(ST_Area(rast::geometry::geography)) / (1000000.0 * total_pixels) AS total_area_cropland_sq_km,
    (SELECT SUM(number_of_pixels) FROM lc_pixels WHERE land_cover_type = 50) * SUM(ST_Area(rast::geometry::geography)) / (1000000.0 * total_pixels) AS total_area_builtup_sq_km,
    (SELECT SUM(number_of_pixels) FROM lc_pixels WHERE land_cover_type = 60) * SUM(ST_Area(rast::geometry::geography)) / (1000000.0 * total_pixels) AS total_area_bare_sq_km,
    (SELECT SUM(number_of_pixels) FROM lc_pixels WHERE land_cover_type = 70) * SUM(ST_Area(rast::geometry::geography)) / (1000000.0 * total_pixels) AS total_area_snow_ice_sq_km,
    (SELECT SUM(number_of_pixels) FROM lc_pixels WHERE land_cover_type = 80) * SUM(ST_Area(rast::geometry::geography)) / (1000000.0 * total_pixels) AS total_area_permanentwaterb_sq_km,
    (SELECT SUM(number_of_pixels) FROM lc_pixels WHERE land_cover_type = 90) * SUM(ST_Area(rast::geometry::geography)) / (1000000.0 * total_pixels) AS total_area_herbaceous_sq_km,
    (SELECT SUM(number_of_pixels) FROM lc_pixels WHERE land_cover_type = 95) * SUM(ST_Area(rast::geometry::geography)) / (1000000.0 * total_pixels) AS total_area_mangroves_sq_km,    
    (SELECT SUM(number_of_pixels) FROM lc_pixels WHERE land_cover_type = 100) * SUM(ST_Area(rast::geometry::geography)) / (1000000.0 * total_pixels) AS total_area_moss_lichen_sq_km
FROM tigray_landcover, pixel_summary
GROUP BY total_pixels;

```

![image](https://github.com/walubeisack/FinalProject/assets/165956747/8d791f7c-048d-499c-a283-0d8d05be57bf)



Step 4. Created a new table showing the percentage area of different land cover types in the restricted areas.

```SQL
CREATE TABLE "Percent_landcover_Area" AS
 SELECT "Columns","Values"*100/(SELECT SUM("Values") FROM land_cover_area)
 FROM "Redzonelandcover_Area"
 WHERE "Columns" IS NOT NULL AND "Values" IS NOT NULL
 Order by "Values" desc;
```


![image](https://github.com/walubeisack/FinalProject/assets/165956747/b4b27aff-4d2e-4fa6-ae86-4a609d81261f)


From the table, 25% of the land cover in the restricted area is cropland. There is no standard percent to benchmark sufficient  cropland for subsistence or commercial farming since such  standards would depend on population density, agricultural productivity, land distribution policies, and environmental considerations. However, as a general guideline, a country aiming for food security and self-sufficiency like Ethiopia might target a significant portion of arable land available for cultivation by its residents.


### Challenges
There is a somewhat limited level of detail in available data (empty columns). my primary focus was to use the lowest administrative units in the Ethiopia administrative system, but the datasets at that level were now sufficient.

This analysis provides a basic analysis of food accessibility in the region, it is important to acknowledge that there are more places to purchase food than the 47 markets mapped.

There were difficulties in filtering raster data to remain with cropland only. The layer was inseparable after uploading the data. 

### Future works







