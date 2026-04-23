create database session08_miniproject;
use session08_miniproject;

create table Customer(
	customer_id int primary key auto_increment,
    fullname varchar(100),
    email varchar(150) unique,
    gender int default 1,
    dob date
);

create table Category(
	category_id int primary key auto_increment,
    category_name varchar(100)
);

create table Product(
	product_id int primary key auto_increment,
    product_name varchar(100),
    product_price decimal(10,2),
    category_id int,
    foreign key (category_id) references Category(category_id)
);

create table Orders(
	order_id int primary key auto_increment,
    customer_id int,
    order_date date,
    foreign key (customer_id) references Customer(customer_id)
);

create table Order_Detail(
	order_detail_id int primary key auto_increment,
	order_id int,
    product_id int,
    quantity int,
    order_detail_price decimal(10,2),
    foreign key (order_id) references Orders(order_id),
    foreign key (product_id) references Product(product_id)
);

INSERT INTO Category (category_name)
VALUES 
    ('Điện thoại thông minh'),
    ('Máy tính xách tay'),
    ('Phụ kiện công nghệ'),
    ('Thiết bị gia dụng'),
    ('Thời trang nam nữ');

INSERT INTO Customer (fullname, email, gender, dob)
VALUES 
    ('Nguyễn Văn An', 'an.nguyen@email.com', 1, '1990-05-15'),
    ('Trần Thị Bình', 'binh.tran@email.com', 0, '1995-08-22'),
    ('Lê Hoàng Cường', 'cuong.le@email.com', 1, '1988-12-10'),
    ('Phạm Thu Dung', 'dung.pham@email.com', 0, '2001-03-05'),
    ('Hoàng Ngọc Minh', 'minh.hoang@email.com', 1, '1992-11-30');

INSERT INTO Product (product_name, product_price, category_id)
VALUES 
    ('iPhone 15 Pro Max', 29990000, 1),
    ('Samsung Galaxy S24 Ultra', 26990000, 1),
    ('MacBook Pro M3 14-inch', 39990000, 2),
    ('Tai nghe không dây AirPods Pro', 5990000, 3),
    ('Nồi chiên không dầu Philips', 2500000, 4),
    ('Áo thun cotton nam', 250000, 5);

INSERT INTO Orders (customer_id, order_date)
VALUES 
    (1, '2024-01-10'),
    (2, '2024-01-15'),
    (3, '2024-02-20'),
    (1, '2024-03-05'),
    (4, '2024-03-12'),
    (5, '2024-03-15');

INSERT INTO Order_Detail (order_id, product_id, quantity, order_detail_price)
VALUES 
    (1, 1, 1, 29990000),
    (1, 4, 1, 5990000),
    (2, 3, 1, 39990000),
    (3, 5, 2, 2500000),
    (4, 6, 3, 250000),
    (5, 2, 1, 26990000),	
    (6, 4, 2, 5990000); 
    

-- Phần III - Cập nhật dữ liệu
set sql_safe_updates = 0;
-- Cập nhật giá bán cho một sản phẩm.
update Product
set product_price = 30000000
where product_name = 'iPhone 15 Pro Max';

-- Cập nhật email cho một khách hàng.
update Customer
set email = 'nguyenan@email.com'
where customer_id = 1;

-- Phần IV - Xóa dữ liệu
-- Xóa một bản ghi chi tiết đơn hàng không hợp lệ (hoặc một đơn hàng bị hủy).
delete from Orders
where order_id = 1;

-- Phần V - Truy vấn dữ liệu 
-- 1.Lấy danh sách khách hàng gồm họ tên, email và sử dụng câu lệnh CASE để hiển thị giới tính dưới dạng văn bản ('Nam' hoặc 'Nữ'). Sử dụng AS để đặt lại tên cột.
select fullname, email,
case when gender = 1 then 'Nam' else 'Nữ' end as 'gender'
from Customer;

-- 2.Lấy thông tin 3 khách hàng trẻ tuổi nhất: Sử dụng hàm YEAR() và NOW() để tính tuổi, kết hợp mệnh đề ORDER BY và LIMIT.
select 
	customer_id, fullname, email,
	case when gender = 1 then 'Nam' else 'Nữ' end as 'gender',
	dob,
    (year(now()) - year(dob)) as age
from Customer
order by age asc
limit 3;

-- 3.Hiển thị danh sách tất cả các đơn hàng kèm theo tên khách hàng tương ứng (Sử dụng INNER JOIN).
select o.order_id, order_date, c.fullname
from Orders o
inner join Customer c
on o.customer_id = c.customer_id;

-- 4.Đếm số lượng sản phẩm theo từng danh mục. Sử dụng GROUP BY và HAVING để chỉ hiển thị các danh mục có từ 2 sản phẩm trở lên.
select c.category_name, count(p.product_id) as total_product
from Category c
inner join Product p
on c.category_id = p.category_id
group by c.category_id, c.category_name
having count(p.product_id) >= 2;

-- 5.(Scalar Subquery) Lấy danh sách các sản phẩm có giá lớn hơn giá trị trung bình (AVG) của tất cả các sản phẩm trong cửa hàng.
select *
from Product
where product_price > (select avg(product_price) from Product);

-- 6.(Column Subquery) Lấy danh sách thông tin các khách hàng chưa từng đặt bất kỳ đơn hàng nào (Sử dụng toán tử NOT IN kết hợp truy vấn lồng).
SELECT 
    customer_id, 
    fullname, 
    email, 
    gender, 
    dob
FROM 
    Customer
WHERE 
    customer_id NOT IN (SELECT customer_id FROM Orders WHERE customer_id IS NOT NULL);

-- 7.(Subquery với hàm tổng hợp) Tìm các phòng ban/danh mục có tổng doanh thu lớn hơn 120% doanh thu trung bình của toàn bộ cửa hàng.
SELECT 
    c.category_name, 
    SUM(od.quantity * od.order_detail_price) AS category_revenue
FROM 
    Category c
INNER JOIN 
    Product p ON c.category_id = p.category_id
INNER JOIN 
    Order_Detail od ON p.product_id = od.product_id
GROUP BY 
    c.category_id, 
    c.category_name
HAVING 
    SUM(od.quantity * od.order_detail_price) > 1.2 * (
        -- Truy vấn con: Tính trung bình doanh thu của một danh mục
        SELECT SUM(od2.quantity * od2.order_detail_price) / COUNT(DISTINCT p2.category_id)
        FROM Order_Detail od2
        INNER JOIN Product p2 ON od2.product_id = p2.product_id
);
    
-- 8.(Correlated Subquery) Lấy danh sách các sản phẩm có giá đắt nhất trong từng danh mục (Truy vấn con tham chiếu đến outer query).
SELECT 
    p1.product_id, 
    p1.product_name, 
    p1.product_price, 
    p1.category_id
FROM 
    Product p1
WHERE 
    p1.product_price = (
        -- Inner Query: Tìm giá lớn nhất trong cùng danh mục với sản phẩm p1 đang xét
        SELECT MAX(p2.product_price) 
        FROM Product p2 
        WHERE p2.category_id = p1.category_id
    );
    
-- 9.(Truy vấn lồng nhiều cấp) Tìm họ tên của các khách hàng VIP đã từng mua sản phẩm thuộc danh mục 'Điện tử' (Sử dụng truy vấn lồng từ 3 cấp trở lên thông qua các bảng Customer, Order, Order_Detail, Product, Category).
SELECT fullname 
FROM Customer 
WHERE customer_id IN (
    -- Cấp 4: Tìm mã khách hàng có trong danh sách đơn hàng thỏa mãn
    SELECT customer_id 
    FROM Orders 
    WHERE order_id IN (
        -- Cấp 3: Tìm mã đơn hàng có chứa các sản phẩm thỏa mãn
        SELECT order_id 
        FROM Order_Detail 
        WHERE product_id IN (
            -- Cấp 2: Tìm mã sản phẩm thuộc về danh mục thỏa mãn
            SELECT product_id 
            FROM Product 
            WHERE category_id IN (
                -- Cấp 1 (Lõi): Tìm mã danh mục có tên là 'Điện thoại thông minh'
                SELECT category_id 
                FROM Category 
                WHERE category_name = 'Điện thoại thông minh'
            )
        )
    )
);