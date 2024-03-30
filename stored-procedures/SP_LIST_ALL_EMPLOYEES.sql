CREATE PROCEDURE SP_LIST_ALL_EMPLOYEES
    @ROLE NVARCHAR(8),
    @CHINHANH NCHAR(3)
AS
BEGIN
    IF @ROLE = 'CongTy'
        BEGIN
            DECLARE @REQUESTING_AT_CURRENT_BRANCH INT
            IF (EXISTS(SELECT 1 FROM NHANVIEN AS NV WHERE NV.MACN = @CHINHANH))
                @REQUESTING_AT_CURRENT_BRANCH = 1
            ELSE
                @REQUESTING_AT_CURRENT_BRANCH = 0

            IF @REQUESTING_AT_CURRENT_BRANCH = 1
                BEGIN
                    SELECT
                        NV.MANV AS MANV,
                        NV.CMND AS CMND,
                        HO + ' ' + TEN AS HO_TEN,
                        MV.DAICHI AS DIACHI
                    FROM NHANVIEN AS NV
                    ORDER BY HO + ' ' + TEN AS HO_TEN
                END
            ELSE
                BEGIN
                    SELECT
                        NV.MANV AS MANV,
                        NV.CMND AS CMND,
                        HO + ' ' + TEN AS HO_TEN,
                        MV.DAICHI AS DIACHI
                    FROM LINK1.QLVT_DATHANG.DBO.NHANVIEN AS NV
                    ORDER BY HO + ' ' + TEN AS HO_TEN
                END
        END
    ELSE IF @ROLE = 'CHINHANH'
        BEGIN
            SELECT
                NV.MANV AS MANV,
                NV.CMND AS CMND,
                HO + ' ' + TEN AS HO_TEN,
                MV.DAICHI AS DIACHI
            FROM NHANVIEN AS NV
            ORDER BY HO + ' ' + TEN AS HO_TEN
        END
END