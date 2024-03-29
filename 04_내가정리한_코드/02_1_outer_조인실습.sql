/************************************
   조인 실습 - OUTER 조인.
*************************************/

-- 주문이 단 한번도 없는 고객 정보 구하기.
SELECT *
FROM NW.CUSTOMERS A
         LEFT JOIN NW.ORDERS B ON A.CUSTOMER_ID = B.CUSTOMER_ID
WHERE B.CUSTOMER_ID IS NULL;

-- 부서정보와 부서에 소속된 직원명 정보 구하기. 부서가 직원을 가지고 있지 않더라도 부서정보는 표시되어야 함.
SELECT A.*, B.EMPNO, B.ENAME
FROM HR.DEPT A
         LEFT JOIN HR.EMP B ON A.DEPTNO = B.DEPTNO;

-- MADRID에 살고 있는 고객이 주문한 주문 정보를 구할것.
-- 고객명, 주문ID, 주문일자, 주문접수 직원명, 배송업체명을 구하되,
-- 만일 고객이 주문을 한번도 하지 않은 경우라도 고객정보는 빠지면 안됨. 이경우 주문 정보가 없으면 주문ID를 0으로 나머지는 NULL로 구할것.
SELECT A.CUSTOMER_ID, A.CONTACT_NAME, COALESCE(B.ORDER_ID, 0) AS ORDER_ID, B.ORDER_DATE
     , C.FIRST_NAME||' '||C.LAST_NAME AS EMPLOYEE_NAME, D.COMPANY_NAME AS SHIPPER_NAME
FROM NW.CUSTOMERS A
         LEFT JOIN NW.ORDERS B ON A.CUSTOMER_ID = B.CUSTOMER_ID
         LEFT JOIN NW.EMPLOYEES C ON B.EMPLOYEE_ID = C.EMPLOYEE_ID -- why?
         LEFT JOIN NW.SHIPPERS D ON B.SHIP_VIA = D.SHIPPER_ID
WHERE A.CITY = 'MADRID';

-- 만일 아래와 같이 중간에 연결되는 집합을 명확히 LEFT OUTER JOIN 표시하지 않으면 원하는 집합을 가져 올 수 없음.
SELECT A.CUSTOMER_ID, A.CONTACT_NAME, COALESCE(B.ORDER_ID, 0) AS ORDER_ID, B.ORDER_DATE
     , C.FIRST_NAME||' '||C.LAST_NAME AS EMPLOYEE_NAME, D.COMPANY_NAME AS SHIPPER_NAME
FROM NW.CUSTOMERS A
         LEFT JOIN NW.ORDERS B ON A.CUSTOMER_ID = B.CUSTOMER_ID
         JOIN NW.EMPLOYEES C ON B.EMPLOYEE_ID = C.EMPLOYEE_ID -- NULL 이기 때문에 Join 매칭될 수 없음
         JOIN NW.SHIPPERS D ON B.SHIP_VIA = D.SHIPPER_ID
WHERE A.CITY = 'MADRID';

-- ORDERS_ITEMS에 주문번호(ORDER_ID)가 없는 ORDER_ID를 가진 ORDERS 데이터 찾기
SELECT *
FROM NW.ORDERS A
         LEFT JOIN NW.ORDER_ITEMS B ON A.ORDER_ID = B.ORDER_ID
WHERE B.ORDER_ID IS NULL;

-- ORDERS 테이블에 없는 ORDER_ID가 있는 ORDER_ITEMS 데이터 찾기.
SELECT *
FROM NW.ORDER_ITEMS A
         LEFT JOIN NW.ORDERS B ON A.ORDER_ID = B.ORDER_ID
WHERE B.ORDER_ID IS NULL;