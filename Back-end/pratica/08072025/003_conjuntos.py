# Criando conjuntos
cores = {"vermelho", "azul", "verde", "amarelo"} # Itens duplicados não são permitidos!
print(cores)

# Comprimento do conjunto
print(len(cores))

# Loop pelo conjunto
for cor in cores:
    print(cor)

# Verificando a presença de um elemento no conjunto
print("verde" in cores)

# Adicionando um item ao conjuntocores = {"vermelho", "azul", "verde", "amarelo"}
cores.add("laranja")

# Adicionando itens de outro conjunto
cores_novas = {"marrom", "branco"}
cores.update(cores_novas)
print(cores)

# Removendo elementos
print(cores)
cores.remove("vermelho")
print(cores)
cores.add("vermelho")
cores.discard("vermelho")

# Removendo um valor aleatório
print(cores)
cores.pop()
print(cores)

# Esvaziando o conjunto
print(cores)
cores.clear()
print(cores)

# Excluindo o conjunto
print(cores)
del cores
#print(cores) - Dá erro

# Iterando o conjunto
cores = {"vermelho", "azul", "verde", "amarelo"}
for cor in cores:
    print(cor)

# Unindo conjuntos
cores1 = {"vermelho", "azul", "verde"}
cores2 = {"laranja", "azul", "verde", "amarelo"}
cores = cores1.union(cores2)
print(cores)
