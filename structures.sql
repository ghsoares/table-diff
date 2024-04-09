-- Para comparação das tabelas de grupos de estruturas

SELECT
    "ID" AS "STRUCTURE_GROUP_ID", 
    "TITLE" AS "STRUCTURE_GROUP_NAME"
FROM "AP_TIMP"."ATR::StructureGroup"
ORDER BY "ID";

SELECT
    "GROUP"."STRUCTURE_GROUP_ID", 
    "STRUCT_GROUP"."TITLE" AS "STRUCTURE_GROUP_NAME",
    "GROUP"."STRUCTURE_ID", 
    "STRUCT"."title" AS "STRUCTURE_NAME"
FROM "AP_TIMP"."ATR::StructureGroupXStructure" AS "GROUP"
INNER JOIN "AP_TIMP"."ATR::StructureGroup" AS "STRUCT_GROUP" ON
    "STRUCT_GROUP"."ID" = "GROUP"."STRUCTURE_GROUP_ID"
INNER JOIN "AP_TIMP"."ATR::Structure" AS "STRUCT" ON
    "STRUCT"."ID" = "GROUP"."STRUCTURE_ID"
ORDER BY "GROUP"."STRUCTURE_GROUP_ID", "GROUP"."STRUCTURE_ID";

-- Para comparação das tabelas de mapeamentos de groupos de estruturas

SELECT
    "MAPPING"."ID" AS "MAPPING_ID", 
    "MAPPING"."STRUCTURE_ID", 
    "STRUCT"."title" AS "STRUCTURE_NAME", 
    "MAPPING"."EMPRESA", 
    "MAPPING"."UF_FILIAL", 
    "MAPPING"."FILIAL", 
    "MAPPING"."DATA", 
    "MAPPING"."DATA2",
    "MAPPING"."MAPPING", 
    "MAPPING"."UF_ST", 
    "MAPPING"."DATE_FORMAT",
    "MAPPING"."CREATION.ID_USER",
    "MAPPING"."MODIFICATION.ID_USER",
    "CREATION.USER"."HANA_USER" AS "CREATION_USER",
    "MODIFICATION.USER"."HANA_USER" AS "MODIFICATION_USER",
    "MAPPING"."CREATION.DATE",
    "MAPPING"."MODIFICATION.DATE"
FROM "AP_TIMP"."ATR::StructureFieldMapping" AS "MAPPING"
LEFT OUTER JOIN "AP_TIMP"."CORE::USER" AS "CREATION.USER" ON
    "CREATION.USER"."ID" = "MAPPING"."CREATION.ID_USER"
LEFT OUTER JOIN "AP_TIMP"."CORE::USER" AS "MODIFICATION.USER" ON
    "MODIFICATION.USER"."ID" = "MAPPING"."MODIFICATION.ID_USER"
INNER JOIN "AP_TIMP"."ATR::Structure" AS "STRUCT" ON
    "STRUCT"."ID" = "MAPPING"."STRUCTURE_ID"
ORDER BY "MAPPING"."STRUCTURE_ID", "MAPPING"."ID";

SELECT
    "MAPPING"."STRUCTURE_ID",
    "MAPPING"."ID" AS "MAPPING_ID", 
    "STRUCT"."title" AS "STRUCTURE_NAME",
    "MAPPING_TRIBUTO"."COD_TRIBUTO", 
    "TRIBUTO"."DESCR_COD_TRIBUTO_LABEL" AS "TAX_NAME"
FROM "AP_TIMP"."ATR::StructureFieldMappingXTributo" AS "MAPPING_TRIBUTO"
INNER JOIN "AP_TIMP"."ATR::Tributo" AS "TRIBUTO" ON
    "TRIBUTO"."COD_TRIBUTO" = "MAPPING_TRIBUTO"."COD_TRIBUTO"
INNER JOIN "AP_TIMP"."ATR::StructureFieldMapping" AS "MAPPING" ON
    "MAPPING"."ID" = "MAPPING_TRIBUTO"."STRUCTURE_FIELD_MAPPING_ID"
INNER JOIN "AP_TIMP"."ATR::Structure" AS "STRUCT" ON
    "STRUCT"."ID" = "MAPPING"."STRUCTURE_ID"
ORDER BY "STRUCT"."ID", "MAPPING"."ID", "MAPPING_TRIBUTO"."COD_TRIBUTO";

-- Para comparação das tabelas de mapeamento de parâmetros de entrada

SELECT 
    "MAPPING"."ID" AS "MAPPING_ID",
    "MAPPING"."STRUCTURE_ID",
    "MAPPING"."STRUCTURE_NAME",
    "MAPPING"."CREATION_USER" AS "CREATION_USER_ID",
    "MAPPING"."MODIFICATION_USER" AS "MODIFICATION_USER_ID",
    "CREATION.USER"."HANA_USER" AS "CREATION_USER",
    "MODIFICATION.USER"."HANA_USER" AS "MODIFICATION_USER",
    "MAPPING"."CREATION_DATE",
    "MAPPING"."MODIFICATION_DATE"
FROM "AP_TIMP"."ATR::INPUT_PARAMETERS_MAPPING" AS "MAPPING"
LEFT OUTER JOIN "AP_TIMP"."CORE::USER" AS "CREATION.USER" ON
    "CREATION.USER"."ID" = "MAPPING"."CREATION_USER"
LEFT OUTER JOIN "AP_TIMP"."CORE::USER" AS "MODIFICATION.USER" ON
    "MODIFICATION.USER"."ID" = "MAPPING"."MODIFICATION_USER"
ORDER BY "MAPPING"."STRUCTURE_ID", "MAPPING"."ID";

SELECT 
    "FIELD"."MAPPING_ID",
    "FIELD"."IS_MANUAL",
    "FIELD"."VALUE",
    "FIELD"."INPUT_PARAMETER",
    "FIELD"."OPERATOR",
    "FIELD"."DATE_FORMAT"
FROM "AP_TIMP"."ATR::INPUT_PARAMETERS_MAPPING_FIELDS_X_MAPPING" AS "FIELD"
ORDER BY "FIELD"."MAPPING_ID", "FIELD"."INPUT_PARAMETER";

SELECT 
    "MAPPING"."ID" AS "MAPPING_ID",
    "MAPPING"."STRUCTURE_ID",
    "STRUCT"."title" as "STRUCTURE_NAME",
    "MAPPING"."INPUT_PARAMETERS_MAPPING_ID",
    "MAPPING"."TRIBUTO_KEY" AS "COD_TRIBUTO",
    "MAPPING"."TRIBUTO_NAME" AS "DESC_TRIBUTO",
    "MAPPING"."CREATION_USER" AS "CREATION_USER_ID",
    "MAPPING"."MODIFICATION_USER" AS "MODIFICATION_USER_ID",
    "CREATION.USER"."HANA_USER" AS "CREATION_USER",
    "MODIFICATION.USER"."HANA_USER" AS "MODIFICATION_USER",
    "MAPPING"."CREATION_DATE",
    "MAPPING"."MODIFICATION_DATE"
FROM "AP_TIMP"."ATR::INPUT_PARAMETERS_MAPPING_AUX" AS "MAPPING"
INNER JOIN "AP_TIMP"."ATR::Structure" AS "STRUCT" ON
    "STRUCT"."ID" = "MAPPING"."STRUCTURE_ID"
LEFT OUTER JOIN "AP_TIMP"."CORE::USER" AS "CREATION.USER" ON
    "CREATION.USER"."ID" = "MAPPING"."CREATION_USER"
LEFT OUTER JOIN "AP_TIMP"."CORE::USER" AS "MODIFICATION.USER" ON
    "MODIFICATION.USER"."ID" = "MAPPING"."MODIFICATION_USER"
ORDER BY "MAPPING"."STRUCTURE_ID", "MAPPING"."ID";








































INSERT INTO "AP_TIMP"."ATR::Structure" (
	"ID", "isDeleted", "title", "hanaName", "JSON",
	"JOINT_AMOUNT", "HASH", "NAME_PTBR", "NAME_ENUS",
	"IS_SHADOW", "CREATION.DATE", "CREATION.ID_USER",
	"MODIFICATION.DATE", "MODIFICATION.ID_USER"
) VALUES (
	'546', '0', '02_LRCPE_Relatório de Análise', 'CV_02_LRCPE_CONSOLIDADO',
	'{"hanaName":"CV_02_LRCPE_CONSOLIDADO","version":1,"hanaPackage":"timp.atr.modeling.client.pb.lrcpe","title":"02_LRCPE_Relatório de Análise","description":"Estrutura de Consolidação LRCPE","descriptionPT":"Estrutura de Consolidação LRCPE","descriptionEN":"LRCPE Consolidation Structure","hasTDF":false,"isShadow":false,"lastId":20,"inputParameters":[{"ID":1,"hanaName":"IP_MANDANTE","isMandatory":false},{"ID":2,"hanaName":"IP_LONE","isMandatory":false,"operator":"IN","labelPT":"Lone","labelEN":"Lone","label":"Lone","isMultipleEntries":true},{"ID":3,"hanaName":"IP_CENTRO","isMandatory":false,"operator":"IN","labelPT":"Centro","labelEN":"Center","label":"Centro","isMultipleEntries":true},{"ID":4,"hanaName":"IP_EMPRESA","isMandatory":false,"labelPT":"Empresa","labelEN":"Company","label":"Empresa","value":"*"},{"ID":5,"hanaName":"IP_EXERCICIO","isMandatory":false,"labelPT":"Exercício","labelEN":"Year","label":"Exercício","value":"*"},{"ID":6,"hanaName":"IP_PERIOD","isMandatory":false,"labelPT":"Periodo","labelEN":"Period","label":"Periodo","value":"*"},{"ID":7,"hanaName":"IP_MATERIAL","isMandatory":false,"labelPT":"Material","labelEN":"Material","label":"Material","value":"*"},{"ID":8,"hanaName":"IP_DOC_MAT","isMandatory":false,"labelPT":"Documento do Material","labelEN":"Material Document","label":"Documento do Material","value":"*"},{"ID":9,"hanaName":"IP_DOCNUM","isMandatory":false,"labelPT":"Número do Documento","labelEN":"Documento Number","label":"Número do Documento","value":"*"},{"ID":10,"hanaName":"IP_TP_AVAL","isMandatory":false,"labelPT":"Tipo de Avaliação","labelEN":"Assessment Type","label":"Tipo de Avaliação","value":"*"},{"ID":11,"hanaName":"IP_UF","isMandatory":false,"labelPT":"UF","labelEN":"UF","label":"UF","value":"*"}],"levels":[{"name":"Dados","description":"Dados","namePT":"Dados","descriptionPT":"Dados","nameEN":"Data","descriptionEN":"Data","fields":[{"ID":1},{"ID":2},{"ID":3},{"ID":4},{"ID":5},{"ID":6},{"ID":7},{"ID":8},{"ID":9},{"ID":10},{"ID":11},{"ID":12},{"ID":13},{"ID":14},{"ID":15},{"ID":16},{"ID":17},{"ID":18},{"ID":19},{"ID":20}],"levels":[]}],"fields":[{"ID":1,"hanaName":"MANDT","isKey":false,"type":"NVARCHAR","dimension":3,"labelPT":"Mandante","labelEN":"Mandante","label":"Mandante","active":true},{"ID":2,"hanaName":"EMPRESA","isKey":false,"type":"NVARCHAR","dimension":4,"labelPT":"Empresa","labelEN":"Company","label":"Empresa","active":true},{"ID":3,"hanaName":"UF","isKey":false,"type":"NVARCHAR","dimension":2,"labelPT":"UF","labelEN":"UF","label":"UF","active":true},{"ID":4,"hanaName":"MES","isKey":false,"type":"NVARCHAR","dimension":2,"labelPT":"Mês","labelEN":"Month","label":"Mês","active":true},{"ID":5,"hanaName":"ANO","isKey":false,"type":"NVARCHAR","dimension":4,"labelPT":"Ano","labelEN":"Year","label":"Ano","active":true},{"ID":6,"hanaName":"MATNR","isKey":false,"type":"NVARCHAR","dimension":40,"labelPT":"Número do Material","labelEN":"Material Number","label":"Número do Material","active":true},{"ID":7,"hanaName":"DESC_MAT","isKey":false,"type":"NVARCHAR","dimension":40,"labelPT":"Descrição do Material","labelEN":"Material Description","label":"Descrição do Material","active":true},{"ID":8,"hanaName":"LONE","isKey":false,"type":"NVARCHAR","dimension":256,"labelPT":"Filial","labelEN":"Branch","label":"Filial","active":true},{"ID":9,"hanaName":"CENTRO","isKey":false,"type":"NVARCHAR","dimension":256,"labelPT":"Centro","labelEN":"Center","label":"Centro","active":true},{"ID":10,"hanaName":"QUANT_INICIAL","isKey":false,"type":"DECIMAL","isMeasure":true,"precision":3,"dimension":28,"labelPT":"Estoque Inicial","labelEN":"Initial Stock","label":"Estoque Inicial","active":true},{"ID":11,"hanaName":"NF_ENT_TRANSF","isKey":false,"type":"DECIMAL","isMeasure":true,"precision":3,"dimension":28,"labelPT":"NF - Entradas por transferência CFOP''s 1659 - Z01, Z02 e Z67","labelEN":"NF - Entradas por transferência CFOP''s 1659 - Z01, Z02 e Z67","label":"NF - Entradas por transferência CFOP''s 1659 - Z01, Z02 e Z67","active":true},{"ID":12,"hanaName":"NF_DEV_VEND","isKey":false,"type":"DECIMAL","isMeasure":true,"precision":3,"dimension":28,"labelPT":"NF - Devol.Vendas CFOP 1.661 - Y02","labelEN":"NF - Devol.Vendas CFOP 1.661 - Y02","label":"NF - Devol.Vendas CFOP 1.661 - Y02","active":true},{"ID":13,"hanaName":"NF_SAI_TRANSF","isKey":false,"type":"DECIMAL","isMeasure":true,"precision":3,"dimension":28,"labelPT":"NF - Saídas por transferência CFOP''s 5.658, 5.659 e 6.659 - Z01, Z02 e Z67","labelEN":"NF - Saídas por transferência CFOP''s 5.658, 5.659 e 6.659 - Z01, Z02 e Z67","label":"NF - Saídas por transferência CFOP''s 5.658, 5.659 e 6.659 - Z01, Z02 e Z67","active":true},{"ID":14,"hanaName":"NF_VENDAS","isKey":false,"type":"DECIMAL","isMeasure":true,"precision":3,"dimension":28,"labelPT":"NF - Vendas CFOP''s 5.403, 5.652 e 5.655 - 601","labelEN":"NF - Vendas CFOP''s 5.403, 5.652 e 5.655 - 601","label":"NF - Vendas CFOP''s 5.403, 5.652 e 5.655 - 601","active":true},{"ID":15,"hanaName":"TROC_COD_PROD_ENT","isKey":false,"type":"DECIMAL","isMeasure":true,"precision":3,"dimension":28,"labelPT":"Troca de código de produto Entrada - Z89 e Z91","labelEN":"Troca de código de produto Entrada - Z89 e Z91","label":"Troca de código de produto Entrada - Z89 e Z91","active":true},{"ID":16,"hanaName":"TROC_COD_PROD_SAI","isKey":false,"type":"DECIMAL","isMeasure":true,"precision":3,"dimension":28,"labelPT":"Troca de código de produto Saída - Z89 e Z93","labelEN":"Troca de código de produto Saída - Z89 e Z93","label":"Troca de código de produto Saída - Z89 e Z93","active":true},{"ID":17,"hanaName":"FALTAS_SOBRAS_DEF","isKey":false,"type":"DECIMAL","isMeasure":true,"precision":3,"dimension":28,"labelPT":"Saldo de faltas e sobras definitivas - ZA1, ZA2, ZE0, ZE9, ZI3 a ZI8","labelEN":"Saldo de faltas e sobras definitivas - ZA1, ZA2, ZE0, ZE9, ZI3 a ZI8","label":"Saldo de faltas e sobras definitivas - ZA1, ZA2, ZE0, ZE9, ZI3 a ZI8","active":true},{"ID":18,"hanaName":"MOV_PROV_ENT","isKey":false,"type":"DECIMAL","isMeasure":true,"precision":3,"dimension":28,"labelPT":"Movimentos Provisórios - PSO, YSO, 309, 310, 311, YS2 e Z52","labelEN":"Movimentos Provisórios - PSO, YSO, 309, 310, 311, YS2 e Z52","label":"Movimentos Provisórios - PSO, YSO, 309, 310, 311, YS2 e Z52","active":true},{"ID":19,"hanaName":"MOV_PROV_SAI","isKey":false,"type":"DECIMAL","isMeasure":true,"precision":3,"dimension":28,"labelPT":"Movimentos Provisórios - PSO, YSO, 309, 310, 311, YS2 e Z52","labelEN":"Movimentos Provisórios - PSO, YSO, 309, 310, 311, YS2 e Z52","label":"Movimentos Provisórios - PSO, YSO, 309, 310, 311, YS2 e Z52","active":true},{"ID":20,"hanaName":"QUANT_FINAL","isKey":false,"type":"DECIMAL","isMeasure":true,"precision":3,"dimension":28,"labelPT":"Estoque Final","labelEN":"Final Stock","label":"Estoque Final","active":true}],"jointAmount":1}',
	'1', '-761185219', 'Estrutura de Consolidação LRCPE', 'LRCPE Consolidation Structure', '0', '2024-04-08 09:39:40.394',
	'3219369', '2024-04-08 09:39:40.394', '3219369'
);

INSERT INTO "AP_TIMP"."ATR::StructureGroupXStructure" (
	'STRUCTURE_GROUP_ID', 'STRUCTURE_ID'
) VALUES (
	'1942', '542'
);

UPDATE 
	"AP_TIMP"."ATR::Structure" 
SET 
	"CREATION.DATE" = '2024-04-08 09:39:40.394' AND 
	"MODIFICATION.DATE" = '2024-04-08 09:39:40.394' 
WHERE "ID" = '546';

-- Mon Apr 08 2024 09:25:08 GMT-0300
-- Fri Apr 05 2024 17:24:15 GMT-0300