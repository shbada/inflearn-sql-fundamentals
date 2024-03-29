--LAG() 현재 행보다 이전 행의 데이터를 가져옴. 동일 부서에서 HIREDATE순으로 이전 ENAME을 가져옴.
SELECT EMPNO, DEPTNO, HIREDATE, ENAME
     , LAG(ENAME) OVER (PARTITION BY DEPTNO ORDER BY HIREDATE) AS PREV_ENAME
FROM HR.EMP;

-- LEAD( ) 현재 행보다 다음 행의 데이터를 가져옴. 동일 부서에서 HIREDATE순으로 다음 ENAME을 가져옴.
SELECT EMPNO, DEPTNO, HIREDATE, ENAME,
       LEAD(ENAME) OVER (PARTITION BY DEPTNO ORDER BY HIREDATE) AS NEXT_ENAME
FROM HR.EMP;

-- LAG() OVER (ORDER BY DESC)는 LEAD() OVER (ORDER BY ASC)와 동일하게 동작하므로 혼돈을 방지하기 위해 ORDER BY 는 ASC로 통일하는것이 좋음.
SELECT EMPNO, DEPTNO, HIREDATE, ENAME
     , LAG(ENAME) OVER (PARTITION BY DEPTNO ORDER BY HIREDATE DESC) AS LAG_DESC_ENAME
	, LEAD(ENAME) OVER (PARTITION BY DEPTNO ORDER BY HIREDATE) AS LEAD_DESC_ENAME
FROM HR.EMP;

-- LAG 적용 시 WINDOWS에서 가져올 값이 없을 경우 DEFAULT 값을 설정할 수 있음. 이 경우 반드시 OFFSET을 정해 줘야함.
SELECT EMPNO, DEPTNO, HIREDATE, ENAME
     , LAG(ENAME, 1, 'NO PREVIOUS') OVER (PARTITION BY DEPTNO ORDER BY HIREDATE) AS PREV_ENAME
FROM HR.EMP;

-- NULL 처리를 아래와 같이 수행할 수도 있음.
SELECT EMPNO, DEPTNO, HIREDATE, ENAME
     , COALESCE(LAG(ENAME) OVER (PARTITION BY DEPTNO ORDER BY HIREDATE), 'NO PREVIOUS') AS PREV_ENAME
FROM HR.EMP;

-- 현재일과 1일전 매출데이터와 그 차이를 출력. 1일전 매출 데이터가 없을 경우 현재일 매출 데이터를 출력하고, 차이는 0
WITH
    TEMP_01 AS (
        SELECT DATE_TRUNC('DAY', B.ORDER_DATE)::DATE AS ORD_DATE, SUM(AMOUNT) AS DAILY_SUM
        FROM NW.ORDER_ITEMS A
                 JOIN NW.ORDERS B ON A.ORDER_ID = B.ORDER_ID
        GROUP BY DATE_TRUNC('DAY', B.ORDER_DATE)::DATE
    )
SELECT ORD_DATE, DAILY_SUM
     , COALESCE(LAG(DAILY_SUM) OVER (ORDER BY ORD_DATE), DAILY_SUM) AS PREV_DAILY_SUM
     , DAILY_SUM - COALESCE(LAG(DAILY_SUM) OVER (ORDER BY ORD_DATE), DAILY_SUM) AS DIFF_PREV
FROM TEMP_01;