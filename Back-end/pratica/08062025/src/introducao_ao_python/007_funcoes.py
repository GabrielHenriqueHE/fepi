def media(n):
    soma = 0
    for numero in numeros:
        soma += numero
    return soma/len(numeros)

numeros = [1, 2, 3, 4, 5]
resultado = media(numeros)
print(resultado)