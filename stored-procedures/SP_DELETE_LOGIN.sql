CREATE PROC SP_DELETE_LOGIN
    @MANV INT,
    @LOGIN_NAME NVARCHAR(50)
AS
BEGIN
    DECLARE @ERR_MESSAGE NVARCHAR(256)
    DECLARE @SQL NVARCHAR(4000)

    BEGIN TRY
        -- Check if the employee exists
        IF NOT EXISTS (SELECT 1 FROM NHANVIEN WHERE MANV = @MANV) BEGIN
            SET @ERR_MESSAGE = 'INVALID EMPLOYEE ID';
            THROW 51000, @ERR_MESSAGE, 1;
        END

        -- Check if the login exists
        IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = @LOGIN_NAME) BEGIN
            SET @ERR_MESSAGE = 'INVALID LOGIN NAME';
            THROW 51000, @ERR_MESSAGE, 1;
        END

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
    END TRY
    BEGIN CATCH
        -- Retrieve the error message if not already set
        IF @ERR_MESSAGE IS NULL
            SET @ERR_MESSAGE = ERROR_MESSAGE();

        -- Throw the error
        THROW 51000, @ERR_MESSAGE, 1;
    END CATCH
END
