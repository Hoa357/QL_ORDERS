SELECT *
FROM [CUSTOMER]

SELECT *
FROM [PRODUCT]

SELECT *
FROM [ORDER]

SELECT *
FROM [ORDERDETAIL]

-- Truy vấn danh sách các đơn hàng có doanh thu cao nhất (top 10 đơn hàng có Sales cao nhất)---
SELECT TOP 10 [Product ID], SUM(Quantity) AS total_quantity
FROM [ORDERDETAIL]
GROUP BY [ORDERDETAIL].[Product ID]
ORDER BY total_quantity DESC


-- Truy vấn chi tiết tất cả thông tin đơn hàng -----
SELECT *
FROM [ORDERDETAIL]
JOIN [PRODUCT] ON [PRODUCT].[Product ID]= [ORDERDETAIL].[Product ID]
JOIN [ORDER] ON [ORDER].[Order ID] = [ORDERDETAIL].[Order ID] 
JOIN [CUSTOMER] ON [CUSTOMER].[Customer ID] = [ORDER].[Customer ID]
WHERE [ORDER].[Order ID] = 'IN-2014-12911'

-- Truy vấn tổng doanh thu từng quốc gia---                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
SELECT country, SUM(sales) AS total_sales
FROM [ORDER]
JOIN [ORDERDETAIL] ON [ORDER].[Order ID]= [ORDERDETAIL].[Order ID]
GROUP BY country
ORDER BY total_sales DESC;


--Truy vấn danh sách các đơn hàng được vận chuyển bằng phương thức Same Day--
SELECT *
FROM [ORDER]
WHERE [ORDER].[Ship Mode] = 'Same Day';

-- Truy vấn tổng lợi nhuận (Profit) từng năm:
SELECT YEAR([Order Date]) AS order_year, SUM(Profit) AS total_profit
FROM [ORDER]
JOIN [ORDERDETAIL] ON [ORDER].[Order ID]= [ORDERDETAIL].[Order ID]
GROUP BY YEAR([Order Date])
ORDER BY YEAR([Order Date]);


/*============================================================== Vd về hàm ======================================================================== */

/*===================================================== Hàm hệ thống: Các hàm có sẵn ============================================================== */

/*== DATEDIFF ==*/

SELECT [ORDER].[Order ID], [ORDER].[Order Date] , [ORDER].[Ship Date],[ORDER].[Ship Mode], DATEDIFF(DAY, [ORDER].[Order Date] , [ORDER].[Ship Date]) AS TONG_NG
	FROM [ORDER]
	WHERE DATEDIFF(DAY, [ORDER].[Order Date] , [ORDER].[Ship Date]) >
	CASE
		WHEN [Ship Mode] = 'Second Class' THEN 2
		 WHEN [Ship Mode] = 'First Class' THEN 1
		 WHEN [Ship Mode] = 'Same day' THEN  0
		ELSE 3
    END

/*== REPLACE ==*/

SELECT *
FROM [ORDER]

SELECT [ORDER].[Customer ID], REPLACE([ORDER].[Customer ID], 'SV', 'XX') AS NewCustomerID
FROM [ORDER]

/*== LIKE ==*/

SELECT *
FROM [CUSTOMER]
WHERE [CUSTOMER].[Customer ID] LIKE 'RD%'


/*== LOWER ><  UPPER ==*/

SELECT [CUSTOMER].[Customer Name] ,UPPER( [CUSTOMER].[Customer Name]) 
FROM [CUSTOMER]

SELECT [CUSTOMER].[Customer Name] , LOWER([CUSTOMER].[Customer Name]) 
FROM [CUSTOMER]

/*== SUBSTRING ==*/
SELECT *
FROM [ORDERDETAIL]

SELECT [ORDERDETAIL].[Product ID] ,SUBSTRING([ORDERDETAIL].[Product ID], 1, 3) 
FROM  [ORDERDETAIL]

SELECT [ORDERDETAIL].[Product ID] ,SUBSTRING([ORDERDETAIL].[Product ID], 5, 3) 
FROM  [ORDERDETAIL]

/*== CHARINDEX ==*/


SELECT [ORDERDETAIL].[Product ID] ,CHARINDEX('ST',[ORDERDETAIL].[Product ID]) 
FROM  [ORDERDETAIL]

SELECT [ORDERDETAIL].[Product ID] ,CHARINDEX('OFF',[ORDERDETAIL].[Product ID]) 
FROM  [ORDERDETAIL]


/*============================================================== Hàm người dùng: Hàm tự định nghĩa  ====================================================== */

                 ------------------------------------------ Scalar Valued Fuction --(Hàm vô hướng )--------------------------------------------------
                                              /*=== Hàm trả về duy nhất 1 giá trị bằng lệnh RETURN === */


-----------Chi phí của một đơn hàng-------------

CREATE FUNCTION XEM_DH_GIA2(@OrderID VARCHAR(30))
RETURNS VARCHAR(30)
AS
BEGIN 
    DECLARE @Shipcost MONEY

    -- Kiểm tra xem Order ID có tồn tại không
    IF NOT EXISTS (SELECT 1 FROM [ORDER] WHERE [Order ID] = @OrderID)
    BEGIN
        RETURN 'Order ID not found'  
    END

    SELECT @Shipcost = SUM([ORDER].[Shipping Cost])
    FROM [ORDER]
    WHERE [Order ID] = @OrderID
	GROUP BY [ORDER].[Order ID]
    
    RETURN CONVERT(VARCHAR(30), @Shipcost)
END





CREATE FUNCTION XEM_DH_GIATEST(@OrderID VARCHAR(30))
RETURNS NVARCHAR(30)
AS
BEGIN 
    DECLARE @Shipcost MONEY

    
    IF @OrderID NOT IN   (SELECT [Order ID] FROM [ORDER] WHERE [Order ID] = @OrderID )
    BEGIN
        RETURN 'Order ID not found'  
    END

    SELECT @Shipcost = SUM([ORDER].[Shipping Cost])
    FROM [ORDER]
    WHERE [ORDER].[Order ID] = @OrderID
	GROUP BY [ORDER].[Order ID]
    RETURN CONVERT(VARCHAR(30), @Shipcost)
END

--==========

--Tổng giá tiền vận chuyển theo 1 mã --
SELECT dbo.XEM_DH_GIA2('AE-2013-1130') AS GIAVANCHUYEN

SELECT dbo.XEM_DH_GIATEST('AE-2013-1130') AS GIAVC

--Tổng giá tiền vận chuyển theo nhiều mã --
SELECT [ORDER].[Order ID], [ORDER].[Product ID],[ORDER].[Customer ID] , dbo.XEM_DH_GIA([ORDER].[Order ID]) AS GIAVC_1_DH
FROM [ORDER]
GROUP BY [ORDER].[Order ID], [ORDER].[Product ID],[ORDER].[Customer ID] 




-----------Đơn hàng có tổng tiền nhiều nhất-------------


CREATE FUNCTION MAX_GIAGIAM_MA()
RETURNS NVARCHAR(20)
AS
BEGIN 
  DECLARE @ORDERID NVARCHAR(20)
  SET @ORDERID = ( SELECT [ORDERDETAIL].[Order ID]
                    FROM [ORDERDETAIL]
					GROUP BY  [ORDERDETAIL].[Order ID]
					HAVING SUM([ORDERDETAIL].[Discount]) >= ALL( SELECT SUM([ORDERDETAIL].[Discount])
					                                             FROM [ORDERDETAIL]
																 GROUP BY  [ORDERDETAIL].[Order ID]
																 )
				)
  RETURN @ORDERID
END




--==========


SELECT *
FROM [ORDERDETAIL]


DECLARE @ORDER NVARCHAR(20)
SELECT @ORDER = dbo.MAX_GIAGIAM_MA()
PRINT @ORDER





SELECT [ORDERDETAIL].[Order ID], SUM([ORDERDETAIL].[Discount]) AS SL
FROM [ORDERDETAIL]
GROUP BY  [ORDERDETAIL].[Order ID]
HAVING SUM([ORDERDETAIL].[Discount]) >0 


------------------------------------------  Table  Valued Fuction --(Hàm vô hướng )--------------------------------------------------
                                         /*=== Hàm trả về bảng bằng lệnh RETURN === */

-------------Hàm đọc bảng-----------------
---Lấy mã đơn đơn hàng có số lượng lớn hơn 5 ---
CREATE FUNCTION ORDERID_SL_HON5SP()
RETURNS TABLE
AS
RETURN 
                  ( SELECT [ORDERDETAIL].[Order ID], SUM([ORDERDETAIL].[Quantity]) AS SL_SP
                    FROM [ORDERDETAIL]
					GROUP BY  [ORDERDETAIL].[Order ID]
					HAVING SUM([ORDERDETAIL].[Discount]) > 5
					)


--=====
SELECT *
FROM DBO.ORDERID_SL_HON5SP() 


-------------Hàm tạo bảng  1-----------------

--Lấy mã khách hàng và tên khách hàng-----
GO
CREATE FUNCTION ID_CUSTOMER()
RETURNS @CUSTOMERTABLE TABLE
(
    CustomerID NVARCHAR(40),
    CustomerName NVARCHAR(50)   
)
AS
BEGIN
    INSERT INTO @CUSTOMERTABLE
    SELECT [Customer ID], [Customer Name]
    FROM [CUSTOMER]

    RETURN
END

---=====

GO
SELECT *
FROM  dbo.ID_CUSTOMER()


----------------Hàm tạo bảng 2---------------------


--Viết kiểm tra Đơn hàng nhập vào có ở Canada không --

GO
CREATE FUNCTION DH_CHECK_COUNTRY(@Madonhang NVARCHAR(30))
RETURNS @DH TABLE (OrderID NVARCHAR(20), CustomerID NVARCHAR(20), Country NVARCHAR(20), ProductID NVARCHAR(20))
AS
BEGIN 
    IF EXISTS (SELECT 1 
               FROM [ORDER]
               WHERE [ORDER].[Order ID] = @Madonhang AND [ORDER].[Country] = 'Canada')
    BEGIN
        INSERT INTO @DH 
        SELECT [ORDER].[Order ID], [ORDER].[Customer ID], [ORDER].[Country], [ORDER].[Product ID]
        FROM [ORDER]
        WHERE [ORDER].[Order ID] = @Madonhang AND [ORDER].[Country] = 'Canada';
    END
    ELSE
    BEGIN
        
        INSERT INTO @DH 
        VALUES ('0', '0', '0', 'Khong Co'); 
    END

    RETURN;
END

---=========
SELECT *
FROM [ORDER]


SELECT *
FROM DBO.CHITIET_DHSP('CA-2014-7620')


SELECT *
FROM DBO.CHITIET_DHSP('1620')


