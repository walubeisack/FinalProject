# Leveraging Geospatial Data and Network Analysis for Targeted Food Security Planning in the Tigray Region, Ethiopia
## Objectives
1.	To analyze the accessibility of markets for the population of the Tigray region by calculating the distance between the markets and settlements.
2.	To access the spatial distribution and extent of agricultural land in the region

## Data Acquisition, Processing, & Database Setup
▪	Vector Data
1.	Level 3 Administrative boundaries (woreda) 2021
2.	Ethiopia Settlements 2018
3.	Roads 2018
4.	Ethiopia Subnational Population Statistics 2022
5.	Ethiopia Markets 2020

▪	Raster Data
1.	Ethiopia's land cover


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
