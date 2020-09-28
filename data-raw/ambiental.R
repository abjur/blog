## code to prepare `DATASET` dataset goes here

library(tidyverse)

da_intervencao_raw <- read_csv("~/Downloads/decintervencao.csv")
da_ambiental_raw <- read_csv("~/Downloads/declicambiental.csv")

da_intervencao <- da_intervencao_raw %>% 
  transmute(
    id, 
    processo,
    orgao, 
    municipio, 
    tipo_pessoa = case_when(
      str_length(cpfcnpj) == "14" ~ "Física",
      str_length(cpfcnpj) == "18" ~ "Jurídica"
    ),
    responsavel,
    # data = paste(ano, mes, 1, sep = "-"),
    # data = case_when(
    #   data == "NA-NA-1" ~ NA_character_,
    #   TRUE ~ data
    # ),
    # data = lubridate::ymd(data),
    data_entrada = lubridate::dmy(dataentrada),
    data_decisao = lubridate::dmy(data),
    local,
    modalidade,
    area = case_when(
      area %in% c("o", "'") ~ NA_character_,
      TRUE ~ area
    ),
    area = parse_number(area, locale = locale(decimal_mark = ",", grouping_mark = ".")),
    bioma,
    decisao
  )

da_ambiental <- da_ambiental_raw %>% 
  transmute(
    id,
    tipo_pessoa = case_when(
      str_length(cnpjcpf) == "14" ~ "Física",
      str_length(cnpjcpf) == "18" ~ "Jurídica"
    ),
    classe,
    datapublic,
    data_decisao = lubridate::dmy(datapublic),
    responsavel = empreendimento,
    regional,
    modalidade,
    decisao
  )


