SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Le Van Dung
-- Create date: 17/6/2024
-- =============================================
CREATE PROCEDURE SP_ADD_SUPPLIES_IMPORTATION_DETAIL
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

	DECLARE @SOLUONGTON INT;

    -- Kiểm tra số lượng tồn rồi cộng thêm vào khi nhập vào Vattu.
	-- May throw exc.
	EXEC SP_UPDATE_SUPPLY_QUANTITY @OPTION='ADD', @MAVT = @MAVT, @SOLUONG = @SOLUONG;

	INSERT INTO CTPN (MAPN, MAVT, SOLUONG, DONGIA) VALUES (@MAPN, @MAVT, @SOLUONG, @DONGIA);
	
    COMMIT TRAN;
END
GO
