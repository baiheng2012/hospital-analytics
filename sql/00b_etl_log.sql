USE HospitalDW;
GO

-- 日志表:只创建一次,不要 DROP,否则历史记录会丢
IF OBJECT_ID('etl.run_log') IS NULL
CREATE TABLE etl.run_log (
    log_id       INT IDENTITY(1,1) PRIMARY KEY,
    run_id       UNIQUEIDENTIFIER NOT NULL,          -- 一次完整运行共用一个 ID
    step_name    NVARCHAR(100)    NOT NULL,          -- 脚本文件名
    status       NVARCHAR(20)     NOT NULL,          -- STARTED / SUCCESS / FAILED
    started_at   DATETIME2        NOT NULL DEFAULT SYSDATETIME(),
    finished_at  DATETIME2        NULL,
    duration_sec AS DATEDIFF(SECOND, started_at, finished_at),  -- 计算列
    message      NVARCHAR(2000)   NULL
);
GO

-- 写日志的小过程:开始时插入一行,结束时更新同一行
CREATE OR ALTER PROCEDURE etl.usp_log_step
    @run_id    UNIQUEIDENTIFIER,
    @step_name NVARCHAR(100),
    @status    NVARCHAR(20),
    @message   NVARCHAR(2000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @status = 'STARTED'
        INSERT INTO etl.run_log (run_id, step_name, status)
        VALUES (@run_id, @step_name, 'STARTED');
    ELSE
        UPDATE etl.run_log
        SET status = @status, finished_at = SYSDATETIME(), message = @message
        WHERE run_id = @run_id AND step_name = @step_name AND status = 'STARTED';
END;
GO