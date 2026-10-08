extends Node

# Guarda o saldo de moedas do jogador. Como é um Autoload, qualquer script
# acessa direto por "Economia", sem precisar de referência ao nó.

signal moedas_mudaram(total: int)   # avisa a interface quando o saldo muda

var moedas: int = 100   # saldo inicial


# Soma moedas ao saldo (chamada quando um inimigo morre).
func ganhar(qtd: int) -> void:
	moedas += qtd
	moedas_mudaram.emit(moedas)


# Desconta moedas se houver saldo. Devolve true se conseguiu pagar.
func gastar(qtd: int) -> bool:
	if moedas < qtd:
		return false
	moedas -= qtd
	moedas_mudaram.emit(moedas)
	return true
