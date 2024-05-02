-- Question 1 --
-- Selama transaksi yang terjadi selama 2021, pada bulan apa total nilai transaksi (after_discount) paling besar?
SELECT 
    EXTRACT(MONTH FROM order_date) AS bulan_transaksi,
    SUM(after_discount) AS total_transaksi
FROM 
    order_detail
WHERE 
    is_valid = 1 
AND 
    EXTRACT(YEAR FROM order_date) = 2021
GROUP BY 
    EXTRACT(MONTH FROM order_date)
ORDER BY 
    SUM(after_discount) DESC;




-- Question 2 --
-- Selama transaksi pada tahun 2022, kategori apa yang menghasilkan nilai transaksi paling besar?
SELECT 
    sd.category,
    SUM(od.after_discount) AS total_transaksi
FROM 
    order_detail AS od
JOIN 
    sku_detail AS sd ON od.sku_id = sd.id
WHERE 
    od.is_valid = 1 AND
    EXTRACT(YEAR FROM od.order_date) = 2022
GROUP BY 
    sd.category
ORDER BY 
    total_transaksi 
DESC;



-- Question 3 --
-- Bandingkan nilai transaksi dari masing-masing kategori pada tahun 2021 dengan 2022. Sebutkan kategori apa saja yang mengalami peningkatan dan kategori apa yang mengalami penurunan nilai transaksi dari tahun 2021 ke 2022.
SELECT
    sd.category,
    SUM(CASE WHEN EXTRACT(YEAR FROM od.order_date) = 2021 THEN od.after_discount ELSE 0 END) AS total_transaksi_2021,
    SUM(CASE WHEN EXTRACT(YEAR FROM od.order_date) = 2022 THEN od.after_discount ELSE 0 END) AS total_transaksi_2022,
    ROUND(((SUM(CASE WHEN EXTRACT(year from od.order_date) = 2022 THEN od.after_discount end) -
            (SUM(CASE WHEN EXTRACT(year from od.order_date) = 2021 THEN od.after_discount end))))::DECIMAL,0) AS pertumbuhan,
    CASE
        WHEN SUM(CASE WHEN EXTRACT(YEAR FROM od.order_date) = 2022 THEN od.after_discount ELSE 0 END) > SUM(CASE WHEN EXTRACT(YEAR FROM od.order_date) = 2021 THEN od.after_discount ELSE 0 END) THEN 'Kenaikan'
        WHEN SUM(CASE WHEN EXTRACT(YEAR FROM od.order_date) = 2022 THEN od.after_discount ELSE 0 END) < SUM(CASE WHEN EXTRACT(YEAR FROM od.order_date) = 2021 THEN od.after_discount ELSE 0 END) THEN 'Penurunan'
        ELSE 'Tidak Ada Perubahan'
    END AS status
FROM
    order_detail od
JOIN
    sku_detail sd ON od.sku_id = sd.id
WHERE
    od.is_valid = 1
    AND EXTRACT(YEAR FROM od.order_date) IN (2021, 2022)
GROUP BY
    sd.category
HAVING
    SUM(CASE WHEN EXTRACT(YEAR FROM od.order_date) = 2021 THEN od.after_discount ELSE 0 END) <> 0
    AND SUM(CASE WHEN EXTRACT(YEAR FROM od.order_date) = 2022 THEN od.after_discount ELSE 0 END) <> 0
ORDER BY
    pertumbuhan DESC;
    



-- Question 4 --
-- Tampilkan top 5 metode pembayaran yang paling populer digunakan selama 2022 (berdasarkan total unique order)
SELECT
	payment_method,
    COUNT(DISTINCT od.id) as jumlah
FROM
	order_detail as od
JOIN 
	payment_detail as pd on pd.id = od.payment_id
WHERE
	EXTRACT (YEAR FROM order_date) = 2022
    AND is_valid = 1
GROUP BY 
	1
ORDER by 
	2 
DESC
LIMIT 5;



-- Question 5 --
-- Urutkan dari ke-5 produk ini berdasarkan nilai transaksinya: 1. Samsung 2. Apple 3. Sony 4. Huawei 5. Lenovo
SELECT
	CASE
    	WHEN LOWER(sku_name) LIKE '%samsung%' THEN 'Samsung'
        WHEN LOWER(sku_name) LIKE '%apple%' OR LOWER(sku_name) LIKE '%iphone%' OR LOWER(sku_name) LIKE '%macbook%' THEN 'Apple'
        WHEN LOWER(sku_name) LIKE '%sony%' THEN 'Sony'
        WHEN LOWER(sku_name) LIKE '%huawei%' THEN 'Huawei'
        WHEN LOWER(sku_name) LIKE '%lenovo%' THEN 'Lenovo'
	END AS produk,
    ROUND(SUM(after_discount)::NUMERIC, 0) AS transaksi
FROM
	order_detail AS od
left JOIN 
	sku_detail AS sd ON od.sku_id = sd.id
WHERE
	order_date BETWEEN '2022-01-01' and '2022-12-31' AND
    is_valid = 1 AND
    sd.category = 'Mobiles & Tablets' AND
    CASE
    	WHEN LOWER(sku_name) LIKE '%samsung%' THEN TRUE
        WHEN LOWER(sku_name) LIKE '%apple%' OR LOWER(sku_name) LIKE '%iphone%' OR LOWER(sku_name) LIKE '%macbook%' THEN TRUE
        WHEN LOWER(sku_name) LIKE '%sony%' THEN TRUE
        WHEN LOWER(sku_name) LIKE '%huawei%' THEN TRUE
        WHEN LOWER(sku_name) LIKE '%lenovo%' THEN TRUE
        ELSE FALSE
    END
GROUP BY
	1
ORDER BY
	transaksi DESC;
