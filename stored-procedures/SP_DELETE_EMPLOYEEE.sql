CREATE PROCEDURE SP_DELETE_EMPLOYEE
	@MANV INT
AS
BEGIN
	If NOT EXISTS(SELECT 1 FROM NhanVien WHERE MANV = @MANV AND TrangThaiXoa = 0)
	BEGIN
		THROW 51000, 'Employee info is invalid', 1;
	END
	
	DECLARE @LOGIN_NAME NVARCHAR(256);
	SELECT
		@LOGIN_NAME = SV_PRINC.NAME
	FROM
		SYS.DATABASE_PRINCIPALS AS DB_PRINC
	INNER JOIN
		SYS.SERVER_PRINCIPALS AS SV_PRINC ON DB_PRINC.SID = SV_PRINC.SID
	WHERE
		DB_PRINC.NAME = CAST(@MANV AS NVARCHAR(256));

	DECLARE @ADD_ROLE_SQL NVARCHAR(256);
	SET @ADD_ROLE_SQL = N'ALTER ROLE [DB_OWNER] ADD MEMBER [' + CAST(@MANV AS NVARCHAR(5)) +']';
	EXEC SP_EXECUTESQL @ADD_ROLE_SQL;

	DECLARE @ERR_MESSAGE NVARCHAR(256);
    DECLARE @SQL NVARCHAR(4000);

	BEGIN TRY
        -- Terminate all sessions for the login
        DECLARE @spid INT
        DECLARE @login NVARCHAR(50) = @LOGIN_NAME

        DECLARE session_cursor CURSOR FOR
        SELECT session_id
        FROM sys.dm_exec_sessions
        WHERE login_name = @login

        OPEN session_cursor

        FETCH NEXT FROM session_cursor INTO @spid
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @SQL = N'KILL ' + CAST(@spid AS NVARCHAR(10))
            EXEC sp_executesql @SQL
            FETCH NEXT FROM session_cursor INTO @spid
        END

        CLOSE session_cursor
        DEALLOCATE session_cursor

        -- Construct and execute the dynamic SQL to drop the user
        SET @SQL = N'DROP USER [' + CAST(@MANV AS NVARCHAR(50)) + N']'
        EXEC sp_executesql @SQL

        -- Construct and execute the dynamic SQL to drop the login
        SET @SQL = N'DROP LOGIN [' + @LOGIN_NAME + N']'
        EXEC sp_executesql @SQL

		UPDATE NhanVien SET TrangThaiXoa = 1 WHERE MANV = @MANV;
    END TRY
    BEGIN CATCH
        -- Retrieve the error message if not already set
        IF @ERR_MESSAGE IS NULL
            SET @ERR_MESSAGE = ERROR_MESSAGE();

        -- Throw the error
        THROW 51000, @ERR_MESSAGE, 1;
    END CATCH
END