CREATE PROC SP_LOGIN
	@LOGIN_NAME NVARCHAR(100)
AS
	DECLARE @USER_ID INT
	DECLARE @MANV NVARCHAR(100)
	SELECT
    @USER_ID = uid, 
    @MANV = NAME 
  FROM sys.sysusers 
  WHERE 
    sid = SUSER_SID(@LOGIN_NAME)

	SELECT 
    MANV = @MANV, 
    HO_TEN = (SELECT HO + ' ' + TEN FROM NHANVIEN WHERE MANV = @MANV ), 
    TEN_NHOM = NAME
  FROM
    sys.sysusers
  WHERE
    uid = (SELECT groupuid FROM sys.sysmembers WHERE memberuid = @USER_ID)


-- Notes:
-- NAME includes username and role name
-- sys.sysmembers includes groupUid and memberUid