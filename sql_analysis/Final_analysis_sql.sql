-- Create the initial database
CREATE DATABASE FoodSecurity;


-- Connect to the database
\c FoodSecurity;


-- Create spatial extensions
CREATE EXTENSION POSTGIS;
CREATE EXTENSION POSTGIS_RASTER;

-- Upload the shapefiles

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
	gid ,
	market,
	zone,




-- 12km buffers around the markets

CREATE TABLE market_buffers AS
SELECT 
    tigray_markets.gid,
    ST_Buffer(tigray_markets.geometry, 12000) AS buffer_geom -- 12 km buffer
FROM tigray_markets;

-- Create an index on the buffered geometries for faster spatial operations
CREATE INDEX market_buffers_geom_idx ON market_buffers USING GIST (buffer_geom);

--dissolve the buffers
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


--totals
SELECT 
    SUM(number_of_settlements) AS total_settlements
FROM (
   SELECT restricted_areas.woreda AS woreda, COUNT(tigray_settlements.objectid) AS number_of_settlements
FROM restricted_areas
LEFT JOIN tigray_settlements ON ST_Within(tigray_settlements.geometry, restricted_areas.geometry)
GROUP BY restricted_areas.woreda
order by number_of_settlements desc
) AS subquery;



--#We first select the attribute we want to get raster values from
SELECT parks.name, AVG((ST_SummaryStats(ST_Clip(rast.rast, parks.geom, TRUE))).mean) AS avg_lst		#This will average the rast value from the polygons
FROM public.lst_raster AS rast, public.parks_vector AS parks		#Renaming the raster and vector tables to rast and parks 
WHERE ST_Intersects(rast.rast, parks.geom)		#Where the raster values intersect the geometries of the vector file
GROUP BY parks.name;		#Group results by the attribute we selected earlier


--#We first select the attribute we want to get raster values from
SELECT restricted_areas.woreda, AVG((ST_SummaryStats(ST_Clip(rast.rast, restricted_areas.geometry, TRUE))).mean) AS avg_lc2		--#This will average the rast value from the polygons
FROM public.tigray_lc2 AS rast, 
public.restricted_areas AS restricted_areas		--#Renaming the raster and vector tables to rast and parks 
WHERE ST_Intersects(rast.rast, restricted_areas.geometry)		--#Where the raster values intersect the geometries of the vector file
GROUP BY restricted_areas.woreda;		--#Group results by the attribute we selected earlier

SELECT restricted_areas.woreda, AVG((ST_SummaryStats(ST_Clip(cropland.number_of_pixels, restricted_areas.geometry, TRUE))).mean) AS avg_lc2		--#This will average the rast value from the polygons
FROM public.cropland AS rast, 
public.restricted_areas AS restricted_areas		--#Renaming the raster and vector tables to rast and parks 
WHERE ST_Intersects(cropland.number_of_pixels, restricted_areas.geometry)		--#Where the raster values intersect the geometries of the vector file
GROUP BY restricted_areas.woreda;




SELECT woredas.woreda, AVG((ST_SummaryStats(ST_Clip(rast.rast, woredas.geometry, TRUE))).mean) AS avg_lc2		
FROM public.tigray_lc2 AS rast, 
public.woredas AS woredas		 
WHERE ST_Intersects(rast.rast, woredas.geometry)		
GROUP BY woredas.woreda;


CREATE TABLE pixels AS
SELECT (ST_ValueCount(rast)).value AS number_of_pixels,
		(ST_ValueCount(rast)).count
FROM tigray_lc2;

CREATE TABLE pixels AS
SELECT
    (ST_ValueCount(rast)).value AS land_cover_type,
    (ST_ValueCount(rast)).count AS number_of_pixels
FROM
    tigray_lc2;
WHERE
    (ST_ValueCount(rast)).value = 40;










CREATE TABLE cropland AS
SELECT *
FROM pixels
WHERE land_cover_type = 40;

SELECT woredas_clean, AVG((ST_SummaryStats(ST_Clip(rast.rast, woredas_clean.geom, TRUE))).mean) AS avg_lc2		--#This will average the rast value from the polygons
FROM public.tigray_lc2 AS rast, 
public.access_clean AS woredas_clean		--#Renaming the raster and vector tables to rast and parks 
WHERE ST_Intersects(rast.rast, woredas_clean.geom)		--#Where the raster values intersect the geometries of the vector file
GROUP BY woredas_clean;





--totals
SELECT COUNT(*) AS total_woredas
FROM woredas_21;

SELECT COUNT(*) AS total_settlements
FROM settlements_clean;

SELECT COUNT(*) AS total_markets
FROM markets_clean;



--number of settlements in each woreda
  SELECT woredas_21.w_name, 
    COUNT(settlements_clean.objectid) AS number_of_settlements
    FROM woredas_21
    LEFT JOIN settlements_clean ON ST_Within(settlements_clean.geom, woredas_21.geom)
    GROUP BY woredas_21.w_name
	ORDER BY number_of_settlements DESC;

SELECT 
    SUM(number_of_settlements) AS total_settlements
FROM (
    SELECT woredas_21.objectid, 
    COUNT(settlements_clean.objectid) AS number_of_settlements
    FROM woredas_21
    LEFT JOIN settlements_clean ON ST_Within(settlements_clean.geom, woredas_21.geom)
    GROUP BY woredas_21.objectid
	ORDER BY number_of_settlements DESC;
) AS subquery;

SELECT ST_Intersection(rast, geometry)
FROM tigray_lc2, restricted_areas;


SELECT woredas_21.objectid,
COUNT(DISTINCT settlements_clean.objectid) AS settlement_count
FROM woredas_21
LEFT JOIN settlements_clean ON woredas_21.objectid = settlements_clean.objectid
GROUP BY woredas_21.objectid
ORDER BY settlement_count ASC;

--number of markets in each woreda
SELECT woreda.gid,
COUNT(DISTINCT markets_clean.gid) AS market_count
FROM woredas_clean
LEFT JOIN markets_clean ON woredas_clean.gid = markets_clean.gid
GROUP BY woredas_clean.gid
ORDER BY market_count ASC;


SELECT woredas_clean.gid AS polygon_id,
COUNT(markets_clean.gid) AS number_of_markets
FROM woredas_clean
LEFT JOIN markets_clean ON ST_Within(markets_clean.geom, woredas_clean.geom)
GROUP BY woredas_clean.gid
ORDER BY number_of_markets DESC;



-- average distance between markets and settlements
SELECT
    AVG(ST_Distance(tigray_markets.geometry, tigray_settlements.geometry)) AS average_distance
FROM
    tigray_markets,
    tigray_settlements
ORDER BY average_distance;

SELECT settlements.gid, COUNT(*) AS num_settlements
FROM woredas;

	latitude,
	longitude,
	geom GEOMETRY
FROM markets;

CREATE TABLE restricted_areas AS 
SELECT 	
	gid,
	adm3_en AS woreda,
	adm2_en AS zone,
	shape_area,
	shape_leng,
	geom GEOMETRY
FROM hard_reach_areas;
