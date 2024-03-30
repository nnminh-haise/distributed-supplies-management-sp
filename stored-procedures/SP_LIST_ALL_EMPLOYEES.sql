CREATE PROCEDURE SP_LIST_ALL_EMPLOYEES
    @ROLE NVARCHAR(8),
    @CHINHANH NCHAR(3)
AS
BEGIN
    IF @ROLE = 'CongTy'
        BEGIN
            DECLARE @REQUESTING_AT_CURRENT_BRANCH INT
            IF (EXISTS(SELECT 1 FROM NHANVIEN AS NV WHERE NV.MACN = @CHINHANH))
                SET @REQUESTING_AT_CURRENT_BRANCH = 1
            ELSE
                SET @REQUESTING_AT_CURRENT_BRANCH = 0

            IF @REQUESTING_AT_CURRENT_BRANCH = 1
                BEGIN
                    SELECT
                        NV.MANV AS MANV,
                        NV.CMND AS CMND,
                        HO + ' ' + TEN AS HO_TEN,
                        MV.DIACHI AS DIACHI
                    FROM NHANVIEN AS NV
                    ORDER BY HO + ' ' + TEN AS HO_TEN
                END
            ELSE
                BEGIN
                    SELECT
                        NV.MANV AS MANV,
                        NV.CMND AS CMND,
                        HO + ' ' + TEN AS HO_TEN,
                        MV.DIACHI AS DIACHI
                    FROM LINK1.QLVT_DATHANG.DBO.NHANVIEN AS NV
                    ORDER BY HO + ' ' + TEN AS HO_TEN
                END
        END
    ELSE IF @ROLE = 'ChiNhanh'
        BEGIN
            SELECT
                NV.MANV AS MANV,
                NV.CMND AS CMND,
                HO + ' ' + TEN AS HO_TEN,
                MV.DIACHI AS DIACHI
            FROM NHANVIEN AS NV
            ORDER BY HO + ' ' + TEN AS HO_TEN
        END
END