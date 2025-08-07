# Básico
print("Curso de Engenharia")
print('Curso de Engenharia')

texto = "Curso de engenharia"
print(texto)

texto = """Textos
Multilinhas"""
print(texto)

texto = "Curso de Engenharia"
print(texto[1])

for x in texto:
    print(x)

print(len(texto))

# Slicing
texto = "Curso de Engenharia"
print(texto[2:7])
print(texto[:7])
print(texto[2:])

# Modificando strings
print(texto.upper())
print(texto.lower())
print(texto.strip())

# Formatando
qtd = 5
num_item = 197
preco = 93.25
pedido = "Quero pagar {2} reais por {0} peças do item {1}."
print(pedido.format(qtd, num_item, preco))

# Métodos de strings
