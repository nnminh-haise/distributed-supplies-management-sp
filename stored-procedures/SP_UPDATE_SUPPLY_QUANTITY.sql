CREATE PROCEDURE SP_UPDATE_SUPPLY_QUANTITY
	@OPTION NVARCHAR(6),
	@MAVT NCHAR(4),
	@SOLUONG INT
AS
BEGIN
    -- CASE WHEN THE SUPPLIES ARE EXPORTED
	IF (@OPTION = 'EXPORT')
        BEGIN
            IF (EXISTS(SELECT * FROM DBO.Vattu AS VT WHERE VT.MAVT = @MAVT))
                BEGIN
                    UPDATE DBO.Vattu
                    SET SOLUONGTON = SOLUONGTON - @SOLUONG
                    WHERE MAVT = @MAVT
                END
        END
	-- CASE WHEN THE SUPPLIES ARE IMPORTED
    ELSE IF( @OPTION = 'IMPORT')
        BEGIN
            IF (EXISTS(SELECT * FROM DBO.Vattu AS VT WHERE VT.MAVT = @MAVT))
                BEGIN
                    UPDATE DBO.Vattu
                    SET SOLUONGTON = SOLUONGTON + @SOLUONG
                    WHERE MAVT = @MAVT
                END
        END
END