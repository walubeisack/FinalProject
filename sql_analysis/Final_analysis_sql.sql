-- Create the initial database
CREATE DATABASE FoodSecurity;

-- Connect to the database
\c FoodSecurity;

-- Create spatial extensions
CREATE EXTENSION POSTGIS;
CREATE EXTENSION POSTGIS_RASTER;

-- Upload the shapefiles
Woredas
shp2pgsql -s 4326 -I Database\Data\Woredas.shp public.Woredas > Database\Data\sql_tables\Woredas.sql
psql -U postgres -d FoodSecurity -f Database\Data\sql_tables\Woredas.sql

Markets
shp2pgsql -s 4326 -I Database\Data\Markets.shp public.Markets > Database\Data\sql_tables\Markets.sql
psql -U postgres -d FoodSecurity -f Database\Data\sql_tables\Markets.sql

Settlements
shp2pgsql -s 4326 -I Database\Data\Markets.shp public.woredas > Database\Data\sql_tables\Settlements.sql
psql -U postgres -d FoodSecurity -f Database\Data\sql_tables\Settlements.sql

Tigray land cover
raster2pgsql -s 4326 -t 1000x1000 -I -C -M Database\FinalProject\FinalProject\FinalProject_ARCPRO\Tigray_Clip.tif > Database\Data\sql_tables\LandCover.sql
psql -U postgres -d FoodSecurity -f Database\Data\sql_tables\LandCover.sql


--tables created for analysis
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

CREATE TABLE tigray_settlements AS 
SELECT 	
	objectid,
	hierarchy,
	utm_z,
	easting,
	northing,
	geom GEOMETRY
FROM settlements;

CREATE TABLE tigray_markets AS
SELECT
	gid,
	market,
	zone,

CREATE TABLE restricted_areas AS 
SELECT 	
	gid,
	adm3_en AS woreda,
	adm2_en AS zone,
	shape_area,
	shape_leng,
	geom GEOMETRY
FROM hard_reach_areas;

--ANALYSIS

-- 12km buffers around the markets
CREATE TABLE market_buffers AS
SELECT 
    tigray_markets.gid,
    ST_Buffer(tigray_markets.geometry, 12000) AS buffer_geom -- 12 km buffer
FROM tigray_markets;

-- Create an index on the buffered geometries for faster spatial operations
CREATE INDEX market_buffers_geom_idx ON market_buffers USING GIST (buffer_geom);

--Dissolve the buffers
CREATE TABLE dissolved_buffers AS
SELECT ST_Union(buffer_geom) AS dissolved_buffer
FROM market_buffers;

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

--number of markets in the restricted area
SELECT restricted_areas.woreda AS woreda, COUNT(tigray_markets.gid) AS number_of_markets
FROM restricted_areas
LEFT JOIN tigray_markets ON ST_Within(tigray_markets.geometry, restricted_areas.geometry)
GROUP BY restricted_areas.woreda
order by number_of_markets desc;

-- Number of Settlements in the restricted /hardtoreach areas
SELECT restricted_areas.woreda AS woreda, COUNT(tigray_settlements.objectid) AS number_of_settlements
FROM restricted_areas
LEFT JOIN tigray_settlements ON ST_Within(tigray_settlements.geometry, restricted_areas.geometry)
GROUP BY restricted_areas.woreda
order by number_of_settlements desc;

--Total number of settlements in restricted areas
SELECT 
    SUM(number_of_settlements) AS total_settlements
FROM (
   SELECT restricted_areas.woreda AS woreda, COUNT(tigray_settlements.objectid) AS number_of_settlements
FROM restricted_areas
LEFT JOIN tigray_settlements ON ST_Within(tigray_settlements.geometry, restricted_areas.geometry)
GROUP BY restricted_areas.woreda
order by number_of_settlements desc
) AS subquery;

--WORKING WITH RASTER DATA (landcover dataset)
--Average pixel count in different woredas
SELECT woredas.woreda, AVG((ST_SummaryStats(ST_Clip(rast.rast, woredas.geometry, TRUE))).mean) AS avg_lc2		
FROM public.tigray_lc2 AS rast, 
public.woredas AS woredas		 
WHERE ST_Intersects(rast.rast, woredas.geometry)		
GROUP BY woredas.woreda;


-- CLip landcover to remain with landcover values from  restricted areas only
SELECT restricted_areas.woreda, AVG((ST_SummaryStats(ST_Clip(rast.rast, restricted_areas.geometry, TRUE))).mean) AS avg_lc2		
FROM public.tigray_lc2 AS rast, 
public.restricted_areas AS restricted_areas		
WHERE ST_Intersects(rast.rast, restricted_areas.geometry)		
GROUP BY restricted_areas.woreda;		


-- Create a table containing landcover type and their pixel counts
CREATE TABLE lc_pixels AS
SELECT
    (ST_ValueCount(rast)).value AS land_cover_type,
    (ST_ValueCount(rast)).count AS number_of_pixels
FROM
    tigray_lc2;

--create a new table to summarize land cover types
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


-- Create a new table containing the total pixel count for different landcover_types
CREATE TABLE land_cover_summary AS
SELECT 
    landcover_type,
    SUM(pixel_count) AS total_pixel_count
FROM 
    landcover_summary
GROUP BY 
    landcover_type
ORDER BY total_pixel_count DESC;

-- Calculate the landcover area
-- Get total pixels, use to calculate area per pixel, total area for different landcover type
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


--switched focus onto the restricted area

--
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

-- Create a new table containing the total pixel count for different landcover_types in restricted areas
CREATE TABLE redzone_cover_summary AS
SELECT 
    landcover_type,
    SUM(pixel_count) AS total_pixel_count
FROM 
    redzone_cover
GROUP BY 
    landcover_type
ORDER BY total_pixel_count DESC;


--Created a new table containing a new column 'pixel percentage'
CREATE TABLE redcover_summary AS
SELECT 
    landcover_type,
    SUM(pixel_count) AS total_pixel_count,
    (SUM(pixel_count) * 100.0 / (SELECT SUM(pixel_count) FROM redzone_cover_summary)) AS pixel_percentage
FROM 
    redzone_cover_summary
GROUP BY 
    landcover_type
ORDER BY total_pixel_count DESC;

