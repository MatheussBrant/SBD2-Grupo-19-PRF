CREATE SCHEMA IF NOT EXISTS dw;

-- DIMENSÃO TEMPO
DROP TABLE IF EXISTS dw.dim_tem CASCADE;
CREATE TABLE dw.dim_tem (
    srk_tem SERIAL PRIMARY KEY,
    dat_ocr DATE NOT NULL,
    ano_arq INT,
    dia_sem_num INT,
    fas_dia VARCHAR(50)
);

-- DIMENSÃO LOCALIDADE
DROP TABLE IF EXISTS dw.dim_loc CASCADE;
CREATE TABLE dw.dim_loc (
    srk_loc SERIAL PRIMARY KEY,
    uni_fed VARCHAR(2),
    nom_mun VARCHAR(255),
    nom_del VARCHAR(255),
    num_lat DOUBLE PRECISION,
    num_lon DOUBLE PRECISION
);

-- DIMENSÃO CIRCUNSTÂNCIA
DROP TABLE IF EXISTS dw.dim_cir CASCADE;
CREATE TABLE dw.dim_cir (
    srk_cir SERIAL PRIMARY KEY,
    cau_aci VARCHAR(255),
    tip_aci VARCHAR(255),
    sen_via VARCHAR(100),
    con_met VARCHAR(100),
    tip_pis VARCHAR(100),
    tra_via VARCHAR(100),
    car_via VARCHAR(100)
);

-- DIMENSÃO PESSOA
DROP TABLE IF EXISTS dw.dim_pes CASCADE;
CREATE TABLE dw.dim_pes (
    srk_pes SERIAL PRIMARY KEY,
    cod_pes VARCHAR(50),
    tip_env VARCHAR(100),
    est_fis VARCHAR(100),
    fax_eta VARCHAR(100),
    gen     VARCHAR(50)
);

-- DIMENSÃO VEÍCULO
DROP TABLE IF EXISTS dw.dim_vei CASCADE;
CREATE TABLE dw.dim_vei (
    srk_vei SERIAL PRIMARY KEY,
    cod_vei VARCHAR(50),
    tip_vei VARCHAR(100),
    fax_ida VARCHAR(100)
);

-- TABELA FATO SINISTROS
DROP TABLE IF EXISTS dw.fat_sin CASCADE;
CREATE TABLE dw.fat_sin (
    srk_fat SERIAL PRIMARY KEY,
    srk_tem INT NOT NULL REFERENCES dw.dim_tem (srk_tem),
    srk_loc INT NOT NULL REFERENCES dw.dim_loc (srk_loc),
    srk_cir INT NOT NULL REFERENCES dw.dim_cir (srk_cir),
    srk_pes INT NOT NULL REFERENCES dw.dim_pes (srk_pes),
    srk_vei INT REFERENCES dw.dim_vei (srk_vei),
    cod_sin VARCHAR(50) NOT NULL
);
