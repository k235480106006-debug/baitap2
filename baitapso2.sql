DECLARE @ID INT, @SoTien MONEY, @TongTichLuy MONEY = 0;

DECLARE cur_GiaoDich CURSOR FOR 
SELECT ID, SoTien FROM GiaoDich ORDER BY ThoiGian;

OPEN cur_GiaoDich;
FETCH NEXT FROM cur_GiaoDich INTO @ID, @SoTien;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @TongTichLuy = @TongTichLuy + @SoTien;

    -- Logic dừng xử lý ngay lập tức khi đạt ngưỡng
    IF @TongTichLuy > 100000000
    BEGIN
        INSERT INTO LogVuotHanMuc (IDGiaoDich, ThoiGianVuot) VALUES (@ID, GETDATE());
        PRINT 'Đã chạm ngưỡng! Dừng duyệt tại ID: ' + CAST(@ID AS VARCHAR);
        BREAK; -- Chỉ CURSOR mới làm được việc này một cách tường minh
    END

    FETCH NEXT FROM cur_GiaoDich INTO @ID, @SoTien;
END;

CLOSE cur_GiaoDich;
DEALLOCATE cur_GiaoDich;