# Stored procedures

## SP_GET_USER_INFO_BY_LOGIN

Source code: [SP_GET_USER_INFO_BY_LOGIN](./SP_GET_USER_INFO_BY_LOGIN.sql)

Usecase: Tại trang đăng nhập, khi người dùng nhập vào login name (không dùng username) thì sẽ dùng login name này và gọi SP này để lấy các thông tin:

- Mã nhân viên (MANV)
- Họ và tên (HOTEN)
- Tên nhóm quyền (TENNHOM): là tên của nhóm quyền như: Công ty, Chi nhánh hay Người dùng.

## VIEW_GET_EMPLOYEE_LIST

Source code: [VIEW_GET_EMPLOYEE_LIST](VIEW_GET_EMPLOYEE_LIST.sql)

Usecase: Lấy danh sách nhân viên gồm các thông tin:

- Mã nhân viên (MANV)
- Họ và tên (HOTEN)

Ví dụ output:

| MANV | HOTEN |
| :--: | :-----|
| 1 | Nguyen Van A - 1 |
| 2 | Nguyen Thi B - 2 |

## SP_CHECK_EXIST_EMPLOYEE_ID

Source code: [SP_CHECK_EXIST_EMPLOYEE_ID](./SP_CHECK_EXIST_EMPLOYEE_ID.sql)

Usecase: Sử dụng để kiểm tra một mã nhân viên đã tồn tại hay chưa

Lưu ý:
- LINK0 nối Server phân mảnh tới Server 3 (Server tra cứu)
- LINK1 nối Server phân mảnh này với Server phân mảnh còn lại

Cú pháp sử dụng: Kiểm tra xem mã nhân viên 20 có tồn tại hay không

```sql
DECLARE @RESULT int
EXEC @RESULT = SP_CHECK_EXIST_EMPLOYEE_ID 20
SELECT @RESULT
```

## SP_CHANGE_BRANCH

Source code: [SP_CHANGE_BRANCH](SP_CHANGE_BRANCH.sql)

Usecase: chuyển nhân viên từ chi nhánh này sang chi nhánh khác mà không ảnh hưởng đến tính toàn vẹn dữ liệu, mã nhân viên sẽ không bị trùng.

SP có sử dụng Transaction để đảm bảo được tính toàn vẹn dữ liệu của cơ sở dữ liệu trong trường hợp có xảy ra sự cố khiến cho SP bị dừng hoặc là có mâu thuẫn với ràng buộc toàn vẹn của cơ sở dữ liệu.

Chú ý: nếu `SP_CHANGE_BRANCH` chạy mà gặp lỗi **"MSDTC on server is unavailable"** thì nghĩa là dịch vụ MSDTC chưa được bật. Do đó, cần phải bật dịch vụ theo các bước sau:

1. Bấm Windows Start -> Settings -> Control Panel -> Administrative tools -> Services.
1. Tìm từ khoá **"Distributed Transaction Coordinator"**, chuột phải và chọn Start.
1. Vào Properties -> Startup type -> đổi sang automatic để tự động chạy dịch vụ này.

Cú pháp sử dụng: Chuyển nhân viên có mã nhân viên là 14 sang chi nhánh 1.

```sql
EXEC SP_CHANGE_BRANCH 14, 'CN1';
```