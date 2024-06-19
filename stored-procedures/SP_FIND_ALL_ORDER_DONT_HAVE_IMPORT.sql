USE [QLVT_DATHANG]
GO
/****** Object:  StoredProcedure [dbo].[SP_FIND_ALL_ORDER_DONT_HAVE_IMPORT]    Script Date: 19/06/24 10:53:10 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SP_FIND_ALL_ORDER_DONT_HAVE_IMPORT]
	@MORE_CONDITION NVARCHAR(MAX)
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX)
	SET @sql = N'
		SELECT
			MasoDDH, 
			Ngay, 
			NhaCC, 
			HOTEN,
			TENVT,
			SOLUONG,
			DONGIA
		FROM
			-- Taking all the orders and the employee''s information who imported that order.
			(SELECT
				MasoDDH,
				NGAY,
				NhaCC,
				HOTEN = (SELECT HOTEN = HO + '' '' + TEN FROM NhanVien 
							WHERE DatHang.MANV = NhanVien.MANV) 
				FROM DBO.DatHang) DH,
			-- Taking all the order details
			(SELECT MasoDDH AS MDDH, MAVT,SOLUONG,DONGIA FROM CTDDH ) CT,
			-- Taking supplies information
			(SELECT TENVT, MAVT FROM Vattu ) VT 
		WHERE MasoDDH = CT.MDDH
			AND VT.MAVT = CT.MAVT
			-- Exclude the orders which have not been imported yet.
			AND MasoDDH NOT IN (SELECT PhieuNhap.MasoDDH FROM PhieuNhap)
		'
    IF @MORE_CONDITION IS NOT NULL
    BEGIN
        SET @sql = @sql + N' AND ' + @MORE_CONDITION;
    END

    EXEC sp_executesql @sql;
END