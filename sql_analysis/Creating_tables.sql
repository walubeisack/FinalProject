
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