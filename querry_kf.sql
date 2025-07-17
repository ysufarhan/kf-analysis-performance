WITH kf_analysis_performance AS (
    SELECT
        *,
        -- Hitung nett_sales dengan CAST
        ROUND(CAST(price AS FLOAT64) * (1 - CAST(discount_percentage AS FLOAT64))) AS nett_sales
    FROM
        `rakamin-kf-analytics-448708.kimia_farma.kf_final_transaction`
),
kf_with_profit AS (
    SELECT
        *,
        -- Gunakan nett_sales yang sudah dihitung di CASE --
        CASE
            WHEN nett_sales <= 50000 THEN 0.1
            WHEN nett_sales > 50000 AND nett_sales <= 100000 THEN 0.15
            WHEN nett_sales > 100000 AND nett_sales <= 300000 THEN 0.2
            WHEN nett_sales > 300000 AND nett_sales <= 500000 THEN 0.25
            WHEN nett_sales > 500000 THEN 0.3
        END AS persentase_gross_laba
    FROM
        kf_analysis_performance
)
SELECT
    ft.transaction_id,
    ft.date,
    ft.branch_id,
    kc.branch_name,
    kc.kota,
    kc.provinsi,
    kc.rating AS rating_cabang,
    ft.customer_name,
    ft.product_id,
    kp.product_name,
    kp.product_category,
    ft.price AS actual_price,
    ft.discount_percentage,
    ft.persentase_gross_laba,
    ft.nett_sales,
    ft.nett_sales * ft.persentase_gross_laba AS nett_profit,
    ft.rating AS rating_transaksi
FROM
    kf_with_profit AS ft
JOIN `rakamin-kf-analytics-448708.kimia_farma.kf_product` AS kp
    ON kp.product_id = ft.product_id
JOIN `rakamin-kf-analytics-448708.kimia_farma.kf_kantor_cabang` AS kc
    ON kc.branch_id = ft.branch_id;
