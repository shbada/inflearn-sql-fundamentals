/************************************************
               스칼라 서브쿼리 이해
 *************************************************/

-- 직원의 부서명을 스칼라 서브쿼리로 추출
SELECT A.*,
	(SELECT DNAME FROM HR.DEPT X WHERE X.DEPTNO=A.DEPTNO) AS DNAME
FROM HR.EMP A;

-- 아래는 수행 오류 발생. 스칼라 서브쿼리는 단 한개의 결과 값만 반환해야 함.
SELECT A.*
	, (SELECT ENAME FROM HR.EMP X WHERE X.DEPTNO=A.DEPTNO) AS ENAME
FROM HR.DEPT A;

-- 아래는 수행 오류 발생. 스칼라 서브쿼리는 단 한개의 열값만 반환해야 함.
SELECT A.*,
	(SELECT DNAME, DEPTNO FROM HR.DEPT X WHERE X.DEPTNO=A.DEPTNO) AS DNAME
FROM HR.EMP A;


-- CASE WHEN 절에서 스칼라 서브쿼리 사용
SELECT A.*,
	(CASE WHEN A.DEPTNO = 10 THEN (SELECT DNAME FROM HR.DEPT X WHERE X.DEPTNO=20)
		  ELSE (SELECT DNAME FROM HR.DEPT X WHERE X.DEPTNO=A.DEPTNO)
		  END
	) AS DNAME
FROM HR.EMP A;

-- 스칼라 서브쿼리는 일반 SELECT와 동일하게 사용. GROUP BY 적용 무방.
SELECT A.*,
	(SELECT AVG(SAL) FROM HR.EMP X WHERE X.DEPTNO = A.DEPTNO) DEPT_AVG_SAL
FROM HR.EMP A;

-- 조인으로 변경.
SELECT A.*, B.AVG_SAL
FROM HR.EMP A
	JOIN (SELECT DEPTNO, AVG(SAL) AS AVG_SAL FROM HR.EMP X GROUP BY DEPTNO) B
	ON A.DEPTNO = B.DEPTNO;

/************************************************
               스칼라 서브쿼리 실습
 *************************************************/

-- 직원 정보와 해당 직원을 관리하는 매니저의 이름 추출
SELECT A.*,
	(SELECT ENAME FROM HR.EMP X WHERE X.EMPNO=A.MGR) AS MGR_NAME
FROM HR.EMP A;

SELECT A.*, B.ENAME AS MGR_NAME
FROM HR.EMP A
	LEFT JOIN HR.EMP B ON A.MGR=B.EMPNO;

-- 주문정보와 SHIP_COUNTRY가 FRANCE이면 주문 고객명을, 아니면 직원명을 NEW_NAME으로 출력
SELECT A.ORDER_ID, A.CUSTOMER_ID, A.EMPLOYEE_ID, A.ORDER_DATE, A.SHIP_COUNTRY
	, (SELECT CONTACT_NAME FROM NW.CUSTOMERS X WHERE X.CUSTOMER_ID = A.CUSTOMER_ID) AS CUSTOMER_NAME
	, (SELECT FIRST_NAME||' '||LAST_NAME FROM NW.EMPLOYEES X WHERE X.EMPLOYEE_ID = A.EMPLOYEE_ID) AS EMPLOYEE_NAME
	, CASE WHEN A.SHIP_COUNTRY = 'FRANCE' THEN
	            (SELECT CONTACT_NAME FROM NW.CUSTOMERS X WHERE X.CUSTOMER_ID = A.CUSTOMER_ID)
	       ELSE (SELECT FIRST_NAME||' '||LAST_NAME FROM NW.EMPLOYEES X WHERE X.EMPLOYEE_ID = A.EMPLOYEE_ID)
	  END AS NEW_NAME
FROM NW.ORDERS A;

-- 조인으로 변경.
SELECT A.ORDER_ID, A.CUSTOMER_ID, A.EMPLOYEE_ID, A.ORDER_DATE, A.SHIP_COUNTRY
	, B.CONTACT_NAME, C.FIRST_NAME||' '||C.LAST_NAME
	, CASE WHEN A.SHIP_COUNTRY = 'FRANCE' THEN B.CONTACT_NAME
		   ELSE C.FIRST_NAME||' '||C.LAST_NAME END AS NEW_NAME
FROM NW.ORDERS A
	LEFT JOIN NW.CUSTOMERS B ON A.CUSTOMER_ID = B.CUSTOMER_ID
	LEFT JOIN NW.EMPLOYEES C ON A.EMPLOYEE_ID = C.EMPLOYEE_ID
;

-- 고객정보와 고객이 처음 주문한 일자의 주문 일자 추출.
SELECT A.CUSTOMER_ID, A.CONTACT_NAME
	, (SELECT MIN(ORDER_DATE) FROM NW.ORDERS X WHERE X.CUSTOMER_ID = A.CUSTOMER_ID) AS FIRST_ORDER_DATE
FROM NW.CUSTOMERS A;

-- 조인으로 변경
SELECT A.CUSTOMER_ID, A.CONTACT_NAME, B.LAST_ORDER_DATE
FROM NW.CUSTOMERS A
	LEFT JOIN (SELECT CUSTOMER_ID, MIN(ORDER_DATE) AS FIRST_ORDER_DATE FROM NW.ORDERS X GROUP BY CUSTOMER_ID) B
	ON A.CUSTOMER_ID = B.CUSTOMER_ID;

-- 고객정보와 고객이 처음 주문한 일자의 주문 일자와 그때의 배송 주소, 배송 일자 추출
SELECT A.CUSTOMER_ID, A.CONTACT_NAME
	, (SELECT MIN(ORDER_DATE) FROM NW.ORDERS X WHERE X.CUSTOMER_ID = A.CUSTOMER_ID) AS FIRST_ORDER_DATE
	, (SELECT X.SHIP_ADDRESS FROM NW.ORDERS X WHERE X.CUSTOMER_ID=A.CUSTOMER_ID AND X.ORDER_DATE =
	          (SELECT MIN(ORDER_DATE) FROM NW.ORDERS Y WHERE Y.CUSTOMER_ID = X.CUSTOMER_ID)
	  ) AS FIRST_SHIP_ADDRESS
	, (SELECT X.SHIPPED_DATE FROM NW.ORDERS X WHERE X.CUSTOMER_ID=A.CUSTOMER_ID AND X.ORDER_DATE =
	          (SELECT MIN(ORDER_DATE) FROM NW.ORDERS Y WHERE Y.CUSTOMER_ID = X.CUSTOMER_ID)
      ) AS FIRST_SHIPPED_DATE
FROM NW.CUSTOMERS A
ORDER BY A.CUSTOMER_ID;

-- 조인으로 변경.
SELECT A.CUSTOMER_ID, A.CONTACT_NAME
	, B.ORDER_DATE, B.SHIP_ADDRESS, B.SHIPPED_DATE
FROM NW.CUSTOMERS A
	LEFT JOIN NW.ORDERS B ON A.CUSTOMER_ID = B.CUSTOMER_ID
	AND B.ORDER_DATE = (SELECT MIN(ORDER_DATE) FROM NW.ORDERS X
						  WHERE A.CUSTOMER_ID = X.CUSTOMER_ID
						  )
ORDER BY A.CUSTOMER_ID;


-- 고객정보와 고객이 마지막 주문한 일자의 주문 일자와 그때의 배송 주소, 배송 일자 추출
-- 현재 데이터가 고객이 하루에 주문을 두번한 경우가 있음. MAX(ORDER_DATE) 시 고객이 하루에 주문을 두번한 일자가 나오고 있음
-- 때문에 반드시 1개의 값만 스칼라 서브쿼리에서 반환하도록 LIMIT 1 추가
SELECT A.CUSTOMER_ID, A.CONTACT_NAME
	, (SELECT MAX(ORDER_DATE) FROM NW.ORDERS X WHERE X.CUSTOMER_ID = A.CUSTOMER_ID) AS LAST_ORDER_DATE
	, (SELECT X.SHIP_ADDRESS FROM NW.ORDERS X WHERE X.CUSTOMER_ID=A.CUSTOMER_ID AND X.ORDER_DATE =
	          (SELECT MAX(ORDER_DATE) FROM NW.ORDERS Y WHERE Y.CUSTOMER_ID = X.CUSTOMER_ID)
	          LIMIT 1
	  ) AS LAST_SHIP_ADDRESS
	, (SELECT X.SHIPPED_DATE FROM NW.ORDERS X WHERE X.CUSTOMER_ID=A.CUSTOMER_ID AND X.ORDER_DATE =
	          (SELECT MAX(ORDER_DATE) FROM NW.ORDERS Y WHERE Y.CUSTOMER_ID = X.CUSTOMER_ID)
	          LIMIT 1) AS LAST_SHIPPED_DATE
FROM NW.CUSTOMERS A
ORDER BY A.CUSTOMER_ID;

-- 조인으로 변경
SELECT A.CUSTOMER_ID, A.CONTACT_NAME
	, B.ORDER_DATE, B.SHIP_ADDRESS, B.SHIPPED_DATE
	--, ROW_NUMBER() OVER (PARTITION BY A.CUSTOMER_ID ORDER BY B.ORDER_DATE DESC) AS RNUM
FROM NW.CUSTOMERS A
	LEFT JOIN NW.ORDERS B ON A.CUSTOMER_ID = B.CUSTOMER_ID
	AND B.ORDER_DATE = (SELECT MAX(ORDER_DATE) FROM NW.ORDERS X
						  WHERE A.CUSTOMER_ID = X.CUSTOMER_ID
					   )
	--WHERE A.CUSTOMER_ID = 'ALFKI'
	--LIMIT 1
;