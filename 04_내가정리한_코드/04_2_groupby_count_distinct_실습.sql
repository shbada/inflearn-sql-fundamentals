/************************************
   GROUP BY 실습 - 02(집계함수와 COUNT(DISTINCT))
*************************************/
-- 추가적인 테스트 테이블 생성.
DROP TABLE IF EXISTS HR.EMP_TEST;

CREATE TABLE HR.EMP_TEST
AS
SELECT * FROM HR.EMP;

INSERT INTO HR.EMP_TEST
SELECT 8000, 'CHMIN', 'ANALYST', 7839, TO_DATE('19810101', 'YYYYMMDD'), 3000, 1000, 20
;

SELECT * FROM HR.EMP_TEST;

-- AGGREGATION은 NULL값을 처리하지 않음.
SELECT DEPTNO, COUNT(*) AS CNT
     , SUM(COMM), MAX(COMM), MIN(COMM), AVG(COMM)
FROM HR.EMP_TEST
GROUP BY DEPTNO;

SELECT MGR, COUNT(*), SUM(COMM)
FROM HR.EMP
GROUP BY MGR;

-- MAX, MIN 함수는 숫자열 뿐만 아니라, 문자열,날짜/시간 타입에도 적용가능.
SELECT DEPTNO, MAX(JOB), MIN(ENAME), MAX(HIREDATE), MIN(HIREDATE) --, SUM(ENAME) --, AVG(ENAME)
FROM HR.EMP
GROUP BY DEPTNO;

-- COUNT(DISTINCT 컬럼명)은 지정된 컬럼명으로 중복을 제거한 고유한 건수를 추출
SELECT COUNT(DISTINCT JOB) FROM HR.EMP_TEST;

SELECT DEPTNO, COUNT(*) AS CNT, COUNT(DISTINCT JOB) FROM HR.EMP_TEST GROUP BY DEPTNO;

