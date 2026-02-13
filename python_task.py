def place_atms(n, k, distances):
    left = 1
    right = max(distances)

    while left < right:
        mid = (left + right) // 2

        need = 0
        for d in distances:
            parts = (d + mid - 1) // mid
            need += parts - 1

        if need <= k:
            right = mid  # можно сделать ещё меньше
        else:
            left = mid + 1  # нужно больше

    optimal_max = left
    print(f"Оптимальное максимальное расстояние: {optimal_max}")

    result = []

    for d in distances:
        parts = (d + optimal_max - 1) // optimal_max

        base = d // parts  # целая часть
        remainder = d % parts  # остаток

        for i in range(parts):
            if i < remainder:
                result.append(base + 1)
            else:
                result.append(base)

    return result


n, k = 5, 4
L = [100, 180, 50, 45, 150]
print(place_atms(n, k, L))
