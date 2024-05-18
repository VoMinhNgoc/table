use master
drop database if exists qlhs1
create database qlhs1
use qlhs1

create table THAMSO
(
    TuoiToiThieu int,
    TuoiToiDa int,
    SiSoToiDa int,
    DiemDatMon float,
    DiemDat float,
    DiemToiThieu float,
    DiemToiDa float
)
INSERT INTO THAMSO VALUES(15, 20, 40, 5, 5, 0, 10)

create table MONHOC
(
	MaMonHoc varchar(10) primary key,
	TenMonHoc varchar(50),
	HeSo int
)
INSERT INTO MONHOC VALUES('MH0001', N'Toán', 1)
INSERT INTO MONHOC VALUES('MH0002', N'Vật Lý', 1)
INSERT INTO MONHOC VALUES('MH0003', N'Hóa Học', 1)
INSERT INTO MONHOC VALUES('MH0004', N'Sinh Học', 1)
INSERT INTO MONHOC VALUES('MH0005', N'Lịch Sử', 1)
INSERT INTO MONHOC VALUES('MH0006', N'Địa Lý', 1)
INSERT INTO MONHOC VALUES('MH0007', N'Ngữ Văn', 1)
INSERT INTO MONHOC VALUES('MH0008', N'Đạo Đức', 1)
INSERT INTO MONHOC VALUES('MH0009', N'Thể Dục', 1)

create table KHOILOP
(
	MaKhoiLop varchar(10) primary key,
	TenKhoiLop varchar(50)
)
INSERT INTO KHOILOP VALUES('KHOI10', N'Khối 10')
INSERT INTO KHOILOP VALUES('KHOI11', N'Khối 11')
INSERT INTO KHOILOP VALUES('KHOI12', N'Khối 12') 

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
INSERT INTO NAMHOC VALUES('1920', '2019-2020')
INSERT INTO NAMHOC VALUES('2021', '2020-2021')

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
INSERT INTO LOP VALUES('LOP1011920', '10A1', 32, 'KHOI10', '1920')
INSERT INTO LOP VALUES('LOP1021920', '10A2', 33, 'KHOI10', '1920')
INSERT INTO LOP VALUES('LOP1031920', '10A3', 12, 'KHOI10', '1920')
INSERT INTO LOP VALUES('LOP1111920', '11A1', 32, 'KHOI11', '1920')
INSERT INTO LOP VALUES('LOP1121920', '11A2', 32, 'KHOI11', '1920')
INSERT INTO LOP VALUES('LOP1211920', '12A1', 32, 'KHOI12', '1920')

INSERT INTO LOP VALUES('LOP1012021', '10A1', 32,'KHOI10', '2021')
INSERT INTO LOP VALUES('LOP1022021', '10A2', 26,'KHOI10', '2021')
INSERT INTO LOP VALUES('LOP1032021', '10A3', 32,'KHOI10', '2021')
INSERT INTO LOP VALUES('LOP1042021', '10A4', 35,'KHOI10', '2021')

INSERT INTO LOP VALUES('LOP1112021', '11A1', 32,'KHOI11', '2021')
INSERT INTO LOP VALUES('LOP1122021', '11A2', 32,'KHOI11', '2021')
INSERT INTO LOP VALUES('LOP1132021', '11A3', 34,'KHOI11', '2021')

INSERT INTO LOP VALUES('LOP1212021', '12A1', 32,'KHOI12', '2021')
INSERT INTO LOP VALUES('LOP1222021', '12A2', 40,'KHOI12', '2021')

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
INSERT INTO HOCSINH VALUES ('HS001', 'LOP1012021', 'Nguyễn Văn A', '0', '2006-03-15', '123 Đường ABC, Quận 1, Thành phố Hồ Chí Minh', 'nguyenvana@example.com')
INSERT INTO HOCSINH VALUES ('HS002', 'LOP1112021', 'Trần Thị B', '1', '2002-07-20', '456 Đường XYZ, Quận 2, Thành phố Hồ Chí Minh', 'tranthib@example.com')
INSERT INTO HOCSINH VALUES ('HS003', 'LOP1212021', 'Phạm Đức C', '0', '2004-11-10', '789 Đường DEF, Quận 3, Thành phố Hồ Chí Minh', 'phamducc@example.com')
INSERT INTO HOCSINH VALUES ('HS004', 'LOP1012021', 'Trần Thanh Dương', '0', '2006-04-25', '456 Đường XYZ, Quận 2, Thành phố Hồ Chí Minh', 'tranduong@example.com');
INSERT INTO HOCSINH VALUES ('HS005', 'LOP1112021', 'Nguyễn Thị Hằng', '1', '2005-09-15', '789 Đường MNO, Quận 3, Thành phố Hồ Chí Minh', 'nguyenhang@example.com');
INSERT INTO HOCSINH VALUES ('HS006', 'LOP1212021', 'Lê Văn Đức', '0', '2004-12-10', '101 Đường QRS, Quận 4, Thành phố Hồ Chí Minh', 'levanduc@example.com');
INSERT INTO HOCSINH VALUES ('HS007', 'LOP1012021', 'Phạm Thị Hồng', '1', '2006-03-20', '111 Đường TUV, Quận 5, Thành phố Hồ Chí Minh', 'phamhong@example.com');

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
INSERT INTO BANGDIEMMON VALUES('01','LOP1031920','HK1','MH0001')
INSERT INTO BANGDIEMMON VALUES('02','LOP1031920','HK1','MH0002')
INSERT INTO BANGDIEMMON VALUES('03','LOP1111920','HK1','MH0003')
INSERT INTO BANGDIEMMON VALUES('04','LOP1012021','HK1','MH0002')
INSERT INTO BANGDIEMMON VALUES('05','LOP1211920','HK1','MH0004')

create table CT_BANGDIEMMON
(
	MaBangDiem varchar(10),
	MaHocSinh varchar(10),
	DTBMon Decimal(2,2),
	primary key (MaBangDiem, MaHocSinh),
	foreign key (MaBangDiem) references BANGDIEMMON(MaBangDiem),
	foreign key (MaHocSinh) references HOCSINH(MaHocSinh)
)
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
    MaBangDiem VARCHAR(10),
    MaHocSinh VARCHAR(10),
    MaLoaiHinhKT VARCHAR(10),
    Lan CHAR(2),
    Diem DECIMAL(2,2),
    PRIMARY KEY (MaBangDiem, MaHocSinh, MaLoaiHinhKT, Lan),
    FOREIGN KEY (MaBangDiem) REFERENCES BANGDIEMMON(MaBangDiem),
    FOREIGN KEY (MaHocSinh) REFERENCES HOCSINH(MaHocSinh),
    FOREIGN KEY (MaLoaiHinhKT) REFERENCES LOAIHINHKIEMTRA(MaLoaiHinhKT)
);
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
INSERT INTO CT_DIEMLOAIHINHKT VALUES('01','HS001','15m', 1, 10.00)
INSERT INTO CT_DIEMLOAIHINHKT VALUES('01','HS001','90m', 1, 9.50)
INSERT INTO CT_DIEMLOAIHINHKT VALUES('01','HS001','45m', 1, 7.00)


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

