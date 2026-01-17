  -- ============================================================================
  -- SILVER LAYER: TABELA SINISTROS (PRF)
  -- Camada Silver - Dados limpos e validados (2024/2025)
  -- Grão: 1 linha = 1 pessoa envolvida em 1 sinistro
  -- ============================================================================

  -- Criação do schema silver (caso não exista)
  CREATE SCHEMA IF NOT EXISTS silver;

  -- Comentário no schema
  COMMENT ON SCHEMA silver IS 'Camada Silver - Dados limpos e validados (Sinistros PRF)';

  -- ============================================================================
  -- TABELA: SINISTROS
  -- ============================================================================
  DROP TABLE IF EXISTS silver.sinistros CASCADE;

  CREATE TABLE silver.sinistros (
      ano_arquivo SMALLINT NOT NULL CHECK (ano_arquivo IN (2024, 2025)),
      sinistro_id BIGINT NOT NULL,
      pessoa_id   BIGINT NOT NULL,
      veiculo_id  BIGINT,
      data_hora TIMESTAMP,
      dia_semana_num SMALLINT CHECK (dia_semana_num BETWEEN 0 AND 6),
      uf VARCHAR(2),
      municipio VARCHAR,
      delegacia VARCHAR,
      latitude  DOUBLE PRECISION CHECK (latitude BETWEEN -90 AND 90 OR latitude IS NULL),
      longitude DOUBLE PRECISION CHECK (longitude BETWEEN -180 AND 180 OR longitude IS NULL),
      causa_acidente VARCHAR,
      tipo_acidente VARCHAR,
      classificacao_acidente VARCHAR,
      fase_dia VARCHAR,
      sentido_via VARCHAR,
      condicao_meteorologica VARCHAR, 
      tipo_pista VARCHAR,
      tracado_via VARCHAR,
      caracteristicas_via VARCHAR,
      tipo_envolvido VARCHAR,
      estado_fisico VARCHAR,
      faixa_etaria_condutor VARCHAR,
      sexo_condutor VARCHAR CHECK (sexo_condutor IN ('masculino','feminino') OR sexo_condutor IS NULL),
      tipo_veiculo VARCHAR,
      faixa_idade_veiculo VARCHAR,

      created_at TIMESTAMP DEFAULT NOW(),

      PRIMARY KEY (sinistro_id, pessoa_id)
  );

  -- ============================================================================
  -- ÍNDICES PARA PERFORMANCE
  -- ============================================================================
  CREATE INDEX idx_sinistros_ano_arquivo   ON silver.sinistros(ano_arquivo);
  CREATE INDEX idx_sinistros_data_hora     ON silver.sinistros(data_hora);
  CREATE INDEX idx_sinistros_uf_municipio  ON silver.sinistros(uf, municipio);
  CREATE INDEX idx_sinistros_sinistro_id   ON silver.sinistros(sinistro_id);
  CREATE INDEX idx_sinistros_veiculo_id    ON silver.sinistros(veiculo_id);
  CREATE INDEX idx_sinistros_causa         ON silver.sinistros(causa_acidente);
  CREATE INDEX idx_sinistros_tipo          ON silver.sinistros(tipo_acidente);
  CREATE INDEX idx_sinistros_estado_fisico ON silver.sinistros(estado_fisico);

  -- ============================================================================
  -- COMENTÁRIOS (TABELA + COLUNAS)
  -- ============================================================================
  COMMENT ON TABLE silver.sinistros IS 'Sinistros PRF (2024/2025) tratados e normalizados - grão: pessoa envolvida no sinistro';

  COMMENT ON COLUMN silver.sinistros.ano_arquivo IS 'Ano de origem do arquivo carregado (2024 ou 2025)';

  COMMENT ON COLUMN silver.sinistros.sinistro_id IS 'ID do sinistro (acidente)';
  COMMENT ON COLUMN silver.sinistros.pessoa_id IS 'ID da pessoa envolvida (uma linha por pessoa no sinistro)';
  COMMENT ON COLUMN silver.sinistros.veiculo_id IS 'ID do veículo associado ao envolvido (pode ser NULL em alguns casos)';

  COMMENT ON COLUMN silver.sinistros.data_hora IS 'Data e hora completas do sinistro';
  COMMENT ON COLUMN silver.sinistros.dia_semana_num IS 'Dia da semana numérico (Seg=0 ... Dom=6)';

  COMMENT ON COLUMN silver.sinistros.uf IS 'UF do sinistro';
  COMMENT ON COLUMN silver.sinistros.municipio IS 'Município do sinistro';
  COMMENT ON COLUMN silver.sinistros.delegacia IS 'Delegacia responsável';
  COMMENT ON COLUMN silver.sinistros.latitude IS 'Latitude do sinistro';
  COMMENT ON COLUMN silver.sinistros.longitude IS 'Longitude do sinistro';

  COMMENT ON COLUMN silver.sinistros.causa_acidente IS 'Causa do acidente';
  COMMENT ON COLUMN silver.sinistros.tipo_acidente IS 'Tipo do acidente';
  COMMENT ON COLUMN silver.sinistros.classificacao_acidente IS 'Classificação do acidente';
  COMMENT ON COLUMN silver.sinistros.fase_dia IS 'Fase do dia';
  COMMENT ON COLUMN silver.sinistros.sentido_via IS 'Sentido da via';
  COMMENT ON COLUMN silver.sinistros.condicao_meteorologica IS 'Condição meteorológica (coluna original: condicao_metereologica)';
  COMMENT ON COLUMN silver.sinistros.tipo_pista IS 'Tipo de pista';
  COMMENT ON COLUMN silver.sinistros.tracado_via IS 'Traçado da via';

  COMMENT ON COLUMN silver.sinistros.caracteristicas_via IS 'Características/elementos da via (ex: Reta;Aclive, Curva, Ponte;Declive;Curva, Sim/Não)';

  COMMENT ON COLUMN silver.sinistros.tipo_envolvido IS 'Tipo de envolvido (condutor/passageiro/pedestre etc.)';
  COMMENT ON COLUMN silver.sinistros.estado_fisico IS 'Estado físico (Ileso/Leve/Grave/Óbito/Não Informado)';
  COMMENT ON COLUMN silver.sinistros.faixa_etaria_condutor IS 'Faixa etária derivada (bins)';
  COMMENT ON COLUMN silver.sinistros.sexo_condutor IS 'Sexo padronizado (masculino/feminino/NULL)';

  COMMENT ON COLUMN silver.sinistros.tipo_veiculo IS 'Tipo do veículo';
  COMMENT ON COLUMN silver.sinistros.faixa_idade_veiculo IS 'Faixa de idade do veículo derivada';

  COMMENT ON COLUMN silver.sinistros.created_at IS 'Timestamp de criação do registro no banco';

  -- ============================================================================
  -- VIEWS AUXILIARES (5 VIEWS)
  -- ============================================================================

  -- View Resumo por sinistro (1 linha = 1 sinistro)
  CREATE OR REPLACE VIEW silver.vw_sinistro_resumo AS
SELECT
  ano_arquivo,
  sinistro_id,

  MIN(data_hora) AS data_hora,
  MIN(dia_semana_num) AS dia_semana_num,

  MIN(uf) AS uf,
  MIN(municipio) AS municipio,
  MIN(delegacia) AS delegacia,
  MIN(latitude) AS latitude,
  MIN(longitude) AS longitude,

  MIN(causa_acidente) AS causa_acidente,
  MIN(tipo_acidente) AS tipo_acidente,
  MIN(classificacao_acidente) AS classificacao_acidente,
  MIN(fase_dia) AS fase_dia,
  MIN(sentido_via) AS sentido_via,
  MIN(condicao_meteorologica) AS condicao_meteorologica,
  MIN(tipo_pista) AS tipo_pista,
  MIN(tracado_via) AS tracado_via,
  MIN(caracteristicas_via) AS caracteristicas_via,

  COUNT(*) AS pessoas_envolvidas,
  COUNT(DISTINCT veiculo_id) AS veiculos_envolvidos,

  -- contagens por pessoa 
  COUNT(*) FILTER (WHERE estado_fisico = 'ileso') AS ilesos,
  COUNT(*) FILTER (WHERE estado_fisico = 'leve')  AS feridos_leves,
  COUNT(*) FILTER (WHERE estado_fisico = 'grave') AS feridos_graves,
  COUNT(*) FILTER (WHERE estado_fisico = 'obito') AS mortos,

    CASE
      WHEN COUNT(*) FILTER (WHERE estado_fisico = 'obito') > 0 THEN 'Com morto'
      WHEN COUNT(*) FILTER (WHERE estado_fisico = 'grave') > 0 THEN 'Com ferido grave'
      WHEN COUNT(*) FILTER (WHERE estado_fisico = 'leve')  > 0 THEN 'Com ferido leve'
      ELSE 'Sem vítima'
  END AS gravidade_sinistro

FROM silver.sinistros
GROUP BY ano_arquivo, sinistro_id;


  -- View Contagens por UF/Município/Mês
  CREATE OR REPLACE VIEW silver.vw_localidade_mes AS
  SELECT
    ano_arquivo,
    uf,
    municipio,
    DATE_TRUNC('month', data_hora)::date AS mes,
    COUNT(DISTINCT sinistro_id) AS sinistros,
    COUNT(*) AS pessoas_envolvidas
  FROM silver.sinistros
  WHERE data_hora IS NOT NULL
  GROUP BY ano_arquivo, uf, municipio, DATE_TRUNC('month', data_hora)::date;

  -- View Perfil das vítimas
  CREATE OR REPLACE VIEW silver.vw_vitimas_perfil AS
  SELECT
    ano_arquivo,
    faixa_etaria_condutor,
    sexo_condutor,
    estado_fisico,
    COUNT(*) AS total_pessoas,
    COUNT(DISTINCT sinistro_id) AS sinistros_distintos
  FROM silver.sinistros
  GROUP BY ano_arquivo, faixa_etaria_condutor, sexo_condutor, estado_fisico;

  -- View de acidente x gravidade
  CREATE OR REPLACE VIEW silver.vw_tipo_acidente_gravidade AS
  SELECT
    tipo_acidente,
    gravidade_sinistro,
    COUNT(*) AS total_sinistros
  FROM silver.vw_sinistro_resumo
  GROUP BY tipo_acidente, gravidade_sinistro;

  -- View Risco por condição meteorológica e fase do dia
  CREATE OR REPLACE VIEW silver.vw_contexto_risco AS
  SELECT
    ano_arquivo,
    condicao_meteorologica,
    fase_dia,
    COUNT(DISTINCT sinistro_id) AS sinistros,
    COUNT(*) AS pessoas_envolvidas
  FROM silver.sinistros
  GROUP BY ano_arquivo, condicao_meteorologica, fase_dia;

  -- ============================================================================
  -- FIM DO DDL
  -- ============================================================================
