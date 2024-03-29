/************************************
   GROUP BY 실습 - 04(GROUP BY와 AGGREGATE 함수의 CASE WHEN 을 이용한 PIVOTING)
*************************************/

SELECT JOB, SUM(SAL) AS SALES_SUM
FROM HR.EMP A
GROUP BY JOB;


-- DEPTNO로 GROUP BY하고 JOB으로 PIVOTING
SELECT SUM(CASE WHEN JOB = 'SALESMAN' THEN SAL END) AS SALES_SUM
     , SUM(CASE WHEN JOB = 'MANAGER' THEN SAL END) AS MANAGER_SUM
     , SUM(CASE WHEN JOB = 'ANALYST' THEN SAL END) AS ANALYST_SUM
     , SUM(CASE WHEN JOB = 'CLERK' THEN SAL END) AS CLERK_SUM
     , SUM(CASE WHEN JOB = 'PRESIDENT' THEN SAL END) AS PRESIDENT_SUM
FROM HR.EMP;


-- DEPTNO + JOB 별로 GROUP BY
SELECT DEPTNO, JOB, SUM(SAL) AS SAL_SUM
FROM HR.EMP
GROUP BY DEPTNO, JOB;


-- DEPTNO로 GROUP BY하고 JOB으로 PIVOTING



-- GROUP BY PIVOTING시 조건에 따른 건수 계산 유형(COUNT CASE WHEN THEN 1 ELSE NULL END)
SELECT DEPTNO, COUNT(*) AS CNT
     , COUNT(CASE WHEN JOB = 'SALESMAN' THEN 1 END) AS SALES_CNT
     , COUNT(CASE WHEN JOB = 'MANAGER' THEN 1 END) AS MANAGER_CNT
     , COUNT(CASE WHEN JOB = 'ANALYST' THEN 1 END) AS ANALYST_CNT
     , COUNT(CASE WHEN JOB = 'CLERK' THEN 1 END) AS CLERK_CNT
     , COUNT(CASE WHEN JOB = 'PRESIDENT' THEN 1 END) AS PRESIDENT_CNT
FROM HR.EMP
GROUP BY DEPTNO;

-- GROUP BY PIVOTING시 조건에 따른 건수 계산 시 잘못된 사례(COUNT CASE WHEN THEN 1 ELSE NULL END)
-- count는 1이라해서 1건을 세는게 아니라, 1이든 0이든 세는거임 !!!! null 이여야 안센다!
SELECT DEPTNO, COUNT(*) AS CNT
     , COUNT(CASE WHEN JOB = 'SALESMAN' THEN 1 ELSE 0 END) AS SALES_CNT
     , COUNT(CASE WHEN JOB = 'MANAGER' THEN 1 ELSE 0 END) AS MANAGER_CNT
     , COUNT(CASE WHEN JOB = 'ANALYST' THEN 1 ELSE 0 END) AS ANALYST_CNT
     , COUNT(CASE WHEN JOB = 'CLERK' THEN 1 ELSE 0 END) AS CLERK_CNT
     , COUNT(CASE WHEN JOB = 'PRESIDENT' THEN 1 ELSE 0 END) AS PRESIDENT_CNT
FROM HR.EMP
GROUP BY DEPTNO;

-- GROUP BY PIVOTING시 조건에 따른 건수 계산 시 SUM()을 이용
SELECT DEPTNO, COUNT(*) AS CNT
     , SUM(CASE WHEN JOB = 'SALESMAN' THEN 1 ELSE 0 END) AS SALES_CNT
     , SUM(CASE WHEN JOB = 'MANAGER' THEN 1 ELSE 0 END) AS MANAGER_CNT
     , SUM(CASE WHEN JOB = 'ANALYST' THEN 1 ELSE 0 END) AS ANALYST_CNT
     , SUM(CASE WHEN JOB = 'CLERK' THEN 1 ELSE 0 END) AS CLERK_CNT
     , SUM(CASE WHEN JOB = 'PRESIDENT' THEN 1 ELSE 0 END) AS PRESIDENT_CNT
FROM HR.EMP
GROUP BY DEPTNO;