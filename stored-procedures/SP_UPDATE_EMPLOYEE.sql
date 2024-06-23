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

CREATE PROCEDURE [dbo].[SP_UPDATE_EMPLOYEE]
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
	IF NOT EXISTS(SELECT 1 FROM NhanVien WHERE TrangThaiXoa = 0 AND MANV = @MANV)
		THROW 51000, 'Employee Id not found', 1;

  BEGIN DISTRIBUTED TRAN
  -- * Check if change branch operation will be executed or not.
  IF @MACN_CU <> @MACN_MOI BEGIN -- * Execute this block when the change branch operation need to be executed
		-- * Check if the employee have been worked at the new branch.
		IF EXISTS (SELECT 1 FROM LINK1.QLVT_DATHANG.dbo.NhanVien WHERE CMND = @CMND) BEGIN -- * Exist an employee at the new branch
			-- * Update the employee information
			UPDATE LINK1.QLVT_DATHANG.dbo.NhanVien SET
				HO = @HO,
				TEN = @TEN,
				DIACHI = @DIACHI,
				NGAYSINH = @NGAYSINH,
				LUONG = @LUONG,
				TrangThaiXoa = 0
			WHERE MANV = (SELECT MANV FROM LINK1.QLVT_DATHANG.dbo.NhanVien WHERE CMND = @CMND)
		END
		ELSE BEGIN -- * Execute when the employee have not worked at the new branch
			-- * Generate a new employee id for the new employee.
			DECLARE @MANV_MOI INT;
			EXEC SP_GET_EMPLOYEE_ID 
				@MACN = @MACN_MOI,
				@MANV_MOI = @MANV_MOI OUTPUT;

			-- * Insert a new employee into the new branch with updated information
			INSERT INTO LINK1.QLVT_DATHANG.dbo.NhanVien
				(MANV, CMND, HO, TEN, DIACHI, NGAYSINH, LUONG, MACN, TRANGTHAIXOA)
			VALUES (@MANV_MOI, @CMND, @HO, @TEN, @DIACHI, @NGAYSINH, @LUONG, @MACN_MOI, 0)
		END

		-- * Change the delete status of the employee at the current branch to 1.
		UPDATE dbo.NhanVien SET TrangThaiXoa = 1 WHERE MANV = @MANV
	END
	ELSE BEGIN -- * Update employee information
		UPDATE NHANVIEN SET
			HO = @HO,
			TEN = @TEN,
			CMND = @CMND,
			DIACHI = @DIACHI,
			NGAYSINH = @NGAYSINH,
			LUONG = @LUONG
		WHERE TRANGTHAIXOA = 0 AND MANV = @MANV
	END
  COMMIT TRAN
END