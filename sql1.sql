SELECT 
    u.id,
    u.username,
    COALESCE(
        (SELECT role 
         FROM user_roles ur 
         WHERE ur.user_id = u.id 
         ORDER BY assigned_at DESC 
         LIMIT 1), 
        'no role'
    ) as role,
    COUNT(ua.id) as activity_count
FROM users u
LEFT JOIN user_activity ua ON u.id = ua.user_id 
    AND ua.activity_date >= DATE('now', '-1 month')
GROUP BY u.id, u.username
ORDER BY activity_count DESC, u.id;