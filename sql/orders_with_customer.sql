CREATE VIEW orders_with_customer AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    o.promised_delivery_time,
    o.actual_delivery_time,
    o.delivery_status,
    o.order_total,
    c.area,
    c.customer_segment
FROM blinkit_orders o
LEFT JOIN blinkit_customers c
ON o.customer_id = c.customer_id;
