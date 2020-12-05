# API Palavras Dicionario PT-BR

## Esta api tem o objetivo de fornecer palavras aleatorias do dicionário pt-br.

**Exemplo** Palavras aleatórias começando com qualquer letra.

[http://papalavras-server.herokuapp.com/words/random/](http://papalavras-server.herokuapp.com/words/random/)

> Resultado: 
```
{
  "word":"Biquadrado",
  "id":36597,
  "count":10,
  "character":"B"
}

```


**Exemplo** Palavras aleatórias começando com uma letra desejada.

[http://papalavras-server.herokuapp.com/words/random/A](http://papalavras-server.herokuapp.com/words/random/A)

> Resultado: 
```
{
  "word":"Árvores",
  "id":24721,
  "count":7,
  "character":"A"
 }
 
```

**Exemplo** Verifique se uma palavra realmente existe no dicionário.

[http://papalavras-server.herokuapp.com/words/verify/Buscar](http://papalavras-server.herokuapp.com/words/verify/Buscar)

> Resultado:
```
{
  "word":"Buscar",
  "id":41918,
  "count":6,
  "character":"B"
 }
```

## Quer contribuir?

Caso queira contribuir basta abrir uma issue informando a melhoria ou abrir um pr :D

Dê ⭐️ neste repositório para que mais pessoas possam ver o/

