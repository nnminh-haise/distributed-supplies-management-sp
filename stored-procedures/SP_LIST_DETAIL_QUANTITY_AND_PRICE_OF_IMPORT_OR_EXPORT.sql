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
                        FORMAT(TKVT.NGAY, 'MM-YYYY') AS THANG_NAM,
                        VT.TENVT AS TEN_VAT_TU,
                        TKVT.TONG_SO_LUONG AS TONG_SO_LUONG,
                        TKVT.TONG_TRI_GIA AS TONG_TRI_GIA
                    FROM
                        LINK2.QLVT_DATHANG.DBO.VATTU AS VT,
                        INNER JOIN (
                            SELECT
                                PN.NGAY AS NGAY,
                                CTPN.MAVT AS MAVT,
                                SUM(CTPN.SOLUONG) AS TONG_SO_LUONG,
                                SUM(CTPN.SOLUONG * CTPN.DONGIA) AS TONG_TRI_GIA
                            FROM LINK2.QLVT_DATHANG.DBO.PHIEUNHAP AS PN
                            INNER JOIN LINK2.QLVT_DATHANG.DBO.CTPN AS CTPN
                                ON PN.MAPN = CTPN.MAPN
                            WHERE PN.NGAY BETWEEN @FROM_DATE AND @TO_DATE
                        ) AS TKVT
                        ON VT.MAVT = TKVT.MAVT
                        GROUP BY FORMAT(TKVT.NGAY, 'MM-YYYY'), VT.TENVT
                        ORDER BY FORMAT(TKVT.NGAY, 'MM-YYYY') DESC, VT.TENVT ASC
                END
            -- FOR XUAT OPTION
            ELSE IF @OPTION = 'XUAT'
                BEGIN
                    SELECT
                        FORMAT(TKVT.NGAY, 'MM-YYYY') AS THANG_NAM,
                        VT.TENVT AS TEN_VAT_TU,
                        TKVT.TONG_SO_LUONG AS TONG_SO_LUONG,
                        TKVT.TONG_TRI_GIA AS TONG_TRI_GIA
                    FROM
                        LINK2.QLVT_DATHANG.DBO.VATTU AS VT,
                        INNER JOIN (
                            SELECT
                                PX.NGAY AS NGAY,
                                CTPX.MAVT AS MAVT,
                                SUM(CTPX.SOLUONG) AS TONG_SO_LUONG,
                                SUM(CTPX.SOLUONG * CTPX.DONGIA) AS TONG_TRI_GIA
                            FROM LINK2.QLVT_DATHANG.DBO.PHIEUXUAT AS PX
                            INNER JOIN LINK2.QLVT_DATHANG.DBO.CTPX AS CTPX
                                ON PX.MAPX = CTPX.MAPX
                            WHERE PX.NGAY BETWEEN @FROM_DATE AND @TO_DATE
                        ) AS TKVT
                        ON VT.MAVT = TKVT.MAVT
                        GROUP BY FORMAT(TKVT.NGAY, 'MM-YYYY'), VT.TENVT
                        ORDER BY FORMAT(TKVT.NGAY, 'MM-YYYY') DESC, VT.TENVT ASC
                END
        END
    -- FOR OTHER ROLES: CHINHANH, USER
    ELSE
        BEGIN
            -- FOR NHAP OPTION
            IF @OPTION = 'NHAP'
                BEGIN
                    SELECT
                        FORMAT(TKVT.NGAY, 'MM-YYYY') AS THANG_NAM,
                        VT.TENVT AS TEN_VAT_TU,
                        TKVT.TONG_SO_LUONG AS TONG_SO_LUONG,
                        TKVT.TONG_TRI_GIA AS TONG_TRI_GIA
                    FROM
                        VATTU AS VT,
                        INNER JOIN (
                            SELECT
                                PN.NGAY AS NGAY,
                                CTPN.MAVT AS MAVT,
                                SUM(CTPN.SOLUONG) AS TONG_SO_LUONG,
                                SUM(CTPN.SOLUONG * CTPN.DONGIA) AS TONG_TRI_GIA
                            FROM PHIEUNHAP AS PN
                            INNER JOIN CTPN AS CTPN
                                ON PN.MAPN = CTPN.MAPN
                            WHERE PN.NGAY BETWEEN @FROM_DATE AND @TO_DATE
                        ) AS TKVT
                        ON VT.MAVT = TKVT.MAVT
                        GROUP BY FORMAT(TKVT.NGAY, 'MM-YYYY'), VT.TENVT
                        ORDER BY FORMAT(TKVT.NGAY, 'MM-YYYY') DESC, VT.TENVT ASC
                END
            -- FOR XUAT OPTION
            ELSE IF @OPTION = 'XUAT'
                BEGIN
                    SELECT
                        FORMAT(TKVT.NGAY, 'MM-YYYY') AS THANG_NAM,
                        VT.TENVT AS TEN_VAT_TU,
                        TKVT.TONG_SO_LUONG AS TONG_SO_LUONG,
                        TKVT.TONG_TRI_GIA AS TONG_TRI_GIA
                    FROM
                        VATTU AS VT,
                        INNER JOIN (
                            SELECT
                                PX.NGAY AS NGAY,
                                CTPX.MAVT AS MAVT,
                                SUM(CTPX.SOLUONG) AS TONG_SO_LUONG,
                                SUM(CTPX.SOLUONG * CTPX.DONGIA) AS TONG_TRI_GIA
                            FROM PHIEUXUAT AS PX
                            INNER JOIN CTPX AS CTPX
                                ON PX.MAPX = CTPX.MAPX
                            WHERE PX.NGAY BETWEEN @FROM_DATE AND @TO_DATE
                        ) AS TKVT
                        ON VT.MAVT = TKVT.MAVT
                        GROUP BY FORMAT(TKVT.NGAY, 'MM-YYYY'), VT.TENVT
                        ORDER BY FORMAT(TKVT.NGAY, 'MM-YYYY') DESC, VT.TENVT ASC
                END
        END
END