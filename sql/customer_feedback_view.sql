CREATE VIEW customer_feedback_view AS
SELECT
    f.feedback_id,
    f.feedback_text,
    f.feedback_category,
    f.sentiment,
    c.area
FROM blinkit_customer_feedback f
LEFT JOIN blinkit_customers c
ON f.customer_id = c.customer_id