USE [QLVT_DATHANG]
GO

/****** Object:  StoredProcedure [dbo].[SP_CHECK_USING_SUPPLY]    Script Date: 04/05/24 11:08:08 CH ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_CHECK_USING_SUPPLY]
    @MAVT NVARCHAR(4)
AS
BEGIN
	-- CHECK THE SUPPLY ID IS USED IN CTPN OR CTPX IN CURRENT SITE
    IF EXISTS( SELECT 1 FROM Vattu WHERE 
		MAVT = @MAVT AND				
		(EXISTS(SELECT 1 FROM CTPN WHERE CTPN.MAVT = @MAVT) OR 
		EXISTS(SELECT 1 FROM CTPX WHERE CTPX.MAVT = @MAVT)) )
		RETURN 1;
	-- CHECK THE SUPPLY ID IS USED IN CTPN OR CTPX IN OTHER SITE
	IF EXISTS( SELECT 1 FROM Vattu WHERE 
		MAVT = @MAVT AND				
		(EXISTS(SELECT 1 FROM LINK1.QLVT_DATHANG.DBO.CTPN WHERE CTPN.MAVT = @MAVT) OR 
		EXISTS(SELECT 1 FROM LINK1.QLVT_DATHANG.DBO.CTPX WHERE CTPX.MAVT = @MAVT)) )
		RETURN 1;
	RETURN 0;
END
GO
