-- Скрипт создает таблицу-справочник по данным, содержащимся в других таблицах по опционам (риск-параметры, торговые параметры)

DROP TABLE IF EXISTS public.data_desc;

CREATE TABLE public.data_desc
(
    "Table" text,
    "Field" text,
    "Description" text
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.data_desc
    OWNER to postgres;
	
COPY public.data_desc
FROM 'C:\Users\Public\Data_desc.csv' 
DELIMITER ';' CSV HEADER ENCODING 'WIN 1251';

-- Скрипт создает таблицу риск-параметров (по данным из файла FO_RISKOPT_F_20200211000000.csv)

DROP TABLE IF EXISTS public.risk_opt;

CREATE TABLE public.risk_opt
(
	"EXP_DATE" date,
	"LIMIT_UP" int,
	"LIMIT_DOWN" int,
	"IM_NOTCOVSELL" real,
	"IM_COVSELL" real,
	"IM_BUY" real,
	"TICKER" text,
	CONSTRAINT risk_opt_pkey PRIMARY KEY ("TICKER")
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.risk_opt
    OWNER to postgres;

COPY public.risk_opt
FROM 'C:\Users\Public\risk_opt.csv'
DELIMITER ';' CSV HEADER ENCODING 'WIN 1251';

-- Скрипт создает таблицу с информацией по торгам (из файла OPT_F_20200211000000.csv)

DROP TABLE IF EXISTS public.trading_opt;

CREATE TABLE public.trading_opt
(
	"CONTRACT" text,
	"AVRG" real,
	"FEE" real,
	"TICK_PRICE" real,
	"TICK" real,
	"DEPO_UNCOV" real,
	"DEPO_COV" real,
	"FUT_CONTR" text,
	"STRIKE" real,
	"PUT" text,
	"EVROP" text,
	"VOLAT" real,
	"THEORPRICE" real,
	"TICK_PR_GO" real,
	"PR_VOLAT" real,
	"PR_THEORPR" real,
	"FUT_TYPE" bool,
	"BASEGOBUY" real
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.trading_opt
    OWNER to postgres;
	
COPY public.trading_opt
FROM 'C:\Users\Public\trading_opt.csv' 
DELIMITER ';' CSV HEADER ENCODING 'WIN 1251';

-- Скрипт создает таблицу с дополнительной информацией по фьючерсам и опционам (из файла FO_F_20200211000000.csv)
-- после удаляется ненужная информация (например, коды Блумберга, TR, а также та информация, которая уже есть в торговых параметрах)
-- затем оставшаяся информация объединяется с информацией по торгам в таблице trading_opt

DROP TABLE IF EXISTS public.extras;

CREATE TABLE public.extras
(
    "TICKER" text,
    "SHORT_TICKER" text,
    "SECURITY_NM" text,
	"KIND" text,
	"BASE_CODE" text,
	"BASE_NM" text,
	"BASE_CUR" text,
	"EXEC_TYPE" text,
	"START_DATE" date,
	"END_DATE" date,
	"EXP_DATE" date,
	"BLOOMBERG_CODE" text,
	"THOMSON_REUTERS_CODE" text,
	"STRIKE" real,
	"QUOTATION" text,
	"MIN_STEP" real,
	"LOT" real,
	"MIN_STEP_PRICE" real,
	CONSTRAINT extras_pkey PRIMARY KEY ("TICKER")
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.extras
    OWNER to postgres;
	
COPY public.extras
FROM 'C:\Users\Public\extras.csv' 
DELIMITER ';' CSV HEADER ENCODING 'WIN 1251';

ALTER TABLE public.extras
DROP "EXP_DATE", DROP "BLOOMBERG_CODE", DROP "THOMSON_REUTERS_CODE", DROP "STRIKE", DROP "MIN_STEP", DROP "MIN_STEP_PRICE";


-- Merge

ALTER TABLE public.trading_opt
ADD "SHORT_TICKER" text,
ADD "SECURITY_NM" text,
ADD "KIND" text,
ADD "BASE_CODE" text,
ADD "BASE_NM" text,
ADD "BASE_CUR" text,
ADD "EXEC_TYPE" text,
ADD "START_DATE" date,
ADD "END_DATE" date,
ADD "QUOTATION" text,
ADD "LOT" real;

UPDATE public.trading_opt
SET "SHORT_TICKER"=public.extras."SHORT_TICKER",
"SECURITY_NM"=public.extras."SECURITY_NM",
"KIND"=public.extras."KIND",
"BASE_CODE"=public.extras."BASE_CODE",
"BASE_NM"=public.extras."BASE_NM",
"BASE_CUR"=public.extras."BASE_CUR",
"EXEC_TYPE"=public.extras."EXEC_TYPE",
"START_DATE"=public.extras."START_DATE",
"END_DATE"=public.extras."END_DATE",
"QUOTATION"=public.extras."QUOTATION",
"LOT"=public.extras."LOT"
FROM public.extras
WHERE public.trading_opt."CONTRACT"=public.extras."TICKER";

DROP TABLE public.extras;