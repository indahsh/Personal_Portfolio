-- (1) Jumlah total kasus Covid-19 aktif yang baru di setiap provinsi lalu diurutkan berdasarkan jumlah kasus yang paling besar
WITH Cleaned_Data AS (
  SELECT 
    Date,
    CASE
      WHEN New_Active_Cases < 0 THEN 0
      ELSE New_Active_Cases
    END AS New_Active_Cases,
    Location_Level
  FROM `challenge_chapter1.kasus_covid-19`
)

SELECT 
  Date,
  SUM(New_Active_Cases) AS Total_New_Active_Cases
FROM Cleaned_Data
WHERE Location_Level = 'Country'
GROUP BY Date
ORDER BY Total_New_Active_Cases DESC;

-- (2) Mengambil 2 (dua) location iso code yang memiliki jumlah total kematian karena Covid-19 paling sedikit
SELECT 
  Location_ISO_Code, 
  Location,
  SUM(Total_Deaths) AS Total_Deaths 
FROM `challenge_chapter1.kasus_covid-19` 
WHERE Location_Level = 'Province'
GROUP BY 
  Location_ISO_Code, 
  Location 
ORDER BY Total_Deaths
LIMIT 2;

-- (3) Data tentang tanggal-tanggal ketika rate kasus recovered di Indonesia paling tinggi beserta jumlah rate-nya
WITH Cleaned_Data AS (
  SELECT 
    Date,
    CASE
      WHEN New_Active_Cases < 0 THEN 0
      ELSE New_Active_Cases
    END AS New_Active_Cases,
    Total_Deaths,
    Total_Recovered,
    Location_Level
  FROM `challenge_chapter1.kasus_covid-19`
),
Recalculated_Data AS (
  SELECT
    Date,
    New_Active_Cases,
    SUM(New_Active_Cases) OVER (PARTITION BY Location_Level ORDER BY Date) AS Total_Active_Cases,
    Total_Deaths,
    Total_Recovered,
    Location_Level
  FROM Cleaned_Data
),
Final_Data AS (
  SELECT
    Date,
    Total_Recovered,
    (Total_Deaths + Total_Recovered + Total_Active_Cases) AS Total_Cases,
    Location_Level
  FROM Recalculated_Data
)

SELECT 
  Date, 
  CONCAT(ROUND(((SUM(Total_Recovered)/SUM(Total_Cases))*100), 3), '%') AS Case_Recovered_Rate,
  MAX(Total_Recovered) AS Total_Recovered
FROM `challenge_chapter1.kasus_covid-19`
WHERE Location_Level = 'Country'
GROUP BY Date
ORDER BY Case_Recovered_Rate DESC;

-- (4) Total case fatality rate dan case recovered rate dari masing-masing location iso code yang diurutkan dari data yang paling rendah
-- (a) Total case fatality rate
WITH Cleaned_Data AS (
  SELECT 
    Date,
    Location_ISO_Code,
    Location,
    CASE
      WHEN New_Active_Cases < 0 THEN 0
      ELSE New_Active_Cases
    END AS New_Active_Cases,
    Total_Deaths,
    Total_Recovered,
    Location_Level
  FROM `challenge_chapter1.kasus_covid-19`
),
Recalculated_Data AS (
  SELECT
    Date,
    Location_ISO_Code,
    Location,
    New_Active_Cases,
    SUM(New_Active_Cases) OVER (PARTITION BY Location_Level ORDER BY Date) AS Total_Active_Cases,
    Total_Deaths,
    Total_Recovered,
    Location_Level
  FROM Cleaned_Data
),
Final_Data AS (
  SELECT
    Location_ISO_Code,
    Location,
    Total_Deaths,
    (Total_Deaths + Total_Recovered + Total_Active_Cases) AS Total_Cases,
    Location_Level
  FROM Recalculated_Data
)

SELECT 
  Location_ISO_Code,
  Location,
  CONCAT(ROUND(((SUM(Total_Deaths)/SUM(Total_Cases))*100), 3), '%') AS Case_Fatality_Rate
FROM `challenge_chapter1.kasus_covid-19`
WHERE Location_Level = 'Province'
GROUP BY 
  Location_ISO_Code, 
  Location
ORDER BY Case_Fatality_Rate;

-- (b) Total case recovered rate
WITH Cleaned_Data AS (
  SELECT 
    Date,
    Location_ISO_Code,
    Location,
    CASE
      WHEN New_Active_Cases < 0 THEN 0
      ELSE New_Active_Cases
    END AS New_Active_Cases,
    Total_Deaths,
    Total_Recovered,
    Location_Level
  FROM `challenge_chapter1.kasus_covid-19`
),
Recalculated_Data AS (
  SELECT
    Date,
    Location_ISO_Code,
    Location,
    New_Active_Cases,
    SUM(New_Active_Cases) OVER (PARTITION BY Location_Level ORDER BY Date) AS Total_Active_Cases,
    Total_Deaths,
    Total_Recovered,
    Location_Level
  FROM Cleaned_Data
),
Final_Data AS (
  SELECT
    Location_ISO_Code,
    Location,
    Total_Recovered,
    (Total_Deaths + Total_Recovered + Total_Active_Cases) AS Total_Cases,
    Location_Level
  FROM Recalculated_Data
)

SELECT
  Location_ISO_Code,
  Location,
  CONCAT(ROUND(((SUM(Total_Recovered)/SUM(Total_Cases))*100), 3), '%') AS Case_Recovered_Rate
FROM `challenge_chapter1.kasus_covid-19`
WHERE Location_Level = 'Province'
GROUP BY 
  Location_ISO_Code,
  Location
ORDER BY Case_Recovered_Rate;

-- (5) Data tentang tanggal-tanggal saat total kasus Covid-19 mulai menyentuh angka 30.000-an
WITH Cleaned_Data AS (
  SELECT 
    Date,
    CASE
      WHEN New_Active_Cases < 0 THEN 0
      ELSE New_Active_Cases
    END AS New_Active_Cases,
    Total_Deaths,
    Total_Recovered,
    Location_Level
  FROM `challenge_chapter1.kasus_covid-19`
),
Recalculated_Data AS (
  SELECT
    Date,
    New_Active_Cases,
    SUM(New_Active_Cases) OVER (PARTITION BY Location_Level ORDER BY Date) AS Total_Active_Cases,
    Total_Deaths,
    Total_Recovered,
    Location_Level
  FROM Cleaned_Data
),
Final_Data AS (
  SELECT
    (Total_Deaths + Total_Recovered + Total_Active_Cases) AS Total_Cases,
    Location_Level
  FROM Recalculated_Data
)

SELECT
  COUNT(Total_Cases) AS Total_Data
FROM Final_Data
WHERE Location_Level = 'Country' AND Total_Cases >= 30000;