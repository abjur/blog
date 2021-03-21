library(magrittr)

# tjsp candidatos ---------------------------------------------------------

da_tjsp_raw <- readr::read_rds(
  "~/Downloads/patocracia/Candidatos 2020/candidatos2020_reus.rds"
)

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
    !stringr::str_detect(distribuicao, "Juizado"),
    ano_processo %in% c(2014:2019)
  ) %>% 
  dplyr::select(id_processo, cpf_candidato, assunto)

# candidatos --------------------------------------------------------------
da_cand_raw <- vroom::vroom(
  "~/Downloads/patocracia/consulta_cand_2020/consulta_cand_2020_SP.csv",
  locale = vroom::locale(encoding = "latin1")
) %>% janitor::clean_names()

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

da_tjsp_eleitos <- da_tjsp %>% 
  dplyr::semi_join(
    dplyr::filter(da_cand, eleito == "Sim"), 
    c("cpf_candidato" = "nr_cpf_candidato")
  )

da_tjsp_join <- da_tjsp %>% 
  dplyr::left_join(da_cand, c("cpf_candidato" = "nr_cpf_candidato")) %>% 
  dplyr::mutate(assunto = abjutils::rm_accent(toupper(assunto))) %>% 
  dplyr::count(assunto, eleito, name = "value") %>% 
  dplyr::mutate(name = dplyr::if_else(
    eleito == "Sim", "nproc_eleito", "nproc_neleito"
  )) %>% 
  dplyr::select(-eleito) %>% 
  tidyr::pivot_wider(values_fill = 0) %>% 
  dplyr::mutate(nproc_total = nproc_neleito + nproc_eleito) %>% 
  dplyr::select(-nproc_neleito)

# seade -------------------------------------------------------------------

aux_seade <- readr::read_csv2(
  "~/Downloads/patocracia/Projpop/tb_dados.txt",
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
  dplyr::mutate(sexo = stringr::str_sub(name, 2, 2)) %>% 
  # dplyr::group_by(sexo) %>% 
  dplyr::summarise(v = sum(value))


# painel cnj - assunto ----------------------------------------------------

# da_assunto <- fs::dir_ls("~/Downloads/patocracia/tjsp_assunto") %>% 
#   purrr::map_dfr(readxl::read_excel, col_types = "text", .id = "ano", na = "-") %>% 
#   janitor::clean_names() %>% 
#   dplyr::mutate(
#     ano = basename(tools::file_path_sans_ext(ano)),
#     ano = as.character(readr::parse_number(ano))
#   ) %>% 
#   dplyr::filter(assunto_nome1 %in% c("DIREITO PENAL")) %>% 
#   dplyr::select(
#     ano, 
#     dplyr::starts_with("assunto_nome"), 
#     x1o_grau, juizado_especial
#   ) %>% 
#   dplyr::mutate(
#     dplyr::across(x1o_grau:juizado_especial, as.numeric),
#     dplyr::across(x1o_grau:juizado_especial, tidyr::replace_na, 0),
#     total_cnj = x1o_grau
#   ) %>% 
#   dplyr::select(-x1o_grau, -juizado_especial) %>% 
#   tibble::rowid_to_column()
# 
# total_assuntos <- da_assunto %>% 
#   dplyr::select(-assunto_nome1, -assunto_nome2) %>% 
#   tidyr::pivot_longer(dplyr::starts_with("assunto_"), values_to = "assunto") %>% 
#   dplyr::filter(!is.na(assunto)) %>% 
#   dplyr::mutate(assunto = abjutils::rm_accent(toupper(assunto))) %>%
#   dplyr::group_by(rowid, name, assunto) %>% 
#   dplyr::summarise(total_cnj = sum(total_cnj), .groups = "drop") %>% 
#   dplyr::inner_join(da_tjsp_join, "assunto") %>% 
#   dplyr::arrange(dplyr::desc(name)) %>% 
#   dplyr::distinct(rowid, .keep_all = TRUE) %>% 
#   dplyr::group_by(assunto) %>% 
#   dplyr::summarise(
#     total_cnj = sum(total_cnj),
#     dplyr::across(c(nproc_eleito, nproc_total), dplyr::first)
#   ) %>% 
#   dplyr::mutate(
#     pop = populacao_elegivel$v,
#     pop_cand = nrow(da_cand)
#   ) %>% 
#   dplyr::arrange(dplyr::desc(nproc_total))
# 

# assuntos direto do TJSP -------------------------------------------------

assuntos_tjsp <- esaj::cjpg_table("subjects")
classes_tjsp <- esaj::cjpg_table("classes")
assuntos_tjsp_penal <- assuntos_tjsp %>% 
  dplyr::filter(name0 == "DIREITO PENAL") %>% 
  tibble::rowid_to_column()

assuntos_tjsp_penal_empilhado <- purrr::map_dfr(
  as.character(0:5), ~{
    dplyr::select(assuntos_tjsp_penal, rowid, dplyr::ends_with(.x)) %>% 
      purrr::set_names(c("rowid", "name", "id")) %>% 
      dplyr::mutate(nivel = .x)
  }
) %>% 
  dplyr::mutate(assunto = toupper(abjutils::rm_accent(name))) %>% 
  dplyr::inner_join(da_tjsp_join, "assunto") %>% 
  dplyr::arrange(dplyr::desc(nivel)) %>% 
  dplyr::distinct(id, assunto, .keep_all = TRUE) %>% 
  dplyr::select(assunto, id, dplyr::starts_with("nproc"))

tjsp_res_assunto_ano <- function(ano, assunto) {
  query_post <- list(
    conversationId = "", 
    dadosConsulta.pesquisaLivre = "", 
    tipoNumero = "UNIFICADO", 
    numeroDigitoAnoUnificado = "", 
    foroNumeroUnificado = "", 
    dadosConsulta.nuProcesso = "", 
    # classes de interesse
    classeTreeSelection.values = "8657,8803,8804,8656", 
    assuntoTreeSelection.values = assunto, 
    contadoragente = 0, 
    contadorMaioragente = 0, 
    dadosConsulta.dtInicio = paste0("01/01/", ano), 
    dadosConsulta.dtFim = paste0("31/12/", ano), 
    varasTreeSelection.values = "", 
    dadosConsulta.ordenacao = "DESC"
  )
  r <- httr::POST(
    "https://esaj.tjsp.jus.br/cjpg/pesquisar.do", 
    body = query_post, httr::config(ssl_verifypeer = FALSE)
  )
  n_results <- r %>% 
    xml2::read_html() %>% 
    xml2::xml_find_all("//*[@id='resultados']/table[1]") %>% 
    xml2::xml_text() %>% 
    stringr::str_extract_all(" [0-9]+") %>% 
    purrr::pluck(1) %>% 
    stringr::str_trim() %>% 
    as.numeric() %>% 
    dplyr::last()
  n_results
}

tjsp_res_assunto <- function(assunto) {
  message(assunto)
  purrr::map_dbl(2014:2019, tjsp_res_assunto_ano, assunto) %>% 
    sum(na.rm = TRUE)
}

# DEMORA
assuntos_tjsp_esaj <- assuntos_tjsp_penal_empilhado %>% 
  dplyr::mutate(n_esaj = purrr::map_dbl(id, tjsp_res_assunto))

assuntos_tjsp_esaj_filter <- assuntos_tjsp_esaj %>% 
  dplyr::filter(n_esaj > 0) %>% 
  dplyr::distinct(assunto, .keep_all = TRUE) %>% 
  dplyr::mutate(
    pop = populacao_elegivel$v,
    pop_cand = nrow(da_cand)
  )

# resultados --------------------------------------------------------------

# prop_geral <- scales::percent(total_classe / populacao_elegivel, .001)
# prop_cand <- da_cand %>% 
#   with(scales::percent(mean(tem_processo == "Sim"), .001))
# prop_cand_eleito <- da_cand %>% 
#   dplyr::filter(eleito == "Sim") %>% 
#   with(scales::percent(mean(tem_processo == "Sim"), .001))

