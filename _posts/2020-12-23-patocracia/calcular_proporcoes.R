library(magrittr)

da_tjsp_raw <- readr::read_rds("~/Downloads/Candidatos 2020/candidatos2020_reus.rds")

classes_consideradas <- c(
  "Ação Penal - Procedimento Ordinário",
  "Ação Penal - Procedimento Sumário",
  "Ação Penal - Procedimento Sumaríssimo",
  "Ação Penal de Competência do Júri"
)
da_tjsp <- da_tjsp_raw %>% 
  dplyr::mutate(ano_processo = stringr::str_sub(id_processo, 12, 15)) %>% 
  dplyr::filter(
    classe %in% classes_consideradas,
    ano_processo %in% c(2014:2019)
  )

# candidatos --------------------------------------------------------------
da_cand_raw <- vroom::vroom(
  "~/Downloads/consulta_cand_2020/consulta_cand_2020_SP.csv",
  locale = vroom::locale(encoding = "latin1")
) %>% janitor::clean_names()

dplyr::glimpse(da_cand)
sit_eleito <- c(c("ELEITO", "ELEITO POR MÉDIA", "ELEITO POR QP"))
da_cand <- da_cand_raw %>% 
  dplyr::mutate(eleito = dplyr::case_when(
    ds_sit_tot_turno %in% sit_eleito ~ "Sim",
    TRUE ~ "Não"
  )) %>% 
  dplyr::select(nr_turno, ds_cargo, ds_genero, nr_cpf_candidato, eleito) %>% 
  dplyr::mutate(tem_processo = dplyr::case_when(
    nr_cpf_candidato %in% unique(da_tjsp$cpf_candidato) ~ "Sim",
    TRUE ~ "Não"
  )) %>% 
  dplyr::distinct(nr_cpf_candidato, .keep_all = TRUE)

da_cand %>% 
  dplyr::count(tem_processo, eleito) %>% 
  dplyr::group_by(tem_processo) %>% 
  dplyr::mutate(prop_eleito = n/sum(n)) %>% 
  dplyr::ungroup()

# painel cnj --------------------------------------------------------------

da_classe <- fs::dir_ls("~/Downloads/tjsp_classe") %>% 
  purrr::map_dfr(readxl::read_excel, col_types = "text", .id = "ano", na = "-") %>% 
  janitor::clean_names() %>% 
  dplyr::rename_with(janitor::make_clean_names, replace = c("º" = "")) %>% 
  dplyr::mutate(
    ano = basename(tools::file_path_sans_ext(ano)),
    ano = as.character(readr::parse_number(ano))
  ) %>% 
  dplyr::filter(
    classe_nome1 == "PROCESSO CRIMINAL",
    classe_nome2 == "Procedimento Comum"
  ) %>% 
  dplyr::select(ano, classe_nome3, x1_grau:total) %>% 
  dplyr::mutate(dplyr::across(x1_grau:total, as.numeric)) %>% 
  tidyr::pivot_longer(x1_grau:total) %>% 
  dplyr::filter(!is.na(value), name != "total")

total_classe <- da_classe %>% 
  dplyr::filter(name %in% c("x1_grau", "juizado_especial")) %>% 
  dplyr::summarise(total = sum(value), .groups = "drop") %>% 
  dplyr::pull(total)


# seade -------------------------------------------------------------------

aux_seade <- readr::read_csv2(
  "~/Downloads/Projpop/tb_dados.txt",
  locale = readr::locale(encoding = "latin1"), 
  guess_max = 2e4
)

populacao_elegivel <- aux_seade %>% 
  dplyr::filter(!is.na(mun_id)) %>% 
  dplyr::group_by(ano) %>% 
  dplyr::summarise(dplyr::across(FH1:DOM, sum), .groups = "drop") %>% 
  tidyr::pivot_longer(FH1:DOM) %>% 
  dplyr::filter(
    stringr::str_detect(name, "FH|FM"),
    ano == "2020",
    !stringr::str_detect(name, "F[HM][1-4]$")
  ) %>% 
  dplyr::summarise(v = sum(value)) %>% 
  dplyr::pull(v)


# resultados --------------------------------------------------------------
prop_geral <- scales::percent(total_classe / populacao_elegivel, .001)
prop_cand <- da_cand %>% 
  with(scales::percent(mean(tem_processo == "Sim"), .001))
prop_cand_eleito <- da_cand %>% 
  dplyr::filter(eleito == "Sim") %>% 
  with(scales::percent(mean(tem_processo == "Sim"), .001))

