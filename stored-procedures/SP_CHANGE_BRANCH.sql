CREATE PROCEDURE SP_CHANGE_BRANCH
	@MANV INT, 
	@MACN nchar(10)
AS
    DECLARE @LGNAME VARCHAR(50)
    DECLARE @USERNAME VARCHAR(50)
    
    SET XACT_ABORT ON;
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    
BEGIN
	BEGIN DISTRIBUTED TRAN -- Bắt đầu transaction phân tán
		DECLARE @HONV NVARCHAR(40)
		DECLARE @TENNV NVARCHAR(10)
		DECLARE @DIACHINV NVARCHAR(100)
		DECLARE @NGAYSINHNV DATETIME
		DECLARE @LUONGNV FLOAT						
		
        -- Lấy thông tin nhân viên cũ để tiện cho việc kiểm tra.
		SELECT
            @HONV = HO,
            @TENNV = TEN,
            @DIACHINV = DIACHI,
            @NGAYSINHNV = NGAYSINH,
            @LUONGNV = LUONG
        FROM NhanVien WHERE MANV = @MANV

        -- Kiểm tra ở site sẽ chuyển tới đã có nhân viên đó chưa? Nếu rồi thì đổi trạng thái, ngược lại sẽ thêm nhân viên vào.
		IF EXISTS(SELECT MANV FROM LINK1.QLVT_DATHANG.dbo.NhanVien
			        WHERE HO = @HONV
                        AND TEN = @TENNV
                        AND DIACHI = @DIACHINV
                        AND NGAYSINH = @NGAYSINHNV
                        AND LUONG = @LUONGNV)
		    BEGIN
				UPDATE LINK1.QLVT_DATHANG.dbo.NhanVien
				SET TrangThaiXoa = 0
				WHERE MANV = (SELECT MANV FROM LINK1.QLVT_DATHANG.dbo.NhanVien
								WHERE HO = @HONV
                                    AND TEN = @TENNV
                                    AND DIACHI = @DIACHINV
									AND NGAYSINH = @NGAYSINHNV
                                    AND LUONG = @LUONGNV)
		    END
		-- Chưa tồn tại nhân viên ở site sẽ chuyển đến thì ta sẽ thêm mới hoàn toàn vào chi nhánh mới với mã nhân viên mới sẽ theo công thức: MANV_MOI = Max(MANV) + 1
        ELSE 
		    BEGIN
			    INSERT INTO LINK1.QLVT_DATHANG.dbo.NhanVien
                    (MANV, HO, TEN, DIACHI, NGAYSINH, LUONG, MACN, TRANGTHAIXOA)
			    VALUES (
                    (SELECT MAX(MANV) FROM LINK0.QLVT_DATHANG.dbo.NhanVien) + 1, @HONV, @TENNV, @DIACHINV, @NGAYSINHNV, @LUONGNV, @MACN, 0)
		    END
		
        -- Cập nhật lại trạng thái xoá của record nhân viên ở site cũ (site hiện tại)
		UPDATE dbo.NhanVien SET TrangThaiXoa = 1 WHERE MANV = @MANV
	COMMIT TRAN; -- Kết thúc transaction phân tán

	-- Lưu ý: sp_droplogin và sp_dropuser không thể được thực thi trong một giao tác do người dùng định nghĩa
	
    -- Kiểm tra xem Nhân viên đã có login chưa, nếu đã có rồi thì xóa login đó đi
	IF EXISTS (SELECT SUSER_SNAME(sid) FROM sys.sysusers
                WHERE name = CAST(@MANV AS NVARCHAR))
		BEGIN
			SET @LGNAME = CAST((SELECT SUSER_SNAME(sid) FROM sys.sysusers
                                WHERE name = CAST(@MANV AS NVARCHAR)) AS VARCHAR(50))
			SET @USERNAME = CAST(@MANV AS VARCHAR(50))
			EXEC SP_DROPUSER @USERNAME;
			EXEC SP_DROPLOGIN @LGNAME;
		END	
END
