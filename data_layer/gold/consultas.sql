-- CONSULTAS SINISTROS PRF
-- Data Warehouse: Schema Gold (Gold Layer)

-- ================================================================================
-- 1. MONITORAMENTO MENSAL DE INDICADORES DE ACIDENTALIDADE E SEVERIDADE
--
-- O QUE ANALISA:
-- Consolida os principais KPIs de segurança viária (total de sinistros, veículos e pessoas)
-- segmentados por estado (UF) e mês. Detalha a severidade do acidente (feridos x óbitos).
--
-- VALOR DE NEGÓCIO:
-- Permite acompanhar a evolução histórica dos acidentes e identificar tendências de aumento
-- ou diminuição na gravidade das ocorrências. Essencial para medir a eficácia de políticas
-- públicas de segurança ao longo do tempo.

SELECT 
    TO_CHAR(t.dat_ocr, 'MM/YYYY') AS mes_ano,
    l.uni_fed AS uf,
    COUNT(DISTINCT f.cod_sin) AS total_sinistros,
    COUNT(DISTINCT f.srk_vei) AS total_veiculos,
    COUNT(DISTINCT f.srk_pes) AS total_envolvidos,
    COUNT(CASE WHEN p.est_fis = 'leve' THEN 1 END) AS total_feridos_leve,
    COUNT(CASE WHEN p.est_fis = 'grave' THEN 1 END) AS total_feridos_grave,
    COUNT(CASE WHEN p.est_fis = 'obito' THEN 1 END) AS total_mortos,
    COUNT(CASE WHEN p.est_fis = 'ileso' THEN 1 END) AS total_ilesos
FROM dw.fat_sin f
JOIN dw.dim_tem t ON f.srk_tem = t.srk_tem
JOIN dw.dim_loc l ON f.srk_loc = l.srk_loc
JOIN dw.dim_pes p ON f.srk_pes = p.srk_pes
GROUP BY 
    TO_CHAR(t.dat_ocr, 'MM/YYYY'),
    l.uni_fed
ORDER BY 
    RIGHT(TO_CHAR(t.dat_ocr, 'MM/YYYY'), 4), -- Ordenar por Ano
    LEFT(TO_CHAR(t.dat_ocr, 'MM/YYYY'), 2),  -- Ordenar por Mês
    l.uni_fed;


-- ================================================================================
-- 2. ANÁLISE DE RISCO POR PERÍODO DO DIA
--
-- O QUE ANALISA:
-- Agrega o volume de sinistros de acordo com a fase do dia (Amanhecer, Pleno Dia, Anoitecer, Plena Noite).
--
-- VALOR DE NEGÓCIO:
-- Ajuda a correlacionar a ocorrência de acidentes com fatores de visibilidade.
-- Permite planejar a escala de equipes de plantão para os turnos de maior incidência.

SELECT 
    t.fas_dia AS fase_dia,
    COUNT(DISTINCT f.cod_sin) AS total_sinistros
FROM dw.fat_sin f
JOIN dw.dim_tem t ON f.srk_tem = t.srk_tem
WHERE t.fas_dia IS NOT NULL
GROUP BY 
    t.fas_dia
ORDER BY 
    total_sinistros DESC;


-- ================================================================================
-- 3. IDENTIFICAÇÃO DE "HOTSPOTS" (PONTOS CRÍTICOS) REGIONAIS
--
-- O QUE ANALISA:
-- Classifica os municípios e delegacias regionais pelo volume absoluto de sinistros registrados.
--
-- VALOR DE NEGÓCIO:
-- Identifica as áreas geográficas que demandam atenção prioritária.
-- Suporta decisões de alocação de recursos financeiros e operacionais para as delegacias
-- que lidam com maior volume de ocorrências.

SELECT 
    l.uni_fed AS uf,
    l.nom_mun AS municipio,
    l.nom_del AS delegacia,
    COUNT(DISTINCT f.cod_sin) AS total_sinistros
FROM dw.fat_sin f
JOIN dw.dim_loc l ON f.srk_loc = l.srk_loc
GROUP BY 
    l.uni_fed, 
    l.nom_mun,
    l.nom_del
ORDER BY 
    total_sinistros DESC;


-- ================================================================================
-- 4. MAPEAMENTO GEOESPACIAL DE OCORRÊNCIAS
--
-- O QUE ANALISA:
-- Lista as coordenadas geográficas (latitude e longitude) exatas de onde os sinistros ocorreram.
--
-- VALOR DE NEGÓCIO:
-- Estes dados são insumos puros para ferramentas de visualização (como Power BI, Tableau ou QGIS)
-- para gerar Mapas de Calor (Heatmaps). Isso revela trechos específicos de rodovias com alta periculosidade
-- que não seriam visíveis apenas com nomes de municípios.

SELECT 
    l.num_lat AS latitude,
    l.num_lon AS longitude,
    COUNT(DISTINCT f.cod_sin) AS total_sinistros
FROM dw.fat_sin f
JOIN dw.dim_loc l ON f.srk_loc = l.srk_loc
WHERE l.num_lat IS NOT NULL 
  AND l.num_lon IS NOT NULL
GROUP BY 
    l.num_lat, 
    l.num_lon;


-- ================================================================================
-- 5. PERFIL DEMOGRÁFICO DAS VÍTIMAS E ENVOLVIDOS
--
-- O QUE ANALISA:
-- Traça o perfil dos envolvidos nos acidentes, segmentando por Gênero e Faixa Etária,
-- calculando tanto o volume absoluto quanto a representatividade percentual.
--
-- VALOR DE NEGÓCIO:
-- Essencial para o direcionamento de campanhas educativas. Ao saber quem são as maiores vítimas
-- (ex: homens jovens, idosos, etc.), a PRF pode calibrar a comunicação para atingir
-- o público-alvo com maior assertividade.

WITH total_geral AS (
    SELECT COUNT(*) AS total FROM dw.fat_sin
)
SELECT 
    p.gen AS genero,
    p.fax_eta AS faixa_etaria,
    COUNT(*) as total_pessoas,
    ROUND(COUNT(*) * 100.0 / (SELECT total FROM total_geral), 2) as percentual
FROM dw.fat_sin f
JOIN dw.dim_pes p ON f.srk_pes = p.srk_pes
WHERE p.gen IS NOT NULL 
  AND p.fax_eta IS NOT NULL
GROUP BY 
    p.gen, 
    p.fax_eta
ORDER BY 
    total_pessoas DESC;
