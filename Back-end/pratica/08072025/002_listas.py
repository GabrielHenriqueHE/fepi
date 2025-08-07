# Definindo listas
lista = ["banana", "laranja", "maça"]
print(lista)

# Exibindo o tamanho da lista
print(len(lista))

# Listas de diferentes tipos
lista2 = [1, 5, 7, 9, 3]
lista3 = [True, True, True]
print(lista)
print(lista2)
print(lista3)

# Exibindo o tipo primitivo da variável lista
print(type(lista))

# Lista a partir da função built-in
lista = list(("banana", "laranja", "maça"))
print(lista)

# Imprimindo o segundo item da lista
print(lista[1])

cores = ["vermelho", "azul", "verde", "amarelo", "roxo", "laranja", "preto"]
print(cores[2:5])

print(cores[:3])

print(cores[4:])

# Verifica se um valor está contido em uma lista
if "azul" in cores:
    print("A cor azul está presente.")

# Substituir o terceiro item da lista
print(cores)
cores[2] = "laranja"
print(cores)

# Inserindo itens na lista
cores.append("lilás")

# Insere um item na segunda posição
cores.insert(1, "marrom")

# Remove um item especificado
print(cores)
cores.remove("vermelho")
print(cores)

# Remove o índice especificado
print(cores)
cores.pop(2)
print(cores)

# Esvazia a lista
print(cores)
cores.clear()
print(cores)

# Exclui completamente a lista
print(cores)
del cores
#print(cores)

# Percorre os itens da lista com o operador for:
cores = ["vermelho", "azul", "verde", "amarelo", "roxo", "laranja", "preto"]
for cor in cores:
    print(cores)

for i in range(len(cores)):
    print(cores[i])

# Percorre os itens da lista com o operador while
i = 0
while i < len(cores):
    print(cores[i])
    i += 1

# List comprehension
[print(cor) for cor in cores]

# Ordena a lista alfanumericamente (crescente)
cores = ["vermelho", "azul", "verde", "amarelo", "roxo", "laranja", "preto"]
cores.sort()
print(cores)

# Decrescente
cores.sort(reverse=True)

# Fazendo uma cópia da lista
cores2 = cores.copy()
print(cores2)

# Fazendo cópia com função built-in
cores3 = list(cores2)
print(cores3)

# Juntando as listas
cores = ["vermelho", "azul", "verde", "amarelo"]
numeros = [23, 73, 7, 39, 58]
cores_num = cores + numeros
print(cores_num)
