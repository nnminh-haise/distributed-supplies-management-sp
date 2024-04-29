USE [QLVT_DATHANG]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_EMPLOYEE]    Script Date: 4/28/2024 3:06:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- * UPDATE EMPLOYEE INFORMATION WITH CHANGE BRANCH FUNCTIONALITY
--
-- * ALGORITHM:
-- 1. CHECKING IF THE USER IS CHANGING BRANCH OR NOT.
-- 2. IF TRUE, PERFORM THE CHANGE BRANCH THEN PERFORM THE UPDATE PROCESS.
-- 3. OTHERWISE, PERFORM THE UPDATE INFORMATION PROCESS ONLY.
--
-- * NOTES:
-- 1. FIELD CAN BE UPDATED: HO, TEN, DIACHI, NGAYSINH, LUONG, THE OTHER ARE IMMUTABLE
-- 2. @MACN_CU AND @MACN_MOI ONLY FOR CHECKING IF THE CHANGE BRANCH OPERATION IS NEEDED OR NOT.
-- 3. @MANV AND @CMND IS USED TO INDICATE THE TARGETING EMPLOYEE

ALTER PROCEDURE [dbo].[SP_UPDATE_EMPLOYEE]
  @MANV INT,
  @CMND NVARCHAR(20),
  @HO NVARCHAR(20),
  @TEN NVARCHAR(50),
  @DIACHI NVARCHAR(100),
  @NGAYSINH DATE,
  @LUONG FLOAT,
  @MACN_MOI NVARCHAR(3),
  @MACN_CU NVARCHAR(3)
AS
  SET XACT_ABORT ON;
  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN
    BEGIN DISTRIBUTED TRAN
    -- * CHECKING IF THE CHANGE BRANCH OPERATION WILL BE EXECUTED OR NOT.
    IF @MACN_CU <> @MACN_MOI
	-- * CHANGE BRANCH AND UPDATE EMPLOYEE INFORMATION PROCESS
	BEGIN
		-- * CHECKING IF THE TARGETING EMPLOYEE IS USED TO WORK AT THE NEW BRANCH (1)
		IF EXISTS (SELECT 1 FROM LINK1.QLVT_DATHANG.dbo.NhanVien WHERE CMND = @CMND)
		BEGIN
			-- PROCESS IF (1) IS TRUE
			UPDATE LINK1.QLVT_DATHANG.dbo.NhanVien SET
				HO = @HO,
				TEN = @TEN,
				DIACHI = @DIACHI,
				NGAYSINH = @NGAYSINH,
				LUONG = @LUONG,
				TrangThaiXoa = 0
			WHERE MANV = (SELECT MANV FROM LINK1.QLVT_DATHANG.dbo.NhanVien WHERE CMND = @CMND)
		END
        ELSE -- PROCESS IF (1) IS FALSE
		BEGIN
			-- * GENERATE NEW EMPLOYEE ID AT NEW BRANCH
			DECLARE @MANV_MOI INT;
            EXEC SP_GET_EMPLOYEE_ID @MACN = @MACN_MOI, @MANV_MOI = @MANV_MOI OUTPUT;

            -- * INSERT A NEW EMPLOYEE INTO THE NEW BRANCH
            INSERT INTO LINK1.QLVT_DATHANG.dbo.NhanVien
					(MANV, CMND, HO, TEN, DIACHI, NGAYSINH, LUONG, MACN, TRANGTHAIXOA)
            VALUES	(@MANV_MOI, @CMND, @HO, @TEN, @DIACHI, @NGAYSINH, @LUONG, @MACN_MOI, 0)
		END

        -- * UPDATE THE DELETE STATUS OF THE CURRENT BRANCH OF THE TARGETING EMPLOYEE TO BE 1 (DELETED)
        UPDATE dbo.NhanVien SET TrangThaiXoa = 1 WHERE MANV = @MANV
      END
    ELSE
	BEGIN -- * UPDATE EMPLOYEE INFORMATION PROCESS
		UPDATE NHANVIEN SET
			HO = @HO,
			TEN = @TEN,
			DIACHI = @DIACHI,
			NGAYSINH = @NGAYSINH,
			LUONG = @LUONG
		WHERE TRANGTHAIXOA = 0 AND MANV = @MANV
	END
    COMMIT TRAN
END