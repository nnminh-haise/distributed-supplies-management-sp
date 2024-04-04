CREATE PROCEDURE SP_CHANGE_BRANCH
	@MANV INT, 
	@MACN nchar(10)
AS    
    SET XACT_ABORT ON;
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;  
BEGIN
	-- * Bắt đầu transaction phân tán
	BEGIN DISTRIBUTED TRAN
		DECLARE @HONV NVARCHAR(40)
		DECLARE @TENNV NVARCHAR(10)
		DECLARE @DIACHINV NVARCHAR(100)
		DECLARE @NGAYSINHNV DATETIME
		DECLARE @LUONGNV FLOAT						
		
        -- * Lấy thông tin nhân viên cũ để tiện cho việc kiểm tra.
		SELECT
            @HONV = HO,
            @TENNV = TEN,
			@CMND = CMND,
            @DIACHINV = DIACHI,
            @NGAYSINHNV = NGAYSINH,
            @LUONGNV = LUONG
        FROM NhanVien WHERE MANV = @MANV

        -- * Kiểm tra ở site sẽ chuyển tới đã có nhân viên đó chưa?
		-- * Nếu rồi thì đổi trạng thái, ngược lại sẽ thêm nhân viên vào.
		IF EXISTS(SELECT MANV FROM LINK1.QLVT_DATHANG.dbo.NhanVien WHERE CMND = @CMND)
		    BEGIN
				UPDATE LINK1.QLVT_DATHANG.dbo.NhanVien
				SET TrangThaiXoa = 0
				WHERE MANV = (SELECT MANV FROM LINK1.QLVT_DATHANG.dbo.NhanVien WHERE CMND = @CMND)
		    END
		-- * Chưa tồn tại nhân viên ở site sẽ chuyển đến thì ta sẽ thêm mới 
		-- * hoàn toàn vào chi nhánh mới với mã nhân viên mới sẽ theo công thức: MANV_MOI = Max(MANV) + 1
        ELSE 
		    BEGIN
			    INSERT INTO LINK1.QLVT_DATHANG.dbo.NhanVien
                    (MANV, CMND, HO, TEN, DIACHI, NGAYSINH, LUONG, MACN, TRANGTHAIXOA)
			    VALUES (
                    (SELECT MAX(MANV) FROM LINK0.QLVT_DATHANG.dbo.NhanVien) + 1, @CMND,
					@HONV, @TENNV, @DIACHINV, @NGAYSINHNV, @LUONGNV, @MACN, 0)
		    END
		
        -- Cập nhật lại trạng thái xoá của record nhân viên ở site cũ (site hiện tại)
		UPDATE dbo.NhanVien SET TrangThaiXoa = 1 WHERE MANV = @MANV
	COMMIT TRAN; -- Kết thúc transaction phân tán
END
