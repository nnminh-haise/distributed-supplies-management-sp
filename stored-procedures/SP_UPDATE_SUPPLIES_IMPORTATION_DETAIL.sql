USE [QLVT_DATHANG]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_SUPPLIES_IMPORTATION_DETAIL]    Script Date: 6/17/2024 9:09:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Le Van Dung
-- Create date: 17/6/2024
-- =============================================
CREATE PROCEDURE [dbo].[SP_UPDATE_SUPPLIES_IMPORTATION_DETAIL]
	@MAPN NCHAR(8), @MAVT NCHAR(4), @SOLUONG INT, @DONGIA FLOAT
AS
	-- Automaically rollback when throwing exc.
	SET XACT_ABORT ON;
	-- Close transaction in the current session of this SP.
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN
    BEGIN TRAN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @SOLUONG_TU_CTDDH INT;
	SELECT TOP 1 @SOLUONG_TU_CTDDH=SOLUONG FROM CTDDH WHERE MAVT=@MAVT AND MasoDDH=(SELECT TOP 1 MasoDDH FROM PhieuNhap WHERE MAPN=@MAPN);
	IF (@SOLUONG > @SOLUONG_TU_CTDDH)
		-- Không thể tăng số lượng vượt quá số lượng từ vật tư ở CTDDH tương ứng.
		THROW 51000, '-2', 1;
		
	--Lấy số lượng cũ ra trước để tính toán lại SOLUONGTON cho đúng.
	DECLARE @SOLUONGTON INT, @SOLUONG_CU INT, @DOLECH INT;
	SELECT TOP 1 @SOLUONG_CU=SOLUONG FROM CTPN WHERE MAPN=@MAPN AND MAVT=@MAVT;
	IF (@SOLUONG >= @SOLUONG_CU) BEGIN
		SET @DOLECH = @SOLUONG - @SOLUONG_CU;
		-- Kiểm tra số lượng tồn rồi cộng thêm vào khi nhập vào Vattu, khi SOLUONG cập nhật lớn hơn SOLUONGCU (May throw exc).
		EXEC SP_UPDATE_SUPPLY_QUANTITY @OPTION='ADD', @MAVT = @MAVT, @SOLUONG = @DOLECH;
	END;
	ELSE BEGIN
		SET @DOLECH = @SOLUONG_CU - @SOLUONG;
		-- Kiểm tra số lượng tồn rồi trừ bớt khi nhập vào Vattu, khi SOLUONG cập nhật bé hơn SOLUONGCU (May throw exc).
		EXEC SP_UPDATE_SUPPLY_QUANTITY @OPTION='SUBTRACT', @MAVT = @MAVT, @SOLUONG = @DOLECH;
	END;

	UPDATE CTPN SET SOLUONG=@SOLUONG, DONGIA=@DONGIA WHERE MAPN=@MAPN AND MAVT=@MAVT;
	
    COMMIT TRAN;
END
