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

