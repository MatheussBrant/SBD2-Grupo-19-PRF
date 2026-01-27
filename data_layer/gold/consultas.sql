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
-- 5. PERFIL DEMOGRÁFICO E TAXA DE LETALIDADE POR GRUPO DE RISCO
--
-- O QUE ANALISA:
-- Identifica os grupos demográficos (gênero + faixa etária) mais vulneráveis em sinistros,
-- calculando a taxa de letalidade específica de cada grupo. Permite segmentar campanhas
-- preventivas para públicos com maior risco de óbito.
--
-- VALOR DE NEGÓCIO:
-- Direcionar campanhas educativas para perfis de maior vulnerabilidade (ex: homens jovens).
-- Calibrar mensagens de segurança para faixas etárias com maior letalidade. Subsidiar
-- políticas de habilitação (CNH) e renovação para grupos críticos. Fundamentar parcerias
-- com autoescolas e programas de conscientização em escolas.

WITH total_geral AS (
    SELECT COUNT(*) AS total FROM dw.fat_sin
),
analise_demografica AS (
    SELECT 
        p.gen AS genero,
        p.fax_eta AS faixa_etaria,
        p.est_fis AS estado_fisico,
        COUNT(*) as total_pessoas,
        ROUND(COUNT(*) * 100.0 / (SELECT total FROM total_geral), 2) as percentual_total
    FROM dw.fat_sin f
    JOIN dw.dim_pes p ON f.srk_pes = p.srk_pes
    WHERE p.gen IS NOT NULL 
      AND p.fax_eta IS NOT NULL
      AND p.est_fis IS NOT NULL
    GROUP BY 
        p.gen, 
        p.fax_eta,
        p.est_fis
)
SELECT 
    genero,
    faixa_etaria,
    SUM(CASE WHEN estado_fisico = 'obito' THEN total_pessoas ELSE 0 END) AS mortos,
    SUM(CASE WHEN estado_fisico = 'grave' THEN total_pessoas ELSE 0 END) AS feridos_graves,
    SUM(CASE WHEN estado_fisico = 'leve' THEN total_pessoas ELSE 0 END) AS feridos_leves,
    SUM(CASE WHEN estado_fisico = 'ileso' THEN total_pessoas ELSE 0 END) AS ilesos,
    SUM(total_pessoas) AS total_pessoas,
    ROUND(SUM(percentual_total), 2) AS percentual_total,
    -- ***TAXA DE LETALIDADE***: % de mortos dentro do grupo demográfico
    ROUND(SUM(CASE WHEN estado_fisico = 'obito' THEN total_pessoas ELSE 0 END) * 100.0 / 
          NULLIF(SUM(total_pessoas), 0), 2) AS taxa_letalidade_grupo
FROM analise_demografica
GROUP BY 
    genero, 
    faixa_etaria
ORDER BY 
    taxa_letalidade_grupo DESC, 
    total_pessoas DESC;


-- ================================================================================
-- 6. TAXA DE LETALIDADE POR TIPO DE ACIDENTE
--
-- O QUE ANALISA:
-- Calcula a taxa de letalidade (% de óbitos sobre total de envolvidos) e o índice de
-- gravidade para cada tipo de acidente. Identifica quais tipos são mais letais, não
-- apenas mais frequentes.
--
-- VALOR DE NEGÓCIO:
-- Priorizar fiscalização em trechos com histórico dos tipos mais letais. Dimensionar
-- equipes de resgate para acidentes de alta gravidade. Criar campanhas específicas
-- (ex: "Ultrapassagem segura" para colisões frontais). Fundamentar melhorias de
-- engenharia viária (duplicação de pistas simples).

SELECT 
    c.tip_aci AS tipo_acidente,
    COUNT(DISTINCT f.cod_sin) AS total_sinistros,
    COUNT(DISTINCT f.srk_pes) AS total_envolvidos,
    SUM(CASE WHEN p.est_fis = 'obito' THEN 1 ELSE 0 END) AS total_mortos,
    SUM(CASE WHEN p.est_fis = 'grave' THEN 1 ELSE 0 END) AS total_feridos_graves,
    SUM(CASE WHEN p.est_fis IN ('obito', 'grave') THEN 1 ELSE 0 END) AS total_vitimas_criticas,
    -- ***TAXA DE LETALIDADE***: % de mortos sobre total de envolvidos nesse tipo
    ROUND(SUM(CASE WHEN p.est_fis = 'obito' THEN 1 ELSE 0 END) * 100.0 / 
          NULLIF(COUNT(DISTINCT f.srk_pes), 0), 2) AS taxa_letalidade_pct,
    -- ***ÍNDICE DE GRAVIDADE***: Pontuação ponderada (Óbito=10, Grave=5, Leve=1)
    ROUND((SUM(CASE WHEN p.est_fis = 'obito' THEN 10 
                   WHEN p.est_fis = 'grave' THEN 5 
                   WHEN p.est_fis = 'leve' THEN 1 
                   ELSE 0 END) * 1.0) / NULLIF(COUNT(DISTINCT f.cod_sin), 0), 2) AS indice_gravidade_media
FROM dw.fat_sin f
JOIN dw.dim_cir c ON f.srk_cir = c.srk_cir
JOIN dw.dim_pes p ON f.srk_pes = p.srk_pes
WHERE c.tip_aci IS NOT NULL
GROUP BY 
    c.tip_aci
HAVING COUNT(DISTINCT f.cod_sin) >= 100  -- Filtro mínimo para significância estatística
ORDER BY 
    taxa_letalidade_pct DESC,
    total_sinistros DESC
LIMIT 15;


-- ================================================================================
-- 7. PONTOS CRÍTICOS COM REINCIDÊNCIA DE SINISTROS (BLACKSPOTS)
--
-- O QUE ANALISA:
-- Identifica coordenadas geográficas exatas (latitude/longitude) onde ocorreram múltiplos
-- sinistros no mesmo ponto. Lista os 30 pontos mais críticos com índice de criticidade
-- ponderado por sinistros, mortos e feridos graves.
--
-- VALOR DE NEGÓCIO:
-- Subsidiar projetos de engenharia viária (correção de curvas, sinalização, iluminação).
-- Priorizar alocação de orçamento para intervenções em pontos com maior reincidência.
-- Fundamentar convênios com DNIT para obras em trechos federais críticos. Instalar
-- radares fixos em locais com histórico comprovado de reincidência.

WITH pontos_criticos AS (
    SELECT 
        l.num_lat AS latitude,
        l.num_lon AS longitude,
        l.uni_fed AS uf,
        l.nom_mun AS municipio,
        COUNT(DISTINCT f.cod_sin) AS total_sinistros,
        SUM(CASE WHEN p.est_fis = 'obito' THEN 1 ELSE 0 END) AS total_mortos,
        SUM(CASE WHEN p.est_fis = 'grave' THEN 1 ELSE 0 END) AS total_feridos_graves,
        -- Lista os 3 tipos de acidente mais comuns nesse ponto
        STRING_AGG(DISTINCT c.tip_aci, ', ') AS tipos_acidentes_recorrentes
    FROM dw.fat_sin f
    JOIN dw.dim_loc l ON f.srk_loc = l.srk_loc
    JOIN dw.dim_pes p ON f.srk_pes = p.srk_pes
    JOIN dw.dim_cir c ON f.srk_cir = c.srk_cir
    WHERE l.num_lat IS NOT NULL 
      AND l.num_lon IS NOT NULL
    GROUP BY 
        l.num_lat, 
        l.num_lon,
        l.uni_fed,
        l.nom_mun
    HAVING COUNT(DISTINCT f.cod_sin) >= 5  -- REINCIDÊNCIA: Mínimo 5 acidentes no mesmo ponto
)
SELECT 
    uf,
    municipio,
    latitude,
    longitude,
    total_sinistros,
    total_mortos,
    total_feridos_graves,
    tipos_acidentes_recorrentes,
    -- ***ÍNDICE DE CRITICIDADE***: Fórmula ponderada (Sinistros + 10*Mortos + 5*Graves)
    (total_sinistros + (10 * total_mortos) + (5 * total_feridos_graves)) AS indice_criticidade
FROM pontos_criticos
ORDER BY 
    indice_criticidade DESC,
    total_sinistros DESC
LIMIT 30;


-- ================================================================================
-- 8. ANÁLISE DE LETALIDADE POR FASE DO DIA
--
-- O QUE ANALISA:
-- Calcula a taxa de letalidade e índice de periculosidade para cada fase do dia
-- (Amanhecer, Pleno Dia, Anoitecer, Plena Noite). Identifica períodos em que os
-- acidentes são mais graves, correlacionando com condições de visibilidade.
--
-- VALOR DE NEGÓCIO:
-- Intensificar fiscalização em períodos de maior letalidade (especialmente noturno).
-- Planejar operações específicas para fases críticas. Ajustar escala de equipes de
-- resgate para períodos de acidentes mais graves. Fundamentar campanhas sobre riscos
-- da direção noturna e condições de baixa visibilidade.

WITH analise_fase_dia AS (
    SELECT 
        t.fas_dia AS fase_dia,
        COUNT(DISTINCT f.cod_sin) AS total_sinistros,
        COUNT(DISTINCT f.srk_pes) AS total_envolvidos,
        SUM(CASE WHEN p.est_fis = 'obito' THEN 1 ELSE 0 END) AS total_mortos,
        SUM(CASE WHEN p.est_fis = 'grave' THEN 1 ELSE 0 END) AS total_feridos_graves
    FROM dw.fat_sin f
    JOIN dw.dim_tem t ON f.srk_tem = t.srk_tem
    JOIN dw.dim_pes p ON f.srk_pes = p.srk_pes
    WHERE t.fas_dia IS NOT NULL
    GROUP BY 
        t.fas_dia
)
SELECT 
    fase_dia,
    total_sinistros,
    total_envolvidos,
    total_mortos,
    total_feridos_graves,
    -- ***TAXA DE LETALIDADE POR FASE***: % de mortos sobre envolvidos
    ROUND(total_mortos * 100.0 / NULLIF(total_envolvidos, 0), 2) AS taxa_letalidade_pct,
    -- ***ÍNDICE DE PERICULOSIDADE***: Sinistros * (1 + Taxa de Letalidade/10)
    ROUND(total_sinistros * (1 + (total_mortos * 100.0 / NULLIF(total_envolvidos, 0)) / 10), 2) AS indice_periculosidade,
    -- Classificação de risco
    CASE 
        WHEN ROUND(total_mortos * 100.0 / NULLIF(total_envolvidos, 0), 2) >= 8 THEN '🔴 ALTO RISCO'
        WHEN ROUND(total_mortos * 100.0 / NULLIF(total_envolvidos, 0), 2) >= 5 THEN '🟡 RISCO MODERADO'
        ELSE '🟢 RISCO BAIXO'
    END AS classificacao_risco
FROM analise_fase_dia
ORDER BY 
    taxa_letalidade_pct DESC;


-- ================================================================================
-- 9. COMPARATIVO DE LETALIDADE: FIM DE SEMANA vs DIAS ÚTEIS
--
-- O QUE ANALISA:
-- Compara a incidência e gravidade de sinistros entre dias úteis (segunda a sexta-feira)
-- e finais de semana (sábado e domingo). Calcula taxa de letalidade, taxa de vítimas
-- críticas e média de envolvidos por sinistro em cada período.
--
-- VALOR DE NEGÓCIO:
-- Reforçar policiamento em rodovias de lazer nos finais de semana. Intensificar operações
-- "Lei Seca" em sextas e sábados à noite. Criar operações sazonais para feriados prolongados
-- (Carnaval, Ano Novo). Ajustar dimensionamento de equipes para períodos de maior gravidade.
-- Campanhas "Viaje Seguro" antes de feriados prolongados.

WITH analise_periodo AS (
    SELECT 
        CASE 
            WHEN t.dia_sem_num IN (0, 6) THEN 'FIM DE SEMANA'  -- Domingo=0, Sábado=6
            ELSE 'DIA ÚTIL'
        END AS tipo_periodo,
        COUNT(DISTINCT f.cod_sin) AS total_sinistros,
        COUNT(DISTINCT f.srk_pes) AS total_envolvidos,
        SUM(CASE WHEN p.est_fis = 'obito' THEN 1 ELSE 0 END) AS total_mortos,
        SUM(CASE WHEN p.est_fis = 'grave' THEN 1 ELSE 0 END) AS total_feridos_graves,
        SUM(CASE WHEN p.est_fis IN ('obito', 'grave') THEN 1 ELSE 0 END) AS total_vitimas_criticas
    FROM dw.fat_sin f
    JOIN dw.dim_tem t ON f.srk_tem = t.srk_tem
    JOIN dw.dim_pes p ON f.srk_pes = p.srk_pes
    WHERE t.dia_sem_num IS NOT NULL
    GROUP BY 
        CASE 
            WHEN t.dia_sem_num IN (0, 6) THEN 'FIM DE SEMANA'
            ELSE 'DIA ÚTIL'
        END
)
SELECT 
    tipo_periodo,
    total_sinistros,
    total_envolvidos,
    total_mortos,
    total_feridos_graves,
    total_vitimas_criticas,
    -- ***TAXA DE LETALIDADE***: % mortos / envolvidos
    ROUND(total_mortos * 100.0 / NULLIF(total_envolvidos, 0), 2) AS taxa_letalidade_pct,
    -- ***TAXA DE VÍTIMAS CRÍTICAS***: % (mortos + graves) / envolvidos
    ROUND(total_vitimas_criticas * 100.0 / NULLIF(total_envolvidos, 0), 2) AS taxa_vitimas_criticas_pct,
    -- ***MÉDIA DE VÍTIMAS POR SINISTRO***: Envolvidos / Sinistros
    ROUND(total_envolvidos * 1.0 / NULLIF(total_sinistros, 0), 2) AS media_envolvidos_por_sinistro
FROM analise_periodo
ORDER BY 
    tipo_periodo DESC;


-- ================================================================================
-- 10. ANÁLISE DE GRAVIDADE POR CATEGORIA DE VEÍCULO
--
-- O QUE ANALISA:
-- Compara a participação e gravidade de sinistros envolvendo diferentes categorias de
-- veículos (Carga, Leves, Transporte Coletivo, Outros). Calcula o Índice de Desproporcionalidade,
-- que revela se uma categoria mata mais ou menos do que sua participação em sinistros.
--
-- VALOR DE NEGÓCIO:
-- Fundamentar legislação específica para transporte de carga (horas de descanso obrigatório).
-- Intensificar fiscalização de caminhões (condições mecânicas, freios, pneus, carga excedida).
-- Criar faixas exclusivas para caminhões em rodovias críticas. Implementar tacógrafos
-- obrigatórios para controle de jornada. Justificar investimento em balanças rodoviárias.

WITH classificacao_veiculos AS (
    SELECT 
        CASE 
            WHEN v.tip_vei IN ('Caminhão', 'Caminhão-trator', 'Caminhonete', 'Caminhoneta') 
                THEN 'VEÍCULOS DE CARGA'
            WHEN v.tip_vei IN ('Automóvel', 'Motocicleta', 'Motoneta', 'Ciclomotor')
                THEN 'VEÍCULOS LEVES'
            WHEN v.tip_vei IN ('Ônibus', 'Micro-ônibus')
                THEN 'TRANSPORTE COLETIVO'
            ELSE 'OUTROS'
        END AS categoria_veiculo,
        f.cod_sin,
        f.srk_pes,
        p.est_fis
    FROM dw.fat_sin f
    JOIN dw.dim_vei v ON f.srk_vei = v.srk_vei
    JOIN dw.dim_pes p ON f.srk_pes = p.srk_pes
    WHERE v.tip_vei IS NOT NULL
)
SELECT 
    categoria_veiculo,
    COUNT(DISTINCT cod_sin) AS total_sinistros,
    COUNT(DISTINCT srk_pes) AS total_envolvidos,
    SUM(CASE WHEN est_fis = 'obito' THEN 1 ELSE 0 END) AS total_mortos,
    SUM(CASE WHEN est_fis = 'grave' THEN 1 ELSE 0 END) AS total_feridos_graves,
    -- ***TAXA DE LETALIDADE POR CATEGORIA***: % mortos / envolvidos
    ROUND(SUM(CASE WHEN est_fis = 'obito' THEN 1 ELSE 0 END) * 100.0 / 
          NULLIF(COUNT(DISTINCT srk_pes), 0), 2) AS taxa_letalidade_pct,
    -- ***PERCENTUAL DE PARTICIPAÇÃO EM SINISTROS***: % sinistros dessa categoria / total
    ROUND(COUNT(DISTINCT cod_sin) * 100.0 / 
          SUM(COUNT(DISTINCT cod_sin)) OVER (), 2) AS percentual_sinistros,
    -- ***PERCENTUAL DE PARTICIPAÇÃO EM ÓBITOS***: % mortes dessa categoria / total de mortes
    ROUND(SUM(CASE WHEN est_fis = 'obito' THEN 1 ELSE 0 END) * 100.0 / 
          SUM(SUM(CASE WHEN est_fis = 'obito' THEN 1 ELSE 0 END)) OVER (), 2) AS percentual_obitos,
    -- ***ÍNDICE DE DESPROPORCIONALIDADE***: Razão entre % óbitos e % sinistros
    -- Se > 1: Categoria mata MAIS do que sua participação em sinistros (ex: caminhões)
    -- Se < 1: Categoria mata MENOS do que sua participação (ex: motos em colisões traseiras leves)
    ROUND(
        (SUM(CASE WHEN est_fis = 'obito' THEN 1 ELSE 0 END) * 100.0 / 
         SUM(SUM(CASE WHEN est_fis = 'obito' THEN 1 ELSE 0 END)) OVER ()) /
        NULLIF((COUNT(DISTINCT cod_sin) * 100.0 / 
                SUM(COUNT(DISTINCT cod_sin)) OVER ()), 0)
    , 2) AS indice_desproporcionalidade
FROM classificacao_veiculos
GROUP BY 
    categoria_veiculo
ORDER BY 
    indice_desproporcionalidade DESC,
    total_mortos DESC;
