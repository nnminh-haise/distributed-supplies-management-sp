ATE PROC SP_CREATE_LOGIN
	@LOGIN_NAME VARCHAR(50),
    @PASS VARCHAR(50),
    @USERNAME VARCHAR(50),
    @ROLE VARCHAR(50)
AS
BEGIN
	DECLARE @RET INT
	EXEC @RET = SP_ADDLOGIN @LOGIN_NAME, @PASS, 'QLVT_DATHANG'
	IF (@RET = 1)
	BEGIN
		RAISERROR ('Duplicated login name', 16,1)
		RETURN
	END

	EXEC @RET = SP_GRANTDBACCESS @LOGIN_NAME, @USERNAME
	IF (@RET = 1)
	BEGIN
		EXEC SP_DROPLOGIN @LOGIN_NAME
		RAISERROR ('Duplicated username', 16,2)
		RETURN
	END

	EXEC sp_addrolemember @ROLE, @USERNAME
	IF @ROLE = 'ADMIN'
	BEGIN
		EXEC sp_addsrvrolemember @LOGIN_NAME, 'SecurityAdmin'
		EXEC sp_addsrvrolemember @LOGIN_NAME, 'DBCREATOR'
		EXEC sp_addsrvrolemember @LOGIN_NAME, 'ProcessAdmin'
	END
END