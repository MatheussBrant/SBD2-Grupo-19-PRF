# Dicionário de Dados - Acidentes de Trânsito PRF

O dataset analisado contém informações detalhadas sobre acidentes de trânsito registrados pela Polícia Rodoviária Federal (PRF) no Brasil. Apesar de ter como referência os dados do [Kaggle](https://www.kaggle.com/datasets/alinebertolani/federal-highway-accidents-dataset), o conjunto de dados utilizado neste projeto foi obtido diretamente do [portal oficial da PRF](https://www.gov.br/prf/pt-br/acesso-a-informacao/dados-abertos/dados-abertos-da-prf), garantindo maior autenticidade e atualização das informações, além de conseguir dados adicionais não presentes na versão do Kaggle.

 A seguir, apresenta-se o dicionário de variáveis que compõem o conjunto de dados, incluindo o nome da coluna, o tipo de dado e uma breve descrição.

## Dicionário de Dados - Tabela de Acidentes de Trânsito PRF

| Coluna | Descrição | Tipo |
|--------|-----------|------|
| id     | Identificador único do acidente | integer |
| pesid  | Identificador único da pessoa envolvida no acidente | integer |
| data_inversa | Data do acidente no formato dd/mm/aaaa | varchar |
| dia_semana | Dia da semana em que o acidente ocorreu | varchar |
| horario | Horário do acidente no formato hh:mm:ss | varchar |
| uf     | Unidade Federativa onde o acidente ocorreu (ex: MG, PE, DF) | varchar |
| br     | Número da BR onde o acidente ocorreu | integer |
| km     | Quilômetro da BR onde o acidente ocorreu | float |
| municipio | Nome do município onde o acidente ocorreu | varchar |
| causa_acidente | Causa presumível do acidente baseada nos vestígios, indícios e provas colhidas | varchar |
| tipo_acidente | Tipo de acidente (ex: Colisão frontal, Saída de pista) | varchar |
| classificacao_acidente | Classificação do acidente (Sem Vítimas, Com Vítimas Feridas, Com Vítimas Fatais, Ignorado) | varchar |
| fase_dia | Fase do dia em que o acidente ocorreu (ex: Amanhecer, Pleno dia) | varchar |
| sentido_via | Sentido da via considerando o ponto de colisão (Crescente, Decrescente) | varchar |
| condicao_meteorologica | Condição meteorológica no momento do acidente (Céu claro, chuva, vento) | varchar |
| tipo_pista | Tipo da pista quanto à quantidade de faixas (Dupla, Simples, Múltipla) | varchar |
| tracado_via | Descrição do traçado da via | varchar |
| uso_solo | Característica do local (Urbano=Sim; Rural=Não) | varchar |
| id_veiculo | Identificador único do veículo envolvido no acidente | integer |
| tipo_veiculo | Tipo do veículo (CTB, Art. 96) (Automóvel, Caminhão, Motocicleta) | varchar |
| marca | Marca do veículo | varchar |
| ano_fabricacao_veiculo | Ano de fabricação do veículo | integer |
| tipo_envolvido | Tipo de envolvido (condutor, passageiro, pedestre, etc.) | varchar |
| estado_fisico | Condição do envolvido (morto, ferido leve, etc.) | varchar |
| idade | Idade do envolvido | integer |
| sexo | Sexo do envolvido (masculino, feminino, nao informado) | varchar |
| ilesos | Indica se o envolvido foi classificado como ileso (0/1) | integer |
| feridos_leves | Indica se o envolvido foi classificado como ferido leve (0/1) | integer |
| feridos_graves | Indica se o envolvido foi classificado como ferido grave (0/1) | integer |
| mortos | Indica se o envolvido foi classificado como morto (0/1) | integer |
| latitude | Latitude do local do acidente | float |
| longitude | Longitude do local do acidente | float |
| regional | Superintendência regional da PRF da circunscrição do acidente | varchar |
| delegacia | Delegacia da PRF da circunscrição do acidente | varchar |
| uop    | Unidade Operacional (UOP) da PRF da circunscrição do acidente | varchar |
