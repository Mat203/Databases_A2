create index idx_order_date
	on orders(order_date)

WITH cte AS (
    SELECT o.order_id, o.order_date, p.product_id, p.product_name, c.city
    FROM orders AS o
    JOIN products AS p ON o.product_id = p.product_id
    JOIN customers AS c ON o.customer_id = c.id
    WHERE o.order_date > '2023-01-01'
),

ProductCountsByCity AS (
    SELECT product_name, city, COUNT(*) AS order_count
    FROM cte
    GROUP BY product_name, city
)

SELECT 
    pc.city,
    (SELECT product_name FROM ProductCountsByCity WHERE city=pc.city ORDER BY order_count DESC LIMIT 1) as most_popular_product,
    (SELECT product_name FROM ProductCountsByCity WHERE city=pc.city ORDER BY order_count ASC LIMIT 1) as least_popular_product
FROM ProductCountsByCity pc
GROUP BY pc.city
;

SELECT
  (
    SELECT
      CONCAT(product_name, ": ", cnt)
    FROM
      (
        SELECT
          product_name,
          COUNT(*) AS cnt
        FROM
          orders o
          JOIN products p ON o.product_id = p.product_id
        WHERE
          o.order_date > '2023-01-01'
        GROUP BY
          product_name
      ) AS product_counts
    WHERE
      cnt = (
        SELECT
          MIN(cnt)
        FROM
          (
            SELECT
              COUNT(*) AS cnt
            FROM
              orders o
              JOIN products p ON o.product_id = p.product_id
            WHERE
              o.order_date > '2023-01-01'
            GROUP BY
              product_name
          ) AS min_counts
      )
    LIMIT 1
  ) AS least_popular_product,
  (
    SELECT
      CONCAT(product_name, ": ", cnt)
    FROM
      (
        SELECT
          product_name,
          COUNT(*) AS cnt
        FROM
          orders o
          JOIN products p ON o.product_id = p.product_id
        WHERE
          o.order_date > '2023-01-01'
        GROUP BY
          product_name
      ) AS product_counts
    WHERE
      cnt = (
        SELECT
          MAX(cnt)
        FROM
          (
            SELECT
              COUNT(*) AS cnt
            FROM
              orders o
              JOIN products p ON o.product_id = p.product_id
            WHERE
              o.order_date > '2023-01-01'
            GROUP BY
              product_name
          ) AS max_counts
      )
    LIMIT 1
  ) AS most_popular_product;