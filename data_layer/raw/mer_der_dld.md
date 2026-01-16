# Modelagem de Dados - Acidentes em Rodovias Federais (2014–2024)

Este documento apresenta a modelagem de dados para o dataset de acidentes de trânsito em rodovias federais brasileiras. Os dados são provenientes do portal de Dados Abertos da **Polícia Rodoviária Federal (PRF)**.

O objetivo desta modelagem é consolidar uma base limpa para Análise Exploratória de Dados, focando em causas, tipos de acidentes e distribuição geográfica no período de 2014 a 2024.

---

## 1. Modelo Entidade-Relacionamento (ME-R)

O Modelo Entidade-Relacionamento (ME-R) descreve a estrutura conceitual do domínio. No nosso trabalho é utilizado uma estrutura de tabela única para facilitar o consumo analítico.

### 1.1 Entidades
- **TB_ACIDENTES**: Única entidade que agrega dados do acidente, do veículo e do condutor envolvido.

### 1.2 Atributos
Abaixo, a representação textual da entidade e seus atributos:
`TB_ACIDENTES(id, data, uf, municipio, causa_acidente, tipo_acidente, condicao_meteorologica, tipo_pista, tracado_via, tipo_veiculo, ano_fabricacao_veiculo, idade, sexo, ilesos, feridos_leves, feridos_graves, mortos, latitude, longitude, delegacia)`.

### 1.3 Relacionamentos
- **Não possui**: Devido à estratégia de desnormalização para análise de dados, a entidade não possui relacionamentos externos nesta camada.

---

## 2. Diagrama Lógico de Dados (DLD)

O DLD detalha a implementação lógica da tabela, definindo os tipos de dados e restrições.


| Coluna | Descrição | Tipo de Dado |
| :--- | :--- | :--- |
| **id** | Identificador único do acidente (PK) | INTEGER |
| **data** | Concatenação de `data_inversa` e `horario` | DATETIME |
| **uf** | Unidade Federativa da ocorrência | VARCHAR |
| **municipio** | Nome do município do acidente | VARCHAR |
| **causa_acidente** | Causa presumível do acidente | VARCHAR |
| **tipo_acidente** | Tipo da ocorrência (ex: Colisão frontal) | VARCHAR |
| **condicao_meteorologica** | Condição do tempo no momento | VARCHAR |
| **tipo_pista** | Quantidade de faixas da via | VARCHAR |
| **tracado_via** | Descrição do traçado (Reta, Curva, etc) | VARCHAR |
| **tipo_veiculo** | Tipo do veículo envolvido | VARCHAR |
| **ano_fabricacao_veiculo**| Ano de fabricação do veículo | INTEGER |
| **idade** | Idade do condutor | INTEGER |
| **sexo** | Sexo do condutor | VARCHAR |
| **ilesos** | Quantidade de pessoas ilesas | INTEGER |
| **feridos_leves** | Quantidade de feridos leves | INTEGER |
| **feridos_graves** | Quantidade de feridos graves | INTEGER |
| **mortos** | Quantidade de óbitos | INTEGER |
| **latitude** | Coordenada geográfica (Latitude) | DOUBLE |
| **longitude** | Coordenada geográfica (Longitude) | DOUBLE |
| **delegacia** | Delegacia da PRF responsável | VARCHAR |
