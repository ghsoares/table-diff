### Ferramenta para comparação de tabelas

Essa ferramenta foi criada para facilitar a comparação de diferença de tabelas entre ambientes.

## Instalação

A máquina de execução precisa ter o NodeJS instalado, pode ser instalado pelo link https://nodejs.org/en/download/current

Após ter extraído a ferramenta, execute `npm install` no terminal na pasta raíz desta ferramenta.

## Configuração

Para comparação de tabelas de estruturas entre PFS e TC2 (envio de tabelas para PFS), insira os arquivos de PFS na pasta "input/PFS/structure" e os arquivos de TC2 na pasta "input/TC2/structure".

## Execução

Para executar a ferramenta, execute o comando `npm run start` no terminal e siga as instruções no terminal.

Os resultados estarão na pasta "output".

## Configuração Customizada

A ferramenta foi criada para comparação de tabelas de estruturas, mas é possível usar uma configuração customizada:

Crie um arquivo .json para a configuração, use como template o seguinte conteúdo:

```json
[
	{
		"name": "Comparação de Tabela Teste ",
		"beforeFile": "before/test/ATR_Test.csv",
		"afterFile": "after/test/ATR_Test.csv",
		"outputFile": "output/test/ATR_Test",
		"beforeEnvironment": "PFS",
		"afterEnvironment": "TC2",
		"keys": ["LINE_ID"]
	}
]
````



Note que é possível fazer a comparação de mais de uma tabela, cada uma sendo um objeto de um array do arquivo de configuração:

```json
[
	{
		"name": "Comparação de Tabela Teste 1",
		"beforeFile": "before/test/ATR_Test1.csv",
		"afterFile": "after/test/ATR_Test1.csv",
		"outputFile": "output/test/ATR_Test1",
		"beforeEnvironment": "PFS",
		"afterEnvironment": "TC2",
		"keys": ["LINE_ID"]
	},
	{
		"name": "Comparação de Tabela Teste 2",
		"beforeFile": "before/test/ATR_Test2.csv",
		"afterFile": "after/test/ATR_Test2.csv",
		"outputFile": "output/test/ATR_Test2",
		"beforeEnvironment": "PFS",
		"afterEnvironment": "TC2",
		"keys": ["LINE_ID"]
	}
]
````

A lista atual de todas as propriedades configuráveis são:

- `disabled`: Usado para ignorar essa configuração;
- `name`: O nome da execução da comparação, usada para mostrar no terminal qual comparação está sendo executada no momento;
- `beforeFile`: Caminho relativo á pasta de execução para o arquivo com os dados da tabela anteriormente (geralmente dados de PFS);
- `afterFile`: Caminho relativo á pasta de execução para o arquivo com os dados da tabela atualmente (geralmente dados de TC2);
- `outputFile`: Caminho relativo á pasta de execução, para o arquivo de saída com os dados gravados (.xlsl);
- `beforeEnvironment`: Usado para identificar qual ambiente possui dados anteriores (para descrição apenas);
- `afterEnvironment`: Usado para identificar qual ambiente possui dados novos (para descrição apenas);
- `keys`: Colunas usadas como chaves para a comparação, pode usar mais de uma para chaves compostas;
- `compareColumns`: Colunas que serão usadas na comparação e que serão mostrados no resultado, deixe sem ou vazio para comparar todas as colunas;
- `ignoreColumns`: Colunas que não serão usadas na comparação, mas ainda serão mostrados no resultado, deixe sem ou vazio para comparar todas as colunas;