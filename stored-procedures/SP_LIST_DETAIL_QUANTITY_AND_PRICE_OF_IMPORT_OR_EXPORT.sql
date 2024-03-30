CREATE PROCEDURE SP_LIST_DETAIL_QUANTITY_AND_PRICE_OF_IMPORT_OR_EXPORT
    @ROLE NVARCHAR(8),
    @OPTION NCHAR(4),
    @FROM_DATE DATE,
    @TO_DATE DATE
AS
BEGIN
    -- FOR CONGTY ROLE
    IF @ROLE = 'CongTy'
        BEGIN
            -- FOR NHAP OPTION
            IF @OPTION = 'NHAP'
                BEGIN
                    SELECT
                        TKVT.THANG_NAM AS THANG_NAM,
                        VT.TENVT AS TEN_VAT_TU,
                        TKVT.TONG_SO_LUONG AS TONG_SO_LUONG,
                        TKVT.TONG_TRI_GIA AS TONG_TRI_GIA
                    FROM 
                        LINK2.QLVT_DATHANG.DBO.VATTU AS VT
                    INNER JOIN (
                        SELECT
                            FORMAT(PN.NGAY, 'MM-YYYY') AS THANG_NAM,
                                CTPN.MAVT AS MAVT,
                                SUM(CTPN.SOLUONG) AS TONG_SO_LUONG,
                                SUM(CTPN.SOLUONG * CTPN.DONGIA) AS TONG_TRI_GIA
                            FROM (
                                SELECT * FROM LINK2.QLVT_DATHANG.DBO.PHIEUNHAP
                                WHERE NGAY BETWEEN @FROM_DATE AND @TO_DATE
                            ) AS PN
                            INNER JOIN LINK2.QLVT_DATHANG.DBO.CTPN AS CTPN ON PN.MAPN = CTPN.MAPN
                            GROUP BY FORMAT(PN.NGAY, 'MM-YYYY'), CTPN.MAVT
                        ) AS TKVT ON VT.MAVT = TKVT.MAVT
                    ORDER BY TKVT.THANG_NAM, VT.TENVT ASC
                END
            -- FOR XUAT OPTION
            ELSE IF @OPTION = 'XUAT'
                BEGIN
                    SELECT
                        TKVT.THANG_NAM AS THANG_NAM,
                        VT.TENVT AS TEN_VAT_TU,
                        TKVT.TONG_SO_LUONG AS TONG_SO_LUONG,
                        TKVT.TONG_TRI_GIA AS TONG_TRI_GIA
                    FROM 
                        LINK2.QLVT_DATHANG.DBO.VATTU AS VT
                    INNER JOIN (
                        SELECT
                            FORMAT(PX.NGAY, 'MM-YYYY') AS THANG_NAM,
                                CTPX.MAVT AS MAVT,
                                SUM(CTPX.SOLUONG) AS TONG_SO_LUONG,
                                SUM(CTPX.SOLUONG * CTPX.DONGIA) AS TONG_TRI_GIA
                            FROM (
                                SELECT * FROM LINK2.QLVT_DATHANG.DBO.PHIEUNHAP
                                WHERE NGAY BETWEEN @FROM_DATE AND @TO_DATE
                            ) AS PX
                            INNER JOIN LINK2.QLVT_DATHANG.DBO.CTPX AS CTPX ON PX.MAPX = CTPX.MAPX
                            GROUP BY FORMAT(PX.NGAY, 'MM-YYYY'), CTPX.MAVT
                        ) AS TKVT ON VT.MAVT = TKVT.MAVT
                    ORDER BY TKVT.THANG_NAM, VT.TENVT ASC
                END
        END
    -- FOR OTHER ROLES: CHINHANH, USER
    ELSE
        BEGIN
            -- FOR NHAP OPTION
            IF @OPTION = 'NHAP'
                BEGIN
                    SELECT
                        TKVT.THANG_NAM AS THANG_NAM,
                        VT.TENVT AS TEN_VAT_TU,
                        TKVT.TONG_SO_LUONG AS TONG_SO_LUONG,
                        TKVT.TONG_TRI_GIA AS TONG_TRI_GIA
                    FROM 
                        VATTU AS VT
                    INNER JOIN (
                        SELECT
                            FORMAT(PN.NGAY, 'MM-YYYY') AS THANG_NAM,
                                CTPN.MAVT AS MAVT,
                                SUM(CTPN.SOLUONG) AS TONG_SO_LUONG,
                                SUM(CTPN.SOLUONG * CTPN.DONGIA) AS TONG_TRI_GIA
                            FROM (
                                SELECT * FROM PHIEUNHAP
                                WHERE NGAY BETWEEN @FROM_DATE AND @TO_DATE
                            ) AS PN
                            INNER JOIN CTPN AS CTPN ON PN.MAPN = CTPN.MAPN
                            GROUP BY FORMAT(PN.NGAY, 'MM-YYYY'), CTPN.MAVT
                        ) AS TKVT ON VT.MAVT = TKVT.MAVT
                    ORDER BY TKVT.THANG_NAM, VT.TENVT ASC
                END
            -- FOR XUAT OPTION
            ELSE IF @OPTION = 'XUAT'
                BEGIN
                    SELECT
                        TKVT.THANG_NAM AS THANG_NAM,
                        VT.TENVT AS TEN_VAT_TU,
                        TKVT.TONG_SO_LUONG AS TONG_SO_LUONG,
                        TKVT.TONG_TRI_GIA AS TONG_TRI_GIA
                    FROM 
                        VATTU AS VT
                    INNER JOIN (
                        SELECT
                            FORMAT(PX.NGAY, 'MM-YYYY') AS THANG_NAM,
                                CTPX.MAVT AS MAVT,
                                SUM(CTPX.SOLUONG) AS TONG_SO_LUONG,
                                SUM(CTPX.SOLUONG * CTPX.DONGIA) AS TONG_TRI_GIA
                            FROM (
                                SELECT * FROM PHIEUNHAP
                                WHERE NGAY BETWEEN @FROM_DATE AND @TO_DATE
                            ) AS PX
                            INNER JOIN CTPX AS CTPX ON PX.MAPX = CTPX.MAPX
                            GROUP BY FORMAT(PX.NGAY, 'MM-YYYY'), CTPX.MAVT
                        ) AS TKVT ON VT.MAVT = TKVT.MAVT
                    ORDER BY TKVT.THANG_NAM, VT.TENVT ASC
                END
        END
END