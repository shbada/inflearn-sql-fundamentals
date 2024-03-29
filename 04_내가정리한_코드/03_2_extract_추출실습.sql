/********************************************************************
EXTRACT와 DATE_PART를 이용하여 DATE/TIMESTAMP에서 년,월,일/시간,분,초 추출
*********************************************************************/

-- EXTRACT와 DATE_PART를 이용하여 년, 월, 일 추출
SELECT A.*
     , EXTRACT(YEAR FROM HIREDATE) AS YEAR
	, EXTRACT(MONTH FROM HIREDATE) AS MONTH
	, EXTRACT(DAY FROM HIREDATE) AS DAY
FROM HR.EMP A;

SELECT A.*
     , DATE_PART('YEAR', HIREDATE) AS YEAR
	, DATE_PART('MONTH', HIREDATE) AS MONTH
	, DATE_PART('DAY', HIREDATE) AS DAY
FROM HR.EMP A;

-- EXTRACT와 DATE_PART를 이용하여 시간, 분, 초 추출.
SELECT DATE_PART('HOUR', '2022-02-03 13:04:10'::TIMESTAMP) AS HOUR
	, DATE_PART('MINUTE', '2022-02-03 13:04:10'::TIMESTAMP) AS MINUTE
	, DATE_PART('SECOND', '2022-02-03 13:04:10'::TIMESTAMP) AS SECOND
;

SELECT EXTRACT(HOUR FROM '2022-02-03 13:04:10'::TIMESTAMP) AS HOUR
	, EXTRACT(MINUTE FROM '2022-02-03 13:04:10'::TIMESTAMP) AS MINUTE
	, EXTRACT(SECOND FROM '2022-02-03 13:04:10'::TIMESTAMP) AS SECOND