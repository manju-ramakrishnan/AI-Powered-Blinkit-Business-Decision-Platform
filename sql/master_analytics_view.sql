CREATE OR REPLACE VIEW master_analytics_view AS

-- STEP A: "SQUASH" THE TRANSACTIONAL DATA
-- 1. Aggregate Marketing Spend (Daily)
WITH daily_marketing AS (
    SELECT 
        date::DATE AS report_date,
        SUM(spend) AS total_spend,
        SUM(impressions) AS total_impressions,
        SUM(clicks) AS total_clicks
    FROM blinkit_marketing_performance
    GROUP BY 1
),

-- 2. Aggregate Orders & Logistics (Daily)
daily_orders AS (
    SELECT 
        order_date::DATE AS report_date,
        SUM(order_total) AS total_revenue,
        COUNT(order_id) AS total_orders,
        -- Calculate Avg Delay in minutes (Actual - Promised)
        AVG(EXTRACT(EPOCH FROM (actual_delivery_time - promised_delivery_time)) / 60) AS avg_delay_mins
    FROM blinkit_orders
    GROUP BY 1
),

-- 3. Aggregate Product Margins (Joining Items + Products)
daily_profit AS (
    SELECT 
        o.order_date::DATE AS report_date,
        SUM(oi.quantity * oi.unit_price * (p.margin_percentage / 100.0)) AS total_profit
    FROM blinkit_order_items oi
    JOIN blinkit_products p ON oi.product_id = p.product_id
    JOIN blinkit_orders o ON oi.order_id = o.order_id
    GROUP BY 1
),

-- 4. Aggregate Customer Sentiment (Daily)
daily_feedback AS (
    SELECT 
        feedback_date::DATE AS report_date,
        AVG(rating) AS avg_rating,
        COUNT(feedback_id) AS total_reviews
    FROM blinkit_customer_feedback
    GROUP BY 1
)

-- STEP B & C: JOIN AND CALCULATE KPI
SELECT 
    COALESCE(m.report_date, o.report_date) AS report_date,
    
    -- Revenue & Volume
    COALESCE(o.total_revenue, 0) AS revenue,
    COALESCE(o.total_orders, 0) AS order_count,
    
    -- Marketing Spend
    COALESCE(m.total_spend, 0) AS marketing_spend,
    
    -- ROAS Calculation (Revenue / Spend)
    -- Using NULLIF to prevent "Division by Zero" errors
    ROUND(COALESCE(o.total_revenue, 0) / NULLIF(m.total_spend, 0), 2) AS roas,
    
    -- Operations & Sentiment
    ROUND(COALESCE(o.avg_delay_mins, 0), 2) AS avg_delay,
    ROUND(COALESCE(dp.total_profit, 0), 2) AS estimated_profit,
    ROUND(COALESCE(f.avg_rating, 0), 1) AS customer_satisfaction

FROM daily_marketing m
FULL OUTER JOIN daily_orders o ON m.report_date = o.report_date
LEFT JOIN daily_profit dp ON m.report_date = dp.report_date
LEFT JOIN daily_feedback f ON m.report_date = f.report_date
ORDER BY report_date DESC;