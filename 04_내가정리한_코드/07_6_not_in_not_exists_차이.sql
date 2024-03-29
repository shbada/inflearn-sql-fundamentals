/************************************************
 NULL값이 있는 컬럼의 NOT IN과 NOT EXISTS 차이 실습
 *************************************************/

SELECT * FROM HR.EMP WHERE DEPTNO IN (20, 30, NULL);

SELECT * FROM HR.EMP WHERE DEPTNO = 20 OR DEPTNO=30 OR DEPTNO = NULL;


-- 테스트를 위한 임의의 테이블 생성.
DROP TABLE IF EXISTS NW.REGION;

CREATE TABLE NW.REGION
AS
SELECT SHIP_REGION AS REGION_NAME FROM NW.ORDERS
GROUP BY SHIP_REGION
;

-- 새로운 XX값을 REGION테이블에 입력.
INSERT INTO NW.REGION VALUES('XX');

COMMIT;

SELECT * FROM NW.REGION;

-- NULL값이 포함된 컬럼을 서브쿼리로 연결할 시 IN과 EXISTS는 모두 동일.
SELECT A.*
FROM NW.REGION A
WHERE A.REGION_NAME IN (SELECT SHIP_REGION FROM NW.ORDERS X);

SELECT A.*
FROM NW.REGION A
WHERE EXISTS (SELECT SHIP_REGION FROM NW.ORDERS X WHERE X.SHIP_REGION = A.REGION_NAME
             );

-- NULL값이 포함된 컬럼을 서브쿼리로 연결 시 NOT IN과 NOT EXISTS의 결과는 서로 다름.
SELECT A.*
FROM NW.REGION A
WHERE A.REGION_NAME NOT IN (SELECT SHIP_REGION FROM NW.ORDERS X);

SELECT A.*
FROM NW.REGION A
WHERE NOT EXISTS (SELECT SHIP_REGION FROM NW.ORDERS X WHERE X.SHIP_REGION = A.REGION_NAME
                 );
;

-- TRUE
SELECT 1=1;

-- FALSE
SELECT 1=2;

-- NULL
SELECT NULL = NULL;

-- NULL
SELECT 1=1 AND NULL;

-- NULL
SELECT 1=1 AND (NULL = NULL);

-- TRUE
SELECT 1=1 OR NULL;

-- FALSE
SELECT NOT 1=1;

-- NULL
SELECT NOT NULL;

-- NOT IN을 사용할 경우 NULL인 값은 서브쿼리내에서 IS NOT NULL로 미리 제거해야 함.
-- IS NOT NULL 제거 하지 않으면 데이터가 안나온다.
-- NOT IN : 데이터 안나옴, NOT EXISTS : NULL 값도 나옴
-- true and NULL = NULL
SELECT A.*
FROM NW.REGION A
WHERE A.REGION_NAME NOT IN (SELECT SHIP_REGION FROM NW.ORDERS X WHERE X.SHIP_REGION IS NOT NULL);

-- NOT EXISTS의 경우 NULL 값을 제외하려면 서브쿼리가 아닌 메인쿼리 영역에서 제외
-- 서브쿼리에서 하면?
-- NULL이 왜 나올까?
-- 서브쿼리 반환값이 NULL이므로(반환값이 없다) NOT EXISTS 문은 true가 된다.
SELECT A.*
FROM NW.REGION A
WHERE NOT EXISTS (SELECT SHIP_REGION FROM NW.ORDERS X WHERE X.SHIP_REGION = A.REGION_NAME --AND A.REGION_NAME IS NOT NULL
                 );
--AND A.REGION_NAME IS NOT NULL