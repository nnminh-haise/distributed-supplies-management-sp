CREATE PROCEDURE SP_FIND_ALL_ORDER_DONT_HAVE_IMPORT
AS
BEGIN
    SELECT
        DH.MasoDDH, 
        DH.Ngay, 
        DH.NhaCC, 
        HOTEN,
        TENVT,
        SOLUONG,
        DONGIA
    FROM
        -- Taking all the orders and the employee's information who imported that order.
        (SELECT
            MasoDDH,
            NGAY,
            NhaCC,
            HOTEN = (SELECT HOTEN = HO + ' ' + TEN FROM NhanVien 
						WHERE DatHang.MANV = NhanVien.MANV) 
	        FROM DBO.DatHang) DH,
        -- Taking all the order details
        (SELECT MasoDDH,MAVT,SOLUONG,DONGIA FROM CTDDH ) CT,
        -- Taking supplies information
        (SELECT TENVT, MAVT FROM Vattu ) VT
    WHERE CT.MasoDDH = DH.MasoDDH
        AND VT.MAVT = CT.MAVT
        -- Exclude the orders which have not been imported yet.
        AND DH.MasoDDH NOT IN (SELECT MasoDDH FROM PhieuNhap)
END