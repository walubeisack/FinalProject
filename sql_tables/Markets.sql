SET CLIENT_ENCODING TO UTF8;
SET STANDARD_CONFORMING_STRINGS TO ON;
BEGIN;
CREATE TABLE "public"."markets" (gid serial,
"country" varchar(254),
"region" varchar(254),
"zone" varchar(254),
"market" varchar(254),
"longitude" numeric,
"latitude" numeric);
ALTER TABLE "public"."markets" ADD PRIMARY KEY (gid);
SELECT AddGeometryColumn('public','markets','geom','32637','POINT',2);
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','North Western Tigray','Adi Awalo','3.80430536800e+01','1.45287375500e+01','01010000207D7F0000104625357C391841283A925B13833841');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','Central Tigray','Rama','3.87818970400e+01','1.43979687600e+01','01010000207D7F0000E02406C11F151D4188F4DB87C7493841');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','North Western Tigray','Shiraro','3.77822434500e+01','1.43823809600e+01','01010000207D7F0000F075E09C0481164150A60A065B443841');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','Central Tigray','Adi Mendi','3.84505446800e+01','1.43810207100e+01','01010000207D7F000030772DA1E8E61A4180613285B0423841');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','North Western Tigray','Adi Da-iro','3.81741172500e+01','1.43108733200e+01','01010000207D7F000050499D00CB141941F8B9DA7ABA243841');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','Central Tigray','Debre Damo','3.92181273900e+01','1.43064382500e+01','01010000207D7F0000D0915CFE10F41F4170E7FB593C223841');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','Eastern Tigray','Bizet','3.92593444300e+01','1.43027646400e+01','01010000207D7F0000B815FBABC31C2041306EA3A1AA203841');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','Western Tigray','Humera','3.65967609600e+01','1.42652619300e+01','01010000207D7F000020D044580C620D4150A60AD6A3153841');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','Central Tigray','Inticho','3.91525302300e+01','1.42687206500e+01','01010000207D7F000070226C3892851F4190537434EB113841');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','Eastern Tigray','Adigrat','3.94604300200e+01','1.42666983900e+01','01010000207D7F00008061329541C6204100780B5437113841');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','Central Tigray','Adi Abun','3.88837700200e+01','1.41930901700e+01','01010000207D7F0000E0BE0E1C8BC01D4170F90F693CF13741');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','Eastern Tigray','Idaga Hamus','3.95635512300e+01','1.41750719500e+01','01010000207D7F0000303333B3591D2141B8B88DC6B9E93741');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','Central Tigray','Adwa','3.88882804000e+01','1.41484750500e+01','01010000207D7F000090F6065F1CC81D41A86054E2F5DD3741');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','Central Tigray','Wukro','3.85877667200e+01','1.41135050100e+01','01010000207D7F000010E02DD040CD1B4178711B7DFECE3741');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','Central Tigray','Axum','3.87188903100e+01','1.41113282500e+01','01010000207D7F00003011363C65AA1C41B003E7DCF8CD3741');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','Eastern Tigray','Inda Tekle Haymanot','3.95762229600e+01','1.41012425500e+01','01010000207D7F00000022FDB63028214160CC5D7BD7C93741');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','North Western Tigray','Selekleka','3.84637352100e+01','1.40976413000e+01','01010000207D7F000000F0168800FC1A41B047E1FA3EC83741');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','North Western Tigray','Inda Silase','3.82721990700e+01','1.40894629000e+01','01010000207D7F0000F0065F58E3B81941A879C7F9EDC43741');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','Central Tigray','Idaga Arbi','3.90720022600e+01','1.40253645500e+01','01010000207D7F0000A079C7E9FAFD1E41A8ADD8AFC4A83741');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','North Western Tigray','Inda Baguna','3.81932606000e+01','1.39786285100e+01','01010000207D7F0000E0F97EEA13331941A88251E926953741');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','Eastern Tigray','Senkata','3.95954278400e+01','1.38996312300e+01','01010000207D7F0000A023B91CD3382141E88C285DC2723741');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','Eastern Tigray','Atsbi Inda Silase','3.97325192700e+01','1.38615272000e+01','01010000207D7F0000182FDDC4A4AC214108F9A03775623741');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','Central Tigray','Mahbere Tsige','3.87990027700e+01','1.38317716600e+01','01010000207D7F0000305530AA19311D41986E12532A553741');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','Eastern Tigray','Wukro','3.96000722200e+01','1.37775057500e+01','01010000207D7F000028E4835E023D21412063EEAA003E3741');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','Western Tigray','Adi Remets','3.73202030200e+01','1.37360114700e+01','01010000207D7F00005096210E846E1341181DC9253B2E3741');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','Central Tigray','Abiy Adi','3.90019954800e+01','1.36184151500e+01','01010000207D7F0000E02D9060DF871E4150FC1893F5F83641');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','South Tigray','May Mekdan','3.95662786700e+01','1.35689091600e+01','01010000207D7F0000A033A214E4202141A835CDABD9E33641');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','North Western Tigray','May Tsamri','3.81271293700e+01','1.35474730800e+01','01010000207D7F0000D0F753E3C4C018413090A088F8DA3641');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','Western Tigray','Mesfinto','3.73739693000e+01','1.34978973000e+01','01010000207D7F0000303A92CB9FC61341384ED1612CC73641');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','Mekele  Zone','Mekele','3.94723143000e+01','1.34872068000e+01','01010000207D7F000080D93D599AD12041B0B6623F78C03641');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','Western Tigray','Densha','3.69657410700e+01','1.34658304800e+01','01010000207D7F0000B0D1005E8D131141102DB2BD99BA3641');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','South Tigray','Kwiha','3.95447432900e+01','1.34634569000e+01','01010000207D7F000030C4B1EEE30E214160C3D3DB45B63641');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','South Tigray','May Keyah','3.95303946100e+01','1.33156508200e+01','01010000207D7F0000C03923CA07032141A001BC0568763641');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','Central Tigray','Yechilay','3.89940235900e+01','1.32829595500e+01','01010000207D7F000050E3A59B627A1E414060E5800B683641');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','South Tigray','Hintalo','3.94290660800e+01','1.32377513900e+01','01010000207D7F0000D0CCCC6C68AD204170E7FBD9AB543641');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','South Tigray','Adi Gudom','3.95280142500e+01','1.32205018300e+01','01010000207D7F0000880D4FAF3001214130BB27AF4C4D3641');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','South Tigray','Samre','3.91995810200e+01','1.31689429100e+01','01010000207D7F000050F38E9370D61F4130B29D2FD3363641');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','South Tigray','Adi Zeyla','3.90280368400e+01','1.30941445300e+01','01010000207D7F00004072F9CFFCB31E41905374047B163641');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','South Tigray','Hiwane','3.95000860000e+01','1.30866490300e+01','01010000207D7F000080C0CA81C7E92041B02E6E8373133641');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','South Tigray','Aberqele','3.90061024000e+01','1.30233098000e+01','01010000207D7F0000401361C3D68E1E4180D0B379E1F73541');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','South Tigray','Ambalage','3.95245357800e+01','1.29160943600e+01','01010000207D7F0000E0141D49CAFE2041B059F529CBC93541');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','South Tigray','Adi Shoh','3.95661897800e+01','1.28607264500e+01','01010000207D7F0000B0EA73B532222141208E75A1E9B13541');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','South Tigray','Maychew','3.95536747100e+01','1.27879338900e+01','01010000207D7F0000B0726851B9172141587DAE9674923541');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','South Tigray','Weyra Wuha','3.97671645900e+01','1.25268917300e+01','01010000207D7F0000D04D62D06ACD2141585BB16FEA213541');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','South Tigray','Korem','3.95204772800e+01','1.24850300800e+01','01010000207D7F0000E826312818FC2041E0141DC9930F3541');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','South Tigray','Alamata','3.95618931500e+01','1.24147052200e+01','01010000207D7F0000D8C56DF4611F2141E851B8FE3BF13441');
INSERT INTO "public"."markets" ("country","region","zone","market","longitude","latitude",geom) VALUES ('Ethiopia','Tigray','South Tigray','Waja','3.96004903900e+01','1.22863465400e+01','01010000207D7F0000C876BE3F68402141283A926BD2B93441');
CREATE INDEX ON "public"."markets" USING GIST ("geom");
COMMIT;
ANALYZE "public"."markets";
