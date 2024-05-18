use master
drop database if exists qlhs1
create database qlhs1
use qlhs1

create table THAMSO
(
    TuoiToiThieu int,
    TuoiToiDa int,
    SiSoToiDa int,
    DiemDatMon Decimal(4,2),
    DiemDat Decimal(4,2),
    DiemToiThieu Decimal(4,2),
    DiemToiDa Decimal(4,2)
)
INSERT INTO THAMSO VALUES(15, 20, 40, 5.0, 5.0, 0.0, 10.0)

create table MONHOC
(
	MaMonHoc varchar(10) primary key,
	TenMonHoc varchar(50),
	HeSo int
)
INSERT INTO MONHOC VALUES('MH01', N'Toán', 1)
INSERT INTO MONHOC VALUES('MH02', N'Vật Lý', 1)
INSERT INTO MONHOC VALUES('MH03', N'Thể Dục', 0)

create table KHOILOP
(
	MaKhoiLop varchar(10) primary key,
	TenKhoiLop varchar(50)
)
INSERT INTO KHOILOP VALUES('KHOI10', N'Khối 10') 

create table HOCKI
(
	MaHocKi varchar(10) primary key,
	TenHocKi varchar(50)
)
INSERT INTO HOCKI VALUES('HK1', N'Học Kỳ 1')
INSERT INTO HOCKI VALUES('HK2', N'Học Kỳ 2')

create table NAMHOC
(
	MaNamHoc VARCHAR(4) PRIMARY KEY CHECK (MaNamHoc LIKE '[0-9][0-9][0-9][0-9]'),
	TenNamHoc varchar(50)
)
INSERT INTO NAMHOC VALUES('2019', '2019-2020')

create table LOP
(
	MaLop varchar(10) primary key,
	TenLop varchar(50),
	SiSo int,
	MaKhoiLop varchar(10) foreign key references KHOILOP(MaKhoiLop),
	MaNamHoc varchar(4) foreign key references NAMHOC(MaNamHoc)
)
go
CREATE TRIGGER SiSo_Check
ON LOP
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @SiSoToiDa int;
    SELECT @SiSoToiDa = SiSoToiDa FROM THAMSO;
    IF EXISTS (SELECT 1 FROM inserted i WHERE i.SiSo > @SiSoToiDa)
    BEGIN
        RAISERROR ('Violation of the SiSo Check constraint, SiSo should be less than SiSoToiDa', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
go
INSERT INTO LOP VALUES('LOP1012019', '10A1', 32, 'KHOI10', '2019')

	SELECT MaLop, TenLop, SiSo, TenKhoiLop, TenNamHoc
	FROM LOP
	INNER JOIN KHOILOP ON LOP.MaKhoiLop = KHOILOP.MaKhoiLop
	INNER JOIN NAMHOC ON LOP.MaNamHoc = NAMHOC.MaNamHoc;

create table HOCSINH
(
	MaHocSinh varchar(10) primary key,
	MaLop varchar(10) foreign key references LOP(MaLop),
	HoTen varchar(50),
    GioiTinh bit,
	NgaySinh date,
	DiaChi varchar(255),
	Email varchar(100)
)
go
CREATE TRIGGER Tuoi_Check 
ON HOCSINH 
AFTER INSERT, UPDATE 
AS 
BEGIN 
    DECLARE @TuoiToiThieu INT, @TuoiToiDa INT;
    SELECT @TuoiToiThieu = TuoiToiThieu, @TuoiToiDa = TuoiToiDa FROM THAMSO;

    IF EXISTS (
        SELECT 1 
        FROM inserted i
        JOIN LOP l ON i.MaLop = l.MaLop
        JOIN NAMHOC nh ON l.MaNamHoc = nh.MaNamHoc
        WHERE SUBSTRING(nh.TenNamHoc, 6, 4) - YEAR(i.NgaySinh) < @TuoiToiThieu OR SUBSTRING(nh.TenNamHoc, 6, 4) - YEAR(i.NgaySinh) > @TuoiToiDa
    ) 
    BEGIN 
        RAISERROR ('Vi phạm ràng buộc Tuoi, Tuoi phải nằm trong khoảng TuoiToiThieu và TuoiToiDa trong năm học!', 16, 1); 
        ROLLBACK TRANSACTION; 
        RETURN;
    END 
END;
go
INSERT INTO HOCSINH VALUES 
('HS001', 'LOP1012019', 'Nguyễn Văn A1', 0, '2005-01-01', '123 Đường A, Quận 1, Thành phố Hồ Chí Minh', 'nguyenvana1@example.com'),
('HS002', 'LOP1012019', 'Trần Thị B1', 1, '2005-02-01', '456 Đường B, Quận 2, Thành phố Hồ Chí Minh', 'tranthib1@example.com'),
('HS003', 'LOP1012019', 'Phạm Đức C1', 0, '2005-03-01', '789 Đường C, Quận 3, Thành phố Hồ Chí Minh', 'phamducc1@example.com');

SELECT MaHocSinh, HoTen, GioiTinh, NgaySinh, DiaChi, Email
FROM HOCSINH;

SELECT LOP.TenLop, LOP.SiSo, ROW_NUMBER() OVER (PARTITION BY LOP.TenLop ORDER BY HOCSINH.HoTen) AS STT, 
       HOCSINH.HoTen, HOCSINH.GioiTinh, HOCSINH.NgaySinh, HOCSINH.DiaChi
FROM LOP 
INNER JOIN HOCSINH ON LOP.MaLop = HOCSINH.MaLop
ORDER BY LOP.TenLop, STT;

create table BANGDIEMMON
(
	MaBangDiem varchar(10) primary key,
	MaLop varchar(10) foreign key references LOP(MaLop),
	MaHocKi varchar(10) foreign key references HOCKI(MaHocKi),
	MaMonHoc varchar(10) foreign key references MONHOC(MaMonHoc)
)
INSERT INTO BANGDIEMMON VALUES 
('BDM001', 'LOP1012019', 'HK1', 'MH01'),
('BDM002', 'LOP1012019', 'HK1', 'MH02'),
('BDM003', 'LOP1012019', 'HK1', 'MH03'),
('BDM004', 'LOP1012019', 'HK2', 'MH01'),
('BDM005', 'LOP1012019', 'HK2', 'MH02'),
('BDM006', 'LOP1012019', 'HK2', 'MH03');

create table LOAIHINHKIEMTRA
(
	MaLoaiHinhKT varchar(10) primary key,
	TenLoaiHinhKT varchar(50),
	HeSo int
)
INSERT INTO LOAIHINHKIEMTRA VALUES('15m', '15 phut', 1)
INSERT INTO LOAIHINHKIEMTRA VALUES('45m', '1 tiet', 2)
INSERT INTO LOAIHINHKIEMTRA VALUES('90m', 'cuoi ki', 3)

CREATE TABLE CT_DIEMLOAIHINHKT
(
    MaBangDiem VARCHAR(10) FOREIGN KEY REFERENCES BANGDIEMMON(MaBangDiem),
    MaHocSinh VARCHAR(10) FOREIGN KEY REFERENCES HOCSINH(MaHocSinh),
    MaLoaiHinhKT VARCHAR(10) FOREIGN KEY REFERENCES LOAIHINHKIEMTRA(MaLoaiHinhKT),
    Lan INT,
    Diem DECIMAL(4,2),
    PRIMARY KEY (MaBangDiem, MaHocSinh, MaLoaiHinhKT, Lan),
)
GO
CREATE TRIGGER Diem_Check
ON CT_DIEMLOAIHINHKT
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @DiemToiThieu FLOAT, @DiemToiDa FLOAT;
    SELECT @DiemToiThieu = DiemToiThieu, @DiemToiDa = DiemToiDa FROM THAMSO;

    IF EXISTS (SELECT 1 FROM inserted i WHERE i.Diem < @DiemToiThieu OR i.Diem > @DiemToiDa)
    BEGIN
        RAISERROR ('Violation of the Diem Check constraint, Diem should be within DiemToiThieu and DiemToiDa', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
go
-- Bảng điểm môn: BDM001 - LOP1012019 - HK1 - MH01 (Toán)
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM001', 'HS001', '15m', 1, 7.25);
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM001', 'HS001', '45m', 1, 8.0);
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM001', 'HS001', '90m', 1, 9.0);

INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM001', 'HS002', '15m', 1, 6.5);
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM001', 'HS002', '45m', 1, 7.0);
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM001', 'HS002', '90m', 1, 8.0);

INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM001', 'HS003', '15m', 1, 5.5);
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM001', 'HS003', '45m', 1, 6.0);
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM001', 'HS003', '90m', 1, 7.0);

-- Bảng điểm môn: BDM002 - LOP1012019 - HK1 - MH02 (Vật Lý)
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM002', 'HS001', '15m', 1, 8.5);
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM002', 'HS001', '45m', 1, 9.0);
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM002', 'HS001', '90m', 1, 9.5);

INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM002', 'HS002', '15m', 1, 7.5);
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM002', 'HS002', '45m', 1, 8.0);
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM002', 'HS002', '90m', 1, 8.5);

INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM002', 'HS003', '15m', 1, 6.5);
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM002', 'HS003', '45m', 1, 7.0);
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM002', 'HS003', '90m', 1, 7.5);

-- Bảng điểm môn: BDM003 - LOP1012019 - HK1 - MH03 (Hóa Học)
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM003', 'HS001', '15m', 1, 9.0);
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM003', 'HS001', '45m', 1, 9.5);
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM003', 'HS001', '90m', 1, 10.0);

INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM003', 'HS002', '15m', 1, 8.0);
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM003', 'HS002', '45m', 1, 8.5);
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM003', 'HS002', '90m', 1, 9.0);

INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM003', 'HS003', '15m', 1, 7.0);
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM003', 'HS003', '45m', 1, 7.5);
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM003', 'HS003', '90m', 1, 8.0);

-- Bảng điểm môn: BDM004 - LOP1012019 - HK2 - MH01 (Toán)
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM004', 'HS001', '15m', 1, 8.0);
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM004', 'HS001', '45m', 1, 8.5);
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM004', 'HS001', '90m', 1, 9.0);

INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM004', 'HS002', '15m', 1, 7.0);
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM004', 'HS002', '45m', 1, 7.5);
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM004', 'HS002', '90m', 1, 8.0);

INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM004', 'HS003', '15m', 1, 6.0);
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM004', 'HS003', '45m', 1, 6.5);
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM004', 'HS003', '90m', 1, 7.0);

-- Bảng điểm môn: BDM005 - LOP1012019 - HK2 - MH02 (Vật Lý)
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM005', 'HS001', '15m', 1, 7.5);
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM005', 'HS001', '45m', 1, 8.0);
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM005', 'HS001', '90m', 1, 8.5);

INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM005', 'HS002', '15m', 1, 6.5);
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM005', 'HS002', '45m', 1, 7.0);
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM005', 'HS002', '90m', 1, 7.5);

INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM005', 'HS003', '15m', 1, 5.5);
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM005', 'HS003', '45m', 1, 6.0);
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM005', 'HS003', '90m', 1, 6.5);

-- Bảng điểm môn: BDM006 - LOP1012019 - HK2 - MH03 (Thể Dục)
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM006', 'HS001', '15m', 1, 8.0);
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM006', 'HS001', '45m', 1, 8.5);
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM006', 'HS001', '90m', 1, 9.0);

INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM006', 'HS002', '15m', 1, 7.0);
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM006', 'HS002', '45m', 1, 7.5);
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM006', 'HS002', '90m', 1, 8.0);

INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM006', 'HS003', '15m', 1, 6.0);
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM006', 'HS003', '45m', 1, 6.5);
INSERT INTO CT_DIEMLOAIHINHKT VALUES ('BDM006', 'HS003', '90m', 1, 7.0);

create table CT_BANGDIEMMON
(
	MaBangDiem varchar(10),
	MaHocSinh varchar(10),
	DTBMon Decimal(4,2),
	primary key (MaBangDiem, MaHocSinh),
	foreign key (MaBangDiem) references BANGDIEMMON(MaBangDiem),
	foreign key (MaHocSinh) references HOCSINH(MaHocSinh)
)
SELECT
    hs.HoTen,
    lop.TenLop,
    hk.TenHocKi,
    mh.TenMonHoc,
    ROUND(SUM(ct.Diem * lh.HeSo) * 1.0 / NULLIF(SUM(lh.HeSo), 0), 2) AS 'DTB MonHoc'
FROM
    HOCSINH hs
    JOIN LOP lop ON hs.MaLop = lop.MaLop
    JOIN BANGDIEMMON bdm ON lop.MaLop = bdm.MaLop
    JOIN HOCKI hk ON bdm.MaHocKi = hk.MaHocKi
    JOIN MONHOC mh ON bdm.MaMonHoc = mh.MaMonHoc
    LEFT JOIN CT_DIEMLOAIHINHKT ct ON bdm.MaBangDiem = ct.MaBangDiem AND hs.MaHocSinh = ct.MaHocSinh
    LEFT JOIN LOAIHINHKIEMTRA lh ON ct.MaLoaiHinhKT = lh.MaLoaiHinhKT
GROUP BY
    hs.HoTen, lop.TenLop, hk.TenHocKi, mh.TenMonHoc;

SELECT 
    hs.HoTen,
    lop.TenLop,
    hk.TenHocKi,
    ROUND(SUM(ct.Diem * mh.HeSo * lh.HeSo) / SUM(mh.HeSo * lh.HeSo), 2) as DTBHocKi
FROM 
    HOCSINH hs 
    JOIN LOP lop ON hs.MaLop = lop.MaLop
    JOIN BANGDIEMMON bdm ON lop.MaLop = bdm.MaLop
    JOIN HOCKI hk ON bdm.MaHocKi = hk.MaHocKi
    JOIN MONHOC mh ON bdm.MaMonHoc = mh.MaMonHoc
    LEFT JOIN CT_DIEMLOAIHINHKT ct ON bdm.MaBangDiem = ct.MaBangDiem AND hs.MaHocSinh = ct.MaHocSinh
    LEFT JOIN LOAIHINHKIEMTRA lh ON ct.MaLoaiHinhKT = lh.MaLoaiHinhKT
GROUP BY 
    hs.HoTen,
    lop.TenLop,
    hk.TenHocKi;
create table BAOCAOTONGKETMON
(
	MaBaoCaoMon varchar(10) primary key,
	MaHocKi varchar(10) foreign key references HOCKI(MaHocKi),
	MaNamHoc varchar(4) foreign key references NAMHOC(MaNamHoc),
	MaMonHoc varchar(10) foreign key references MONHOC(MaMonHoc)
)
create table CT_BAOCAOTONGKETMON
(
	MaBaoCaoMon varchar(10),
	MaLop varchar(10),
	SoLuongDat int,
	TiLeDat float,
	primary key (MaBaoCaoMon, MaLop),
	foreign key (MaBaoCaoMon) references BAOCAOTONGKETMON(MaBaoCaoMon),
	foreign key (MaLop) references LOP(MaLop)
)
go
CREATE TRIGGER DTBMon_Check_FOR_CT_BAOCAOTONGKETMON2
ON CT_BANGDIEMMON
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @DiemDatMon FLOAT, @MaBangDiem VARCHAR(10), @MaLop VARCHAR(10), @SiSo INT;
    
    SELECT @DiemDatMon = DiemDatMon FROM THAMSO;
    SELECT @MaBangDiem = MaBangDiem FROM inserted;
    SELECT @MaLop = MaLop FROM BANGDIEMMON WHERE MaBangDiem = @MaBangDiem;
    SELECT @SiSo = SiSo FROM LOP WHERE MaLop = @MaLop;
    
    IF EXISTS (SELECT 1 FROM inserted i WHERE i.DTBMon >= @DiemDatMon)
    BEGIN
        UPDATE CT_BAOCAOTONGKETMON
        SET SoLuongDat = SoLuongDat + 1
        WHERE MaBaoCaoMon = @MaBangDiem; -- Sửa MaBangDiem thành MaBaoCaoMon
    END
    UPDATE CT_BAOCAOTONGKETMON
    SET TiLeDat = (SoLuongDat / @SiSo) * 100.0
    WHERE MaBaoCaoMon = @MaBangDiem; -- Sửa MaBangDiem thành MaBaoCaoMon
END;
GO

create table CHITIETDSLOP
(
	MaChiTietDSLop varchar(10),
	MaLop varchar(10),
	MaHocKi varchar(10),
	MaHocSinh varchar(10),
	DTBHocKi decimal(2,2),
	primary key (MaChiTietDSLop, MaLop, MaHocKi, MaHocSinh),
	foreign key (MaLop) references LOP(MaLop),
	foreign key (MaHocKi) references HOCKI(MaHocKi),
	foreign key (MaHocSinh) references HOCSINH(MaHocSinh)
)

create table BAOCAOTONGKETHK
(
	MaNamHoc varchar(4),
	MaHocKi varchar(10),
	MaLop varchar(10),
	SoLuongDat int,
	TiLeDat float,
	primary key (MaNamHoc, MaHocKi, MaLop),
	foreign key (MaNamHoc) references NAMHOC(MaNamHoc),
	foreign key (MaHocKi) references HOCKI(MaHocKi),
	foreign key (MaLop) references LOP(MaLop)
)
go
CREATE TRIGGER Increase_SoLuongDat
ON CHITIETDSLOP
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @DiemDat FLOAT, @MaLop VARCHAR(10), @MaHocKi VARCHAR(10), @MaNamHoc VARCHAR(10), @SiSo INT;
    
    SELECT @DiemDat = DiemDat FROM THAMSO;
    SELECT @MaLop = MaLop, @MaHocKi = MaHocKi FROM inserted; -- Cập nhật từ bảng dữ liệu đầu vào
    SELECT @SiSo = SiSo FROM LOP WHERE MaLop = @MaLop;
    
    IF EXISTS (SELECT 1 FROM inserted i WHERE i.DTBHocKi >= @DiemDat)
    BEGIN
	UPDATE BAOCAOTONGKETHK
	SET SoLuongDat = SoLuongDat + 1
	WHERE MaLop = @MaLop AND MaHocKi = @MaHocKi;

	UPDATE BAOCAOTONGKETHK
	SET TiLeDat = (CAST(SoLuongDat AS FLOAT) / CAST(@SiSo AS FLOAT)) * 100.0
	WHERE MaLop = @MaLop AND MaHocKi = @MaHocKi;
	END;
end;
GO

CREATE TABLE LOAINGUOIDUNG
(
	MaLoai VARCHAR(6) PRIMARY KEY,
	TenLoai NVARCHAR(30) 
)

INSERT INTO LOAINGUOIDUNG VALUES('LND001', N'Ban giám hiệu')
INSERT INTO LOAINGUOIDUNG VALUES('LND002', N'Giáo viên')
INSERT INTO LOAINGUOIDUNG VALUES('LND003', N'Nhân viên giáo vụ')

CREATE TABLE NGUOIDUNG
(
	MaNguoiDung VARCHAR(6) PRIMARY KEY,
	MaLoai VARCHAR(6),
	TenNguoiDung NVARCHAR(30),
	TenDangNhap NVARCHAR(30),
	MatKhau VARCHAR(64),
	CONSTRAINT FK_NGUOIDUNG_LOAINGUOIDUNG FOREIGN KEY(MaLoai) REFERENCES LOAINGUOIDUNG(MaLoai)
)

