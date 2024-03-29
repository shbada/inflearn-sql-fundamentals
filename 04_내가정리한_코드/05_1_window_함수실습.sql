/* 0. 강의 SQL */

-- ORDER_ITEMS 테이블에서 ORDER_ID 별 AMOUNT 총합까지 표시
SELECT ORDER_ID, LINE_PROD_SEQ, PRODUCT_ID, AMOUNT
     , SUM(AMOUNT) OVER (PARTITION BY ORDER_ID) AS TOTAL_SUM_BY_ORD FROM NW.ORDER_ITEMS

-- ORDER_ITEMS 테이블에서시 RDER_ID별 LINE_PROD_SEQ순으로  누적 AMOUNT 합까지 표시
SELECT ORDER_ID, LINE_PROD_SEQ, PRODUCT_ID, AMOUNT
     , SUM(AMOUNT) OVER (PARTITION BY ORDER_ID) AS TOTAL_SUM_BY_ORD
	, SUM(AMOUNT) OVER (PARTITION BY ORDER_ID ORDER BY LINE_PROD_SEQ) AS CUM_SUM_BY_ORD
FROM NW.ORDER_ITEMS;

-- ORDER_ITEMS 테이블에서 ORDER_ID별 LINE_PROD_SEQ순으로  누적 AMOUNT 합 - PARTITION 또는 ORDER BY 절이 없을 경우 WINDOWS.
SELECT ORDER_ID, LINE_PROD_SEQ, PRODUCT_ID매 AMOUNT
     , SUM(AMOUNT) OVER (PARTITION BY ORDER_ID) AS TOTAL_SUM_BY_ORD
	, SUM(AMOUNT) OVER (PARTITION BY ORDER_ID ORDER BY LINE_PROD_SEQ) AS CUM_SUM_BY_ORD_01
	, SUM(AMOUNT) OVER (PARTITION BY ORDER_ID ORDER BY LINE_PROD_SEQ ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS CUM_SUM_BY_ORD_02
	, SUM(AMOUNT) OVER ( ) AS TOTAL_SUM
FROM NW.ORDER_ITEMS WHERE ORDER_ID BETWEEN 10248 AND 10250;

-- ORDER_ITEMS 테이블에서 ORDER_ID 별 상품 최대 구매금액, ORDER_ID별 상품 누적 최대 구매금액
SELECT ORDER_ID, LINE_PROD_SEQ, PRODUCT_ID, AMOUNT
     , MAX(AMOUNT) OVER (PARTITION BY ORDER_ID) AS MAX_BY_ORD
	, MAX(AMOUNT) OVER (PARTITION BY ORDER_ID ORDER BY LINE_PROD_SEQ) AS CUM_MAX_BY_ORD
FROM NW.ORDER_ITEMS;

-- ORDER_ITEMS 테이블에서 ORDER_ID 별 상품 최소 구매금액, ORDER_ID별 상품 누적 최소 구매금액
SELECT ORDER_ID, LINE_PROD_SEQ, PRODUCT_ID, AMOUNT
     , MIN(AMOUNT) OVER (PARTITION BY ORDER_ID) AS MIN_BY_ORD
	, MIN(AMOUNT) OVER (PARTITION BY ORDER_ID ORDER BY LINE_PROD_SEQ) AS CUM_MIN_BY_ORD
FROM NW.ORDER_ITEMS;

-- ORDER_ITEMS 테이블에서 ORDER_ID 별 상품 평균 구매금액, ORDER_ID별 상품 누적 평균 구매금액
SELECT ORDER_ID, LINE_PROD_SEQ, PRODUCT_ID, AMOUNT
     , AVG(AMOUNT) OVER (PARTITION BY ORDER_ID) AS AVG_BY_ORD
	, AVG(AMOUNT) OVER (PARTITION BY ORDER_ID ORDER BY LINE_PROD_SEQ) AS CUM_AVG_BY_ORD
FROM NW.ORDER_ITEMS;


/* 1. AGGREGATION ANALYTIC 실습 */

-- 직원 정보 및 부서별로 직원 급여의 HIREDATE순으로 누적 급여합.
SELECT EMPNO, ENAME, DEPTNO, SAL, HIREDATE, SUM(SAL) OVER (PARTITION BY DEPTNO ORDER BY HIREDATE) CUM_SAL FROM HR.EMP;

--직원 정보 및 부서별 평균 급여와 개인 급여와의 차이 출력
SELECT EMPNO, ENAME, DEPTNO, SAL, AVG(SAL) OVER (PARTITION BY DEPTNO) DEPT_AVG_SAL
	, SAL - AVG(SAL) OVER (PARTITION BY DEPTNO) DEPT_AVG_SAL_DIFF
FROM HR.EMP;

-- ANALYTIC을 사용하지 않고 위와 동일한 결과 출력
WITH
    TEMP_01 AS (
        SELECT DEPTNO, AVG(SAL) AS DEPT_AVG_SAL
        FROM HR.EMP GROUP BY DEPTNO
    )
SELECT A.EMPNO, A.ENAME, A.DEPTNO, B.DEPT_AVG_SAL,
       A.SAL - B.DEPT_AVG_SAL AS DEPT_AVG_SAL_DIFF
FROM HR.EMP A
         JOIN TEMP_01 B
              ON A.DEPTNO = B.DEPTNO
ORDER BY A.DEPTNO
;

-- 직원 정보및 부서별 총 급여 대비 개인 급여의 비율 출력(소수점 2자리까지로 비율 출력)
SELECT EMPNO, ENAME, DEPTNO, SAL, SUM(SAL) OVER (PARTITION BY DEPTNO) AS DEPT_SUM_SAL
	, ROUND(SAL/SUM(SAL) OVER (PARTITION BY DEPTNO), 2) AS DEPT_SUM_SAL_RATIO
FROM HR.EMP;


-- 직원 정보 및 부서에서 가장 높은 급여 대비 비율 출력(소수점 2자리까지로 비율 출력)
SELECT EMPNO, ENAME, DEPTNO, SAL, MAX(SAL) OVER (PARTITION BY DEPTNO) AS DEPT_MAX_SAL
	, ROUND(SAL/MAX(SAL) OVER (PARTITION BY DEPTNO), 2) AS DEPT_MAX_SAL_RATIO
FROM HR.EMP;


-- PRODUCT_ID 총 매출액을 구하고, 전체 매출 대비 개별 상품의 총 매출액 비율을 소수점2자리로 구한 뒤 매출액 비율 내림차순으로 정렬
WITH
    TEMP_01 AS (
        SELECT PRODUCT_ID, SUM(AMOUNT) AS SUM_BY_PROD
        FROM ORDER_ITEMS
        GROUP BY PRODUCT_ID
    )
SELECT PRODUCT_ID, SUM_BY_PROD
     , SUM(SUM_BY_PROD) OVER () TOTAL_SUM
	, ROUND(1.0 * SUM_BY_PROD/SUM(SUM_BY_PROD) OVER (), 2) AS SUM_RATIO
FROM TEMP_01
ORDER BY 4 DESC;

-- 직원별 개별 상품 매출액, 직원별 가장 높은 상품 매출액을 구하고, 직원별로 가장 높은 매출을 올리는 상품의 매출 금액 대비 개별 상품 매출 비율 구하기
WITH
    TEMP_01 AS (
        SELECT B.EMPLOYEE_ID, A.PRODUCT_ID, SUM(AMOUNT) AS SUM_BY_EMP_PROD
        FROM ORDER_ITEMS A
                 JOIN ORDERS B ON A.ORDER_ID = B.ORDER_ID
        GROUP BY B.EMPLOYEE_ID, A.PRODUCT_ID
    )
SELECT EMPLOYEE_ID, PRODUCT_ID, SUM_BY_EMP_PROD
     , MAX(SUM_BY_EMP_PROD) OVER (PARTITION BY EMPLOYEE_ID) AS SUM_BY_EMP
	, SUM_BY_EMP_PROD/MAX(SUM_BY_EMP_PROD) OVER (PARTITION BY EMPLOYEE_ID) AS SUM_RATIO
FROM TEMP_01
ORDER BY 1, 5 DESC;



-- 상품별 매출합을 구하되, 상품 카테고리별 매출합의 5% 이상이고, 동일 카테고리에서 상위 3개 매출의 상품 정보 추출.
-- 1. 상품별 + 상품 카테고리별 총 매출 계산. (상품별 + 상품 카테고리별 총 매출은 결국 상품별 총 매출임)
-- 2. 상품 카테고리별 총 매출 계산 및 동일 카테고리에서 상품별 랭킹 구함
-- 3. 상품 카테고리 매출의 5% 이상인 상품 매출과 매출 기준 TOP 3 상품 추출.
WITH
    TEMP_01 AS (
        SELECT A.PRODUCT_ID, MAX(B.CATEGORY_ID) AS CATEGORY_ID , SUM(AMOUNT) SUM_BY_PROD
        FROM  ORDER_ITEMS A
                  JOIN PRODUCTS B
                       ON A.PRODUCT_ID = B.PRODUCT_ID
        GROUP BY  A.PRODUCT_ID
    ),
    TEMP_02 AS (
        SELECT PRODUCT_ID, CATEGORY_ID, SUM_BY_PROD
             , SUM(SUM_BY_PROD) OVER (PARTITION BY CATEGORY_ID) AS SUM_BY_CAT
	, ROW_NUMBER() OVER (PARTITION BY CATEGORY_ID ORDER BY SUM_BY_PROD DESC) AS TOP_PROD_RANKING
        FROM TEMP_01
    )
SELECT * FROM TEMP_02 WHERE SUM_BY_PROD >= 0.05 * SUM_BY_CAT AND TOP_PROD_RANKING <=3;