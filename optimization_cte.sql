USE product_db;

CREATE INDEX idx_order_date
	ON orders(order_date)

WITH cte AS (
    SELECT o.order_id, o.order_date, p.product_id, p.product_name, c.city
    FROM orders AS o
    JOIN products AS p ON o.product_id = p.product_id
    JOIN customers AS c ON o.customer_id = c.id
    WHERE o.order_date > '2023-01-01'
),

ProductCounts AS (
    SELECT product_name, COUNT(*) AS order_count
    FROM cte
    GROUP BY product_name
)

SELECT
    (SELECT product_name FROM ProductCounts ORDER BY order_count DESC LIMIT 1) AS most_popular_product,
    (SELECT product_name FROM ProductCounts ORDER BY order_count ASC LIMIT 1) AS least_popular_product;
--------------------------

SELECT
  (
    SELECT
      product_name
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
  ) AS most_popular_product,
  (
    SELECT
      product_name
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
  ) AS least_popular_product;
