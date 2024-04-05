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
    @NEW_CHINHANH NVARCHAR(3)
AS
    SET XACT_ABORT ON;
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN
    BEGIN DISTRIBUTED TRAN
        UPDATE NhanVien
        SET
            MANV = @MANV,
            CMND = @CMND,
            HO = @HO,
            TEN = @TEN,
            DIACHI = @DIACHI,
            NGAYSINH = @NGAYSINH,
            LUONG = @LUONG,
            MACN = @CHINHANH
        WHERE
            MANV = @MANV

        IF EXIST(SELECT MANV FROM LINK1.QLVT_DATHANG.DB.NhanVien
                    WHERE CMND = @CMND)
            BEGIN
                UPDATE LINK1.QLVT_DATHANG.DBO.NhanVien
                SET TrangThaiXoa = 0
                WHERE MANV = (SELECT MANV FROM LINK1.QLVT_DATHANG.DB.NhanVien WHERE CMND = @CMND)
            END
        ELSE
            BEGIN
                INSERT INTO LINK1.QLVT_DATHANG.DBO.NhanVien
                    (MANV, CMND, HO, TEN, DIACHI, NGAYSINH, LUONG, MACN, TRANGTHAIXOA)
                VALUES
                    ((SELECT MAX(MANV) FROM LINK0.QLVT_DATHANG.DBO.NhanVien) + 1, 
                        @CMND, @HO, @TEN, @DIACHI, @NGAYSINH, @LUONG, @NEW_CHINHANH, 0)
            END
        
        UPDATE NhanVien SET TrangThaiXoa = 1 WHERE MANV = @MANV
    COMMIT TRAN;
END