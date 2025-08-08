install.packages("pak")
pak::pak("ajdamico/lodown")
library(lodown) # [github::ajdamico/lodown] v0.1.0
library(magrittr) # CRAN v2.0.1
library(dplyr) # CRAN v1.0.7
library(stringr) # CRAN v1.4.0
library(fs) # CRAN v1.5.0
library(SAScii) # CRAN v1.0
library(readr)
library(arrow)
library(dplyr)
library(censobr)

options(scipen = 999)

setwd("C:\\Users\\julia_z131ibj\\OneDrive\\Documentos\\OUC-Rio\\bases\\censo")

# dicionário de variáveis de pessoas (microdados da amostra)
data_dictionary(year = 2000, 
                dataset = 'population')

# dicionário de variáveis de domicílios (microdados da amostra)
data_dictionary(year = 2010, 
                dataset = 'households')


# Buscar catálogo de microdados, aplicar filtros e baixar arquivos
catalog <- lodown::get_catalog(data_name = "censo", output_dir = "data") %>%
  dplyr::filter(year == 2010, stringr::str_detect(state, "rj")) %>%
  lodown::lodown(data_name = "censo")

# Arquivos baixados
fs::dir_tree(path = "data")

# Variáveis a serem importadas
vars_censo <- c("v0002", "v0011", "v0010", "v0601", "v6036", "v0606", 
                "v0620", "v0621", "v6224", "v6264", "v0624", "v0633",  
                "v0634", "v6461", "v6471", "v6513", "v0662")

# Converte arquivo de instruções de importação SAS para o R
sas_input <- SAScii::parse.SAScii(catalog$pes_sas) %>%
  dplyr::mutate(varname = stringr::str_to_lower(varname))

# Importar arquivo TXT
raw_censo <- readr::read_fwf(
  file = catalog$pes_file,
  col_positions = readr::fwf_widths(
    widths = abs(sas_input$width),
    col_names = sas_input$varname
  ),
  col_types = paste0(
    ifelse(
      !(sas_input$varname %in% vars_censo),
      "_",
      ifelse(sas_input$char, "c", "d")
    ),
    collapse = ""
  )
)

dplyr::glimpse(raw_censo)

#renomear variáveis
raw_censo<-raw_censo%>%
  rename(cod_mun = v0002,
         area_pon = v0011,
         peso = v0010,
         sexo = v0601,
         idade = v6036,
         raça = v0606,
         nacionalidade = v0620,
         ano_brasil = v0621,
         país_origem = v6224,
         mun_resid_2005 = v6264,
         tempo_mora_rj = v0624,
         ultima_educ = v0633,
         concluiu = v0634,
         ocupacao = v6461,
         atividade = v6471,
         rendimento = v6513,
         tempo_deslocamento = v0662
  )


# salvar para trabalhar no SQL
library(DBI)

## exportar
con <- dbConnect(RSQLite::SQLite(), "censo_rj.db")

dbWriteTable(con, "censo", raw_censo, overwrite = TRUE)

dbDisconnect(con)

## trazer de volta

con <- dbConnect(RSQLite::SQLite(), "censo_rj.db")

dbListTables(con)

df_censo <- dbReadTable(con, "censo")

dbDisconnect(con)
