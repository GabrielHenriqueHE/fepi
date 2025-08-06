# Listas
numeros: list[int] = [1, 2, 3, 4, 5]
nomes: list[str] = ["João", "Maria", "José"]
misturado: list[object] = [1, "dois, True"]

# Tuplas
coordenadas: tuple[int, int] = (10, 20)

# Conjuntos
vogais: set[str] = {"a", "e", "i", "o", "u"}

# Dicionários
pessoa: dict[str, object] = {"nome": "João", "idade": 39, "profissão": "engenheiro"}
notas: dict[str, object] = {"matematica": 8.5, "portugues": 7.0, "historia": 9.5}

print(numeros)
print(misturado)
print(coordenadas)
print(vogais)
print(pessoa)

