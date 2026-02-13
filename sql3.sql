WITH client_stats AS (
    SELECT 
        a.client_id,
        COUNT(DISTINCT a.account_id) as total_accounts,
        SUM(a.balance) as total_balance,
        COUNT(CASE WHEN t.transaction_type = 'deposit' THEN 1 END) as total_deposits,
        COUNT(CASE WHEN t.transaction_type = 'withdrawal' THEN 1 END) as total_withdrawals
    FROM accounts a
    LEFT JOIN transactions t ON a.account_id = t.account_id
    GROUP BY a.client_id
)
SELECT 
    c.client_id,
    c.name,
    c.age,
    COALESCE(cs.total_accounts, 0) as total_accounts,
    COALESCE(cs.total_balance, 0) as total_balance,
    COALESCE(cs.total_deposits, 0) as total_deposits,
    COALESCE(cs.total_withdrawals, 0) as total_withdrawals
FROM clients c
LEFT JOIN client_stats cs ON c.client_id = cs.client_id
WHERE c.registration_date >= '2020-01-01'
ORDER BY total_balance DESC;