from calculadora import Calculadora
from pytest import mark

@mark.skip
def test_somar():
    assert Calculadora.somar(10, 20) == 30

def test_subtrair():
    assert Calculadora.subtrair(10, 20) == -10

def test_multiplicar():
    assert Calculadora.multiplicar(10, 20) == 200

def test_dividir():
    assert Calculadora.dividir(10, 20) == 0.5