CREATE PROCEDURE SP_GET_USER_INFO_BY_LOGIN
	@TEN_LOGIN NVARCHAR( 100)
AS
BEGIN
	DECLARE @UID INT
	DECLARE @MANV NVARCHAR(100)

	SELECT
		@UID = uid,
		@MANV = NAME -- Lấy username
    FROM sys.sysusers 
  	WHERE sid = SUSER_SID(@TEN_LOGIN)

	SELECT
        MANV = @MANV,
        HOTEN = (SELECT HO + ' ' + TEN FROM dbo.NHANVIEN WHERE MANV = @MANV), 
       	TENNHOM = NAME -- Lấy tên nhóm quyền
  	FROM sys.sysusers
    WHERE UID = (SELECT groupuid FROM sys.sysmembers WHERE memberuid = @UID)
END