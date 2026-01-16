# Dicionário de Dados - Acidentes de Trânsito PRF

O dataset analisado contém informações detalhadas sobre acidentes de trânsito registrados pela Polícia Rodoviária Federal (PRF) no Brasil. Apesar de ter como referência os dados do [Kaggle](https://www.kaggle.com/datasets/alinebertolani/federal-highway-accidents-dataset), o conjunto de dados utilizado neste projeto foi obtido diretamente do [portal oficial da PRF](https://www.gov.br/prf/pt-br/acesso-a-informacao/dados-abertos/dados-abertos-da-prf), garantindo maior autenticidade e atualização das informações, além de conseguir dados adicionais não presentes na versão do Kaggle.

 A seguir, apresenta-se o dicionário de variáveis que compõem o conjunto de dados, incluindo o nome da coluna, o tipo de dado e uma breve descrição.

## Dicionário de Dados - Tabela de Acidentes de Trânsito PRF

| Coluna | Descrição | Tipo |
|--------|-----------|------|
| data | Data do acidente no formato dd/mm/aaaa HH:mm | date |
| uf     | Unidade Federativa onde o acidente ocorreu (ex: MG, PE, DF) | varchar |
| municipio | Nome do município onde o acidente ocorreu | varchar |
| causa_acidente | Causa presumível do acidente baseada nos vestígios, indícios e provas colhidas | varchar |
| tipo_acidente | Tipo de acidente (ex: Colisão frontal, Saída de pista) | varchar |
| condicao_meteorologica | Condição meteorológica no momento do acidente (Céu claro, chuva, vento) | varchar |
| tipo_pista | Tipo da pista quanto à quantidade de faixas (Dupla, Simples, Múltipla) | varchar |
| tracado_via | Descrição do traçado da via | varchar |
| tipo_veiculo | Tipo do veículo (CTB, Art. 96) (Automóvel, Caminhão, Motocicleta) | varchar |
| ano_fabricacao_veiculo | Ano de fabricação do veículo | integer |
| idade_condutor | Idade do condutor do veículo | integer |
| sexo_condutor | Sexo do condutor do veículo (masculino, feminino, nao informado) | varchar |
| ilesos | Indica se o envolvido foi classificado como ileso (0/1) | integer |
| feridos_leves | Indica a quantidade de feridos leves no acidente | integer |
| feridos_graves | Indica a quantidade de feridos graves no acidente | integer |
| mortos | Indica a quantidade de mortos no acidente | integer |
| latitude | Latitude do local do acidente | float |
| longitude | Longitude do local do acidente | float |
| delegacia | Delegacia da PRF da circunscrição do acidente | varchar |
