numeros: list[int] = [1, 2, 3, 4, 5]

# for:
for numero in numeros:
    print(numero)

# while:
count: int = 0
while count < 5:
    print(f"Count: {count}")
    count += 1

# break
for numero in numeros:
    if numero == 3:
        break
    print(numero)

# continue
for numero in numeros:
    if numero == 3:
        continue
    print(numero)
