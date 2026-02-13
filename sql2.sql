WITH tranches_2024 AS (
    SELECT 
        inn,
        credit_num,
        account,
        operation_datetime as tranche_datetime,
        operation_sum as tranche_sum,
        doc_id as tranche_doc_id
    FROM tranches
    WHERE EXTRACT(YEAR FROM operation_datetime) = 2024
),
transactions_2024 AS (
    SELECT 
        inn::text as inn,
        account,
        operation_datetime as transaction_datetime,
        operation_sum as transaction_sum,
        ctrg_inn,
        ctrg_account,
        doc_id as transaction_doc_id
    FROM transactions
    WHERE EXTRACT(YEAR FROM operation_datetime) = 2024
),
matches AS (
    SELECT 
        t.*,
        tr.transaction_datetime,
        tr.transaction_sum,
        tr.ctrg_inn,
        tr.ctrg_account,
        tr.transaction_doc_id,
        CASE 
            WHEN t.tranche_sum = tr.transaction_sum THEN 'exact_match'
            ELSE 'excess_match'
        END as match_type,
        ROW_NUMBER() OVER (
            PARTITION BY t.tranche_doc_id 
            ORDER BY 
                CASE WHEN t.tranche_sum = tr.transaction_sum THEN 1 ELSE 2 END,
                tr.transaction_datetime
        ) as rn
    FROM tranches_2024 t
    JOIN transactions_2024 tr 
        ON t.inn = tr.inn 
        AND t.account = tr.account
        AND tr.transaction_datetime BETWEEN t.tranche_datetime 
                                        AND t.tranche_datetime + INTERVAL '10 days'
        AND (
            t.tranche_sum = tr.transaction_sum 
            OR 
            (t.tranche_sum < tr.transaction_sum AND NOT EXISTS (
                SELECT 1 
                FROM transactions_2024 tr2
                WHERE tr2.inn = tr.inn 
                AND tr2.account = tr.account
                AND tr2.operation_datetime BETWEEN t.tranche_datetime 
                                              AND t.tranche_datetime + INTERVAL '10 days'
                AND tr2.operation_sum = t.tranche_sum
            ))
        )
)
SELECT 
    inn,
    credit_num,
    tranche_datetime,
    tranche_sum,
    tranche_doc_id,
    transaction_datetime,
    transaction_sum,
    ctrg_inn,
    ctrg_account,
    transaction_doc_id,
    match_type
FROM matches
WHERE rn = 1
ORDER BY tranche_datetime;