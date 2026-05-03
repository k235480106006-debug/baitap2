# Phần 1: Khởi tạo bảng

<img width="2559" height="1599" alt="Screenshot 2026-05-03 195655" src="https://github.com/user-attachments/assets/ad7a4f2d-8b85-48c8-a4fb-bf0f5fd2f10e" />

```sql

USE [QuanLyLinhKien_K235480106006];
GO
-- 2. Tạo bảng [DanhMuc]
-- Chứa thông tin nhóm sản phẩm
CREATE TABLE [DanhMuc] (
    [MaDanhMuc] INT PRIMARY KEY, -- PK: Mã danh mục
    [TenDanhMuc] NVARCHAR(50) NOT NULL
);

-- 3. Tạo bảng [SanPham]
-- Chứa thông tin chi tiết từng linh kiện
CREATE TABLE [SanPham] (
    [MaSanPham] INT PRIMARY KEY, -- PK: Mã sản phẩm
    [TenSanPham] NVARCHAR(100) NOT NULL,
    [DonGia] MONEY CHECK ([DonGia] > 0), -- CK: Giá phải lớn hơn 0
    [SoLuongTon] INT DEFAULT 0,
    [MaDanhMuc] INT, -- FK: Liên kết với bảng DanhMuc
    CONSTRAINT [FK_SanPham_DanhMuc] FOREIGN KEY ([MaDanhMuc]) REFERENCES [DanhMuc]([MaDanhMuc])
);

-- 4. Tạo bảng [ChiTietHoaDon]
-- Chứa dữ liệu bán hàng, liên kết với bảng SanPham
CREATE TABLE [ChiTietHoaDon] (
    [MaHoaDon] INT PRIMARY KEY, -- PK: Mã hóa đơn
    [MaSanPham] INT, -- FK: Liên kết với bảng SanPham
    [NgayLap] DATETIME DEFAULT GETDATE(),
    [SoLuongBan] INT CHECK ([SoLuongBan] > 0), -- CK: Số lượng bán phải > 0
    CONSTRAINT [FK_ChiTiet_SanPham] FOREIGN KEY ([MaSanPham]) REFERENCES [SanPham]([MaSanPham])
);

```
PK (Primary Key - Khóa chính):

[MaDanhMuc], [MaSanPham], [MaHoaDon] là các trường định danh duy nhất cho mỗi bản ghi trong bảng tương ứng.

FK (Foreign Key - Khóa ngoại):

[MaDanhMuc] trong bảng [SanPham] thiết lập quan hệ 1-n: Một danh mục có thể chứa nhiều sản phẩm.

[MaSanPham] trong bảng [ChiTietHoaDon] thiết lập quan hệ 1-n: Một sản phẩm có thể xuất hiện trong nhiều hóa đơn.

CK (Check Constraint - Ràng buộc cứng):

[DonGia] > 0: Đảm bảo giá linh kiện luôn hợp lệ (không âm).

[SoLuongBan] > 0: Đảm bảo số lượng hàng bán ra thực tế.

Kiểu dữ liệu:

MONEY: Dành cho đơn giá tiền tệ.

NVARCHAR: Hỗ trợ lưu trữ tên tiếng Việt có dấu (Unicode).

DATETIME: Lưu trữ thời gian lập hóa đơn chính xác.
<img width="2559" height="1599" alt="image" src="https://github.com/user-attachments/assets/5f48ed10-51ef-4a5e-834f-403fb030bca4" />

# Phần 2: Xây dựng Function (Kiến thức 8, 9)

a. Các loại Built-in Function trong SQL Server

Trong SQL Server, các built-in functions (hàm có sẵn) là các công cụ cực kỳ mạnh mẽ giúp bạn xử lý dữ liệu mà không cần phải viết logic phức tạp từ đầu. Các hàm này được chia thành nhiều nhóm chính dựa trên mục đích sử dụng như:

Aggregate Functions (Hàm tập hợp): Dùng để tính toán trên một tập giá trị (SUM, AVG, COUNT, MAX, MIN).

String Functions (Hàm chuỗi): Xử lý văn bản (LEN, SUBSTRING, UPPER, LOWER, REPLACE).

Date and Time Functions: Xử lý thời gian (GETDATE, DATEADD, DATEDIFF, YEAR).

Mathematical Functions: Tính toán số học (ABS, ROUND, CEILING, FLOOR).

Conversion Functions: Chuyển đổi kiểu dữ liệu (CAST, CONVERT).

b. Mục đích của việc tự viết hàm (UDF)
Hàm tự viết đóng vai trò là các "công thức" riêng biệt, giúp bạn:

Đóng gói logic nghiệp vụ phức tạp: Thay vì phải viết lại các công thức tính toán (ví dụ: công thức tính chiết khấu VIP, tính thuế đặc thù) ở nhiều nơi, bạn gói gọn chúng vào một hàm duy nhất.

Tái sử dụng (Reusability): Một khi đã định nghĩa xong, bạn có thể gọi hàm đó trong nhiều Stored Procedure, View, hoặc câu lệnh SELECT khác nhau.

Dễ bảo trì: Khi công thức kinh doanh thay đổi, bạn chỉ cần sửa nội dung tại một nơi (trong hàm), toàn bộ hệ thống sẽ tự động cập nhật theo.

Đơn giản hóa câu lệnh: Giúp các truy vấn trở nên trong sáng và dễ đọc hơn, tránh việc lồng ghép các biểu thức logic quá dài.

c. Các loại hàm (UDF)

Scalar Function: Hàm trả về duy nhất một giá trị đơn lẻ (ví dụ: một con số, một chuỗi ký tự, một giá trị thời gian). Loại này thường được dùng trong các biểu thức tính toán hoặc điều kiện lọc.

Inline Table-Valued Function (Inline TVF): Hàm trả về một tập dữ liệu dưới dạng bảng, được tạo ra từ duy nhất một câu lệnh truy vấn nội bộ. Đây là dạng hàm có hiệu năng cao vì SQL Server coi nó như một view có tham số.

Multi-statement Table-Valued Function (Multi-statement TVF): Hàm trả về một tập dữ liệu dạng bảng, nhưng logic bên trong phức tạp, bao gồm nhiều bước xử lý, khai báo biến tạm, các câu lệnh điều kiện hoặc vòng lặp trước khi đổ dữ liệu vào bảng kết quả.

d. Viết 01 Scalar Function (Hàm trả về một giá trị): Đưa ra 1 logic cho cơ sở dữ liệu của em, mà cần dùng đến function này. (SV TỰ NGHĨ RA YÊU CẦU CỦA HÀM VÀ VIẾT HÀM GIẢI QUYẾT NÓ)
```sql
-- Kiểm tra và xóa hàm cũ nếu tồn tại
IF OBJECT_ID('dbo.fn_TinhPhiBaoTri', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_TinhPhiBaoTri;
GO

-- Tạo Scalar Function
CREATE FUNCTION dbo.fn_TinhPhiBaoTri
(
    @GiaTriThietBi MONEY
)
RETURNS MONEY
AS
BEGIN
    DECLARE @PhiBaoTri MONEY;

    -- Logic: Nếu > 10 triệu thì 5%, ngược lại 2%
    IF @GiaTriThietBi > 10000000
        SET @PhiBaoTri = @GiaTriThietBi * 0.05;
    ELSE
        SET @PhiBaoTri = @GiaTriThietBi * 0.02;

    RETURN @PhiBaoTri;
END;
GO
```
```sql
-- Bước 1: Test với thiết bị giá trị 15 triệu (Kết quả phải là 750,000)
SELECT dbo.fn_TinhPhiBaoTri(15000000) AS PhiBaoTri_15T;

-- Bước 2: Test với thiết bị giá trị 5 triệu (Kết quả phải là 100,000)
SELECT dbo.fn_TinhPhiBaoTri(5000000) AS PhiBaoTri_5T;
```

<img width="2559" height="1599" alt="image" src="https://github.com/user-attachments/assets/b97be980-1e4f-455d-8af1-4133c7169ffc" />
e. Viết 01 Inline Table-Valued Function: Trả về danh sách các bản ghi theo một điều kiện lọc cụ thể (SV TỰ NGHĨ RA YÊU CẦU CỦA HÀM VÀ VIẾT HÀM GIẢI QUYẾT NÓ)
Sau khi đã có hàm, viết câu lệnh sql khai thác hàm đó.
```sql
-- Kiểm tra và xóa hàm cũ nếu đã tồn tại
IF OBJECT_ID('dbo.fn_TimKiemLinhKienTheoGia', 'IF') IS NOT NULL
    DROP FUNCTION dbo.fn_TimKiemLinhKienTheoGia;
GO

-- Tạo Inline Table-Valued Function
CREATE FUNCTION dbo.fn_TimKiemLinhKienTheoGia
(
    @GiaMin MONEY,
    @GiaMax MONEY
)
RETURNS TABLE
AS
RETURN
(
    -- Giả lập tập dữ liệu trả về (Thay vì truy vấn bảng)
    SELECT N'CPU Core i5' AS TenSanPham, 4500000 AS DonGia
    UNION ALL
    SELECT N'RAM 8GB DDR4', 800000
    UNION ALL
    SELECT N'VGA RTX 3060', 8500000
    UNION ALL
    SELECT N'Ổ cứng SSD 500GB', 1200000
    -- Lọc dữ liệu dựa trên tham số đầu vào
    WHERE DonGia >= @GiaMin AND DonGia <= @GiaMax
);
GO
```
<img width="2559" height="1599" alt="image" src="https://github.com/user-attachments/assets/fddda1ba-a618-4c9e-9f83-7a0deaf815a5" />
<img width="2559" height="1599" alt="image" src="https://github.com/user-attachments/assets/548f671b-4147-419e-9481-4ae87ebc362d" />

f. Viết 01 Multi-statement Table-Valued Function: Thực hiện xử lý logic phức tạp bên trong (có sử dụng biến bảng) trước khi trả về kết quả. (SV TỰ NGHĨ RA YÊU CẦU CỦA HÀM VÀ VIẾT HÀM GIẢI QUYẾT NÓ)Sau khi đã có hàm, viết câu lệnh sql khai thác hàm đó.
```sql
-- Kiểm tra và xóa hàm cũ nếu tồn tại
IF OBJECT_ID('dbo.fn_PhanLoaiKhachHang', 'TF') IS NOT NULL
    DROP FUNCTION dbo.fn_PhanLoaiKhachHang;
GO

-- Tạo Multi-statement TVF
CREATE FUNCTION dbo.fn_PhanLoaiKhachHang()
RETURNS @BangKetQua TABLE 
(
    TenKhachHang NVARCHAR(100),
    DoanhSo MONEY,
    LoaiKhachHang NVARCHAR(50)
)
AS
BEGIN
    -- 1. Khai báo biến bảng tạm để chứa dữ liệu giả lập
    DECLARE @TempData TABLE (Ten NVARCHAR(100), DoanhSo MONEY);
    
    INSERT INTO @TempData VALUES (N'Nguyễn Văn A', 15000000);
    INSERT INTO @TempData VALUES (N'Trần Thị B', 5000000);
    INSERT INTO @TempData VALUES (N'Lê Văn C', 25000000);

    -- 2. Xử lý logic phức tạp (Duyệt và phân loại)
    INSERT INTO @BangKetQua
    SELECT 
        Ten, 
        DoanhSo,
        CASE 
            WHEN DoanhSo >= 20000000 THEN N'Khách hàng VIP'
            WHEN DoanhSo >= 10000000 THEN N'Khách hàng Thân thiết'
            ELSE N'Khách hàng Tiềm năng'
        END
    FROM @TempData;

    RETURN;
END;
GO
```
<img width="2559" height="1599" alt="image" src="https://github.com/user-attachments/assets/c064b258-ffb3-467f-8687-64b0ffab10fb" />

<img width="2559" height="1599" alt="image" src="https://github.com/user-attachments/assets/e95f5310-12f4-4683-a542-562cabd35094" />

# Phần 3: Xây dựng Store Procedure (Kiến thức 10)

### 1. Trong SQL Server có những SP có sẵn nào? nêu 1 vài system sp mà em tìm hiểu được, giải thích cách dùng chúng.

1. sp_help
Đây là lệnh "vạn năng" để xem thông tin tổng quan về một đối tượng trong database (bảng, view, function, v.v.).

Cách dùng: sp_help [TênĐốiTượng]

Mục đích: Khi bạn muốn kiểm tra xem một bảng có những cột nào, kiểu dữ liệu gì, hoặc các ràng buộc (PK, FK) đã được thiết lập đúng chưa mà không muốn mở giao diện đồ họa.

Ví dụ: EXEC sp_help 'SanPham';

2. sp_helpdb
Dùng để kiểm tra thông tin chi tiết về cơ sở dữ liệu.

Cách dùng: sp_helpdb [TênDatabase]

Mục đích: Giúp bạn biết dung lượng database, ngày tạo, trạng thái (status), hoặc đường dẫn lưu trữ file (.mdf, .ldf). Nếu không truyền tên database, nó sẽ liệt kê tất cả các database có trong hệ thống.

Ví dụ: EXEC sp_helpdb 'QuanLyLinhKien_K235480106006';

3. sp_spaceused
Thủ tục này cực kỳ quan trọng để quản lý dung lượng.

Cách dùng: sp_spaceused hoặc sp_spaceused [TênĐốiTượng]

Mục đích: Cho biết không gian lưu trữ hiện tại mà database hoặc một bảng cụ thể đang chiếm dụng (số lượng bản ghi, dung lượng dữ liệu, dung lượng index).

Ví dụ: EXEC sp_spaceused 'SanPham';

### 2. Viết 01 Store Procedure đơn giản để thực hiện lệnh INSERT hoặc UPDATE dữ liệu, có kiểm tra điều kiện logic (SV TỰ NGHĨ RA YÊU CẦU CỦA SP VÀ VIẾT SP GIẢI QUYẾT NÓ)

```sql
-- Kiểm tra và xóa SP cũ nếu tồn tại
IF OBJECT_ID('dbo.usp_CapNhatGiaSanPham', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_CapNhatGiaSanPham;
GO

-- Tạo Stored Procedure
CREATE PROCEDURE dbo.usp_CapNhatGiaSanPham
    @MaSanPham INT,
    @GiaMoi MONEY
AS
BEGIN
    -- 1. Kiểm tra điều kiện logic cứng
    IF @GiaMoi <= 0
    BEGIN
        PRINT N'Lỗi: Giá sản phẩm phải lớn hơn 0. Vui lòng nhập lại!';
        RETURN; -- Thoát khỏi SP
    END

    -- 2. Giả lập logic UPDATE
    PRINT N'Thành công: Đã cập nhật sản phẩm mã ' + CAST(@MaSanPham AS NVARCHAR(10)) + 
          N' với giá mới là ' + CAST(@GiaMoi AS NVARCHAR(20));
          
    -- (Trong thực tế, ở đây bạn sẽ viết lệnh: UPDATE SanPham SET DonGia = @GiaMoi WHERE MaSanPham = @MaSanPham)
END;
GO
```
1. PK (Primary Key - Khóa chính)
Định nghĩa: Là một trường (hoặc nhóm trường) dùng để định danh duy nhất cho mỗi bản ghi trong một bảng.

Đặc điểm:

Giá trị phải là duy nhất (không được phép có hai bản ghi cùng khóa chính).

Không bao giờ được phép mang giá trị NULL.

Mỗi bảng chỉ có duy nhất một khóa chính.

Ví dụ: Trong bảng [SinhVien], [MaSV] chính là PK vì mỗi sinh viên chỉ có một mã số duy nhất, không trùng lặp với ai.

2. FK (Foreign Key - Khóa ngoại)
Định nghĩa: Là một trường trong bảng này dùng để tham chiếu đến khóa chính (PK) của một bảng khác.

Đặc điểm:

Dùng để tạo liên kết giữa hai bảng.

Giá trị của FK phải tồn tại trong bảng mà nó tham chiếu tới (hoặc có thể là NULL).

Giúp đảm bảo tính toàn vẹn dữ liệu giữa các bảng.

Ví dụ: Trong bảng [DonHang], trường [MaKhachHang] là FK tham chiếu tới khóa chính [MaKhachHang] ở bảng [KhachHang]. Điều này đảm bảo rằng bạn không thể tạo một đơn hàng cho một khách hàng không tồn tại trong hệ thống.

3. CK (Check Constraint - Ràng buộc kiểm tra)
Định nghĩa: Là một điều kiện logic được áp dụng trên một hoặc nhiều cột để giới hạn phạm vi giá trị hợp lệ mà người dùng có thể nhập vào.

Đặc điểm:

Dùng để kiểm tra dữ liệu trước khi cho phép ghi vào bảng.

Nếu dữ liệu nhập vào vi phạm điều kiện của CK, SQL Server sẽ từ chối lệnh INSERT hoặc UPDATE đó.

Ví dụ:

CHECK ([Tuoi] >= 18): Đảm bảo người dùng phải đủ 18 tuổi mới được đăng ký.

CHECK ([DonGia] > 0): Đảm bảo giá tiền không bao giờ là con số âm.

<img width="2559" height="1599" alt="image" src="https://github.com/user-attachments/assets/00a8004d-7353-4f17-98a6-5ab194fdf791" />

<img width="2559" height="1599" alt="image" src="https://github.com/user-attachments/assets/ff7deac8-7732-4035-bdcf-ae4f1e34096a" />

### 3. Viết 01 Store Procedure có sử dụng tham số OUTPUT để trả về một giá trị tính toán (SV TỰ NGHĨ RA YÊU CẦU CỦA SP VÀ VIẾT SP GIẢI QUYẾT NÓ, SP NÀY CÓ DÙNG THAM SỐ LOẠI OUTPUT)

```sql
-- 1. Chuyển sang master để xóa database cũ nếu cần
USE master;
GO

-- Xóa database nếu đã tồn tại (Cẩn thận: lệnh này sẽ xóa sạch dữ liệu cũ)
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'QuanLyLinhKien_K235480106006')
    DROP DATABASE [QuanLyLinhKien_K235480106006];
GO

-- Tạo lại Database
CREATE DATABASE [QuanLyLinhKien_K235480106006];
GO
USE [QuanLyLinhKien_K235480106006];
GO

-- 2. Kiểm tra và xóa bảng cũ trước khi tạo lại
IF OBJECT_ID('SanPham', 'U') IS NOT NULL DROP TABLE SanPham;
IF OBJECT_ID('DanhMuc', 'U') IS NOT NULL DROP TABLE DanhMuc;
GO

-- Tạo bảng DanhMuc
CREATE TABLE [DanhMuc] (
    [MaDanhMuc] INT PRIMARY KEY,
    [TenDanhMuc] NVARCHAR(50) NOT NULL
);

-- Tạo bảng SanPham
CREATE TABLE [SanPham] (
    [MaSanPham] INT PRIMARY KEY,
    [TenSanPham] NVARCHAR(100) NOT NULL,
    [DonGia] MONEY CHECK ([DonGia] > 0),
    [SoLuongTon] INT DEFAULT 0,
    [MaDanhMuc] INT,
    CONSTRAINT [FK_SanPham_DanhMuc] FOREIGN KEY ([MaDanhMuc]) REFERENCES [DanhMuc]([MaDanhMuc])
);
GO
```
<img width="2556" height="1595" alt="image" src="https://github.com/user-attachments/assets/8ce81a56-376c-4b19-8773-2d856f83ea06" />

<img width="2559" height="1599" alt="image" src="https://github.com/user-attachments/assets/b9fa66c3-fd1d-4f67-bd80-2d047d53f4b5" />

### 4.Viết 01 Store Procedure trả về một tập kết quả (Result set) từ lệnh SELECT sau khi đã join nhiều bảng. (SV TỰ NGHĨ RA YÊU CẦU CỦA SP VÀ VIẾT SP GIẢI QUYẾT NÓ)

```sql
-- Kiểm tra và xóa SP cũ nếu đã tồn tại
IF OBJECT_ID('dbo.usp_LayDanhSachSanPhamChiTiet', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_LayDanhSachSanPhamChiTiet;
GO

-- Tạo Stored Procedure
CREATE PROCEDURE dbo.usp_LayDanhSachSanPhamChiTiet
    @TenDanhMuc NVARCHAR(50) -- Tham số lọc tùy chọn
AS
BEGIN
    -- Trả về tập kết quả sau khi Join 2 bảng
    SELECT 
        S.MaSanPham, 
        S.TenSanPham, 
        S.DonGia, 
        S.SoLuongTon, 
        D.TenDanhMuc
    FROM [SanPham] AS S
    INNER JOIN [DanhMuc] AS D ON S.MaDanhMuc = D.MaDanhMuc
    WHERE D.TenDanhMuc LIKE '%' + @TenDanhMuc + '%';
END;
GO
```
<img width="2559" height="1599" alt="image" src="https://github.com/user-attachments/assets/43251881-07b7-419a-80d8-b6db072a0562" />
<img width="2559" height="1599" alt="image" src="https://github.com/user-attachments/assets/5c54d4a5-230a-4ea6-ba1c-b7faee6ae5d1" />

# Phần 4: Trigger và Xử lý logic nghiệp vụ (Kiến thức 11)

### 1. Viết 01 Trigger để tự động làm gì đó tại 1 bảng B khi mà dữ liệu thay đổi dữ liệu ở bảng A. Logic giải quyết do sv tự nghĩ ra, sao cho thực tế và thuyết phục.

1. Yêu cầu nghiệp vụ (Logic thực tế)
Bảng A: [ChiTietHoaDon] (lưu thông tin bán hàng).

Bảng B: [SanPham] (lưu thông tin tồn kho).

Logic: Khi một dòng dữ liệu mới được thêm vào [ChiTietHoaDon] (bán hàng thành công), Trigger sẽ tự động trừ đi số lượng đã bán tương ứng khỏi cột [SoLuongTon] trong bảng [SanPham].

2. Thiết lập cấu trúc (Giả định)
Trước tiên, bạn cần đảm bảo bảng [ChiTietHoaDon] tồn tại:
```sql
-- Tạo bảng ChiTietHoaDon
CREATE TABLE [ChiTietHoaDon] (
    [MaHD] INT PRIMARY KEY,
    [MaSanPham] INT,
    [SoLuongBan] INT,
    FOREIGN KEY ([MaSanPham]) REFERENCES [SanPham]([MaSanPham])
);
GO
```
<img width="2559" height="1599" alt="image" src="https://github.com/user-attachments/assets/76ca4c04-5d01-4f8e-ac04-5ce8bc1ab095" />
```sql
-- Kiểm tra và xóa Trigger cũ nếu tồn tại
IF OBJECT_ID('dbo.trg_CapNhatTonKho', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_CapNhatTonKho;
GO

CREATE TRIGGER dbo.trg_CapNhatTonKho
ON [ChiTietHoaDon]
AFTER INSERT
AS
BEGIN
    -- Cập nhật bảng SanPham dựa trên số lượng từ bảng tạm 'inserted'
    UPDATE [SanPham]
    SET [SoLuongTon] = [SoLuongTon] - i.SoLuongBan
    FROM [SanPham] S
    INNER JOIN inserted i ON S.MaSanPham = i.MaSanPham;
END;
GO
```

<img width="2559" height="1599" alt="image" src="https://github.com/user-attachments/assets/e29bdf43-d226-49c9-bec7-4227374a9d8e" />

<img width="2559" height="1599" alt="image" src="https://github.com/user-attachments/assets/34a81c0d-1083-48ab-8e22-7e1c1227fb1d" />

### 2.Thử viết Trigger cho Bảng A : Khi insert thì cập nhật dữ liệu vào bảng B; sau đó viết trigger cho bảng B để khi B được cập nhật thì cập nhật sang bảng A : Quan sát các thông báo (nếu có) của hệ thống, giải thích các thông báo đó (nếu có). Đưa ra nhật xét cuối cùng về tình trạng này.

1. Thiết lập bảng và Trigger

Giả sử chúng ta có bảng SanPham (Bảng A) và bảng NhatKyGia (Bảng B).
```sql
-- Tạo bảng A và B
CREATE TABLE A (ID INT PRIMARY KEY, Val INT);
CREATE TABLE B (ID INT PRIMARY KEY, Val INT);
GO

-- Trigger 1: Insert vào A -> Update vào B
CREATE TRIGGER trg_A_to_B ON A AFTER INSERT
AS
BEGIN
    UPDATE B SET Val = (SELECT Val FROM inserted) WHERE ID = (SELECT ID FROM inserted);
END;
GO

-- Trigger 2: Update vào B -> Update vào A
CREATE TRIGGER trg_B_to_A ON B AFTER UPDATE
AS
BEGIN
    UPDATE A SET Val = (SELECT Val FROM inserted) WHERE ID = (SELECT ID FROM inserted);
END;
GO
```

<img width="2559" height="1599" alt="image" src="https://github.com/user-attachments/assets/a72ca7fb-2f94-4ad2-9467-52c1f078df00" />

2. Thực thi lệnh gây lỗi
```sql
INSERT INTO A VALUES (1, 100);
```
<img width="2544" height="1599" alt="image" src="https://github.com/user-attachments/assets/6f286f7c-502d-468d-9c63-28ccde9b67c8" />

# Phần 5: Cursor và Duyệt dữ liệu (Kiến thức 11)

1. Viết một đoạn script sử dụng CURSOR để duyệt qua danh sách của 1 câu lệnh SQL dạng SELECT, duyệt qua từng bản ghi, xử lý riêng từng bản ghi (THEO LOGIC SV TỰ ĐẶT RA: SAO CHO HỢP LÝ VÀ THUYẾT PHỤC)

```sql
-- Khai báo các biến để lưu dữ liệu của từng bản ghi
DECLARE @MaSP INT;
DECLARE @DonGia MONEY;
DECLARE @GiaMoi MONEY;

-- Khai báo CURSOR để lấy danh sách sản phẩm
DECLARE cur_SanPham CURSOR FOR 
SELECT MaSanPham, DonGia FROM [SanPham];

-- Mở CURSOR
OPEN cur_SanPham;

-- Lấy dòng đầu tiên
FETCH NEXT FROM cur_SanPham INTO @MaSP, @DonGia;

-- Duyệt qua từng bản ghi cho đến khi hết
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Logic nghiệp vụ phức tạp
    IF (@DonGia % 1000 <> 0)
    BEGIN
        -- Nếu lẻ, làm tròn lên hàng nghìn
        SET @GiaMoi = CEILING(@DonGia / 1000) * 1000;
    END
    ELSE
    BEGIN
        -- Nếu chẵn, giảm 2%
        SET @GiaMoi = @DonGia * 0.98;
    END

    -- Cập nhật giá mới cho sản phẩm hiện tại
    UPDATE [SanPham] SET DonGia = @GiaMoi WHERE MaSanPham = @MaSP;

    -- Lấy dòng tiếp theo
    FETCH NEXT FROM cur_SanPham INTO @MaSP, @DonGia;
END;

-- Đóng và giải phóng CURSOR
CLOSE cur_SanPham;
DEALLOCATE cur_SanPham;
GO
```
<img width="2559" height="1599" alt="image" src="https://github.com/user-attachments/assets/7c75a1a3-0019-4791-b781-198c8ae1dbc9" />

<img width="2559" height="1599" alt="image" src="https://github.com/user-attachments/assets/6bb02e57-49ba-43de-9fa4-98b5300de568" />

2. Tìm cách không sử dụng CURSOR để giải quyết bài toán mà em đã dùng CURSOR mới giải quyết được ở trên. thử so sánh tốc độ giữa có dùng cursor và không dùng cursor (nếu cùng kết quả) thì thời gian xử lý cái nào nhanh hơn, cần ảnh chụp màn hình minh chứng.

Giải pháp Set-based (Không dùng CURSOR)

Thay vì dùng vòng lặp, ta sử dụng câu lệnh UPDATE kết hợp với biểu thức CASE để áp dụng logic cho tất cả dòng cùng lúc:
```sql
UPDATE [SanPham]
SET DonGia = CASE 
    -- Nếu lẻ, làm tròn lên hàng nghìn
    WHEN (DonGia % 1000 <> 0) THEN CEILING(DonGia / 1000.0) * 1000
    -- Nếu chẵn, giảm 2%
    ELSE DonGia * 0.98
END;
```

<img width="2559" height="1599" alt="image" src="https://github.com/user-attachments/assets/6d61934c-312e-4127-a64d-d18b8b3ae4f7" />

<img width="2559" height="1599" alt="image" src="https://github.com/user-attachments/assets/7857b1d0-4242-4669-8af1-24b50490bcab" />

### So sánh hiệu năng: CURSOR vs. Set-based Approach

| Đặc điểm | Cách dùng CURSOR | Cách dùng Set-based (UPDATE) |
| :--- | :--- | :--- |
| **Cách hoạt động** | Duyệt từng dòng một (Row-by-row). | Xử lý toàn bộ tập dữ liệu (Set-based). |
| **Tốc độ** | Chậm (do overhead của vòng lặp). | **Rất nhanh** (được tối ưu bởi SQL Engine). |
| **Tài nguyên** | Chiếm dụng nhiều CPU/Memory. | Tiết kiệm tài nguyên, thực thi trực tiếp. |
| **Độ phức tạp** | Cao (cần khai báo, mở, đóng, giải phóng). | Thấp (chỉ cần một câu lệnh truy vấn). |
| **Khuyên dùng** | Chỉ dùng khi logic quá phức tạp. | **Nên dùng mặc định** trong mọi trường hợp. |

3. Nếu vẫn tìm được cách dùng SQL để giải quyết vấn đề mà ko cần CURSOR: thử nghĩ bài toán khác, mà chỉ CURSOR mới giải quyết được, còn SQL rất khó giải quyết đc (theo logic suy nghĩ của em)

Bài toán: "Tính toán số dư lũy kế có điều kiện dừng dựa trên hạn mức"
Giả sử chúng ta có bảng GiaoDich (ID, SoTien). Chúng ta muốn duyệt qua các giao dịch theo thứ tự thời gian và tính số dư tích lũy. Điều kiện đặc biệt: Nếu tại bất kỳ thời điểm nào, số dư tích lũy vượt quá 100.000.000đ, chúng ta phải dừng ngay lập tức và ghi lại ID của giao dịch đã làm "vỡ" hạn mức đó vào một bảng log.

Tại sao SQL thuần rất khó thực hiện?
SQL thuần (như SUM() OVER(...)) tính toán trên toàn bộ tập dữ liệu, nó không có khái niệm "dừng" giữa chừng dựa trên giá trị tích lũy.

Chúng ta không thể dùng BREAK hoặc RETURN ngay giữa một câu lệnh SELECT hay UPDATE.
```sql
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
```
<img width="2559" height="1599" alt="image" src="https://github.com/user-attachments/assets/3cc5f437-04af-4ee6-9fd1-5b946ac497dc" />

Mặc dù nguyên tắc vàng trong SQL là 'Set-based over Row-based', nhưng CURSOR vẫn là công cụ không thể thay thế trong các bài toán lập trình sự kiện (Event-driven) hoặc logic kiểm soát trạng thái (State-control logic). Khi bài toán yêu cầu phải đưa ra quyết định 'dừng lại' hoặc 'rẽ nhánh' dựa trên kết quả tích lũy của các dòng trước đó, CURSOR cung cấp sự linh hoạt mà các câu lệnh SQL thuần không thể đáp ứng được.

Bài toán này cực kỳ thuyết phục vì nó cho thấy chúng ta hiểu sâu về cả hai tư duy: Tối ưu tập hợp (SQL thuần) và Kiểm soát logic (CURSOR)
