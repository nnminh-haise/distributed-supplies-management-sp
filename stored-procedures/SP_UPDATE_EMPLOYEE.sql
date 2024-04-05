CREATE DECLARE SP_UPDATE_EMPLOYEE
  @MANV INT,
  @CMND NVARCHAR(10),
  @HO NVARCHAR(20),
  @TEN NVARCHAR(50),
  @DIACHI NVARCHAR(100),
  @NGAYSINH DATE,
  @LUONG FLOAT,
  @CHINHANH NVARCHAR(3),
  @CHANGE_BRANCH INT,
  @NEW_CHINHANH NVARCHAR(3),
  @NEW_MANV INT
AS
  SET XACT_ABORT ON;
  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN
  BEGIN DISTRIBUTED TRAN
  
    -- * IF THE EMPLOYEE CHANGE THEIR BRANCH
    IF @CHANGE_BRANCH = 1
      BEGIN
        -- * CHECKING IF THE EMPLOYEE USED TO WORK AT THE OTHER BRANCH, IF TRUE
        IF EXISTS (SELECT MANV FROM LINK1.QLVT_DATHANG.dbo.NhanVien WHERE CMND = @CMND)
          BEGIN
            UPDATE LINK1.QLVT_DATHANG.dbo.NhanVien
            SET
              HO = @HO,
              TEN = @TEN,
              DIACHI = @DIACHI,
              NGAYSINH = @NGAYSINH,
              LUONG = @LUONG,
              TrangThaiXoa = 0
            WHERE MANV = (SELECT MANV FROM LINK1.QLVT_DATHANG.dbo.NhanVien WHERE CMND = @CMND)
          END
        -- * OTHERWISE, THE EMPLOYEE IS A NEW RECORD OF THE OTHER BRANCH
        ELSE 
          BEGIN
            INSERT INTO LINK1.QLVT_DATHANG.dbo.NhanVien (
              MANV, CMND, HO, TEN, DIACHI, NGAYSINH, LUONG, MACN, TRANGTHAIXOA
            )
            VALUES (
              @NEW_MANV, @CMND, @HO, @TEN, @DIACHI, @NGAYSINH, @LUONGNV, @NEW_CHINHANH, 0
            )
		    	END
		
        -- * Cập nhật lại trạng thái xoá của record nhân viên ở site cũ (site hiện tại)
        UPDATE dbo.NhanVien SET TrangThaiXoa = 1 WHERE MANV = @MANV
      END
    -- * IF THE EMPLOYEE NOT CHANGE THEIR BRANCH
    ELSE
      BEGIN
        UPDATE LINK1.QLVT_DATHANG.DBO.NHANVIEN
        SET
          HO = @HO,
          TEN = @TEN,
          DIACHI = @DIACHI,
          NGAYSINH = @NGAYSINH,
          LUONG = @LUONG,
          MACN = @CHINHANH
        WHERE
          TRANGTHAIXOA = 0 AND
          MANV = @MANV
      END
    COMMIT TRAN;
END