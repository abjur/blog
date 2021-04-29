library(tidyverse)

leiloes <- obsFase3::da_leilao_tidy

# PROCESSOS) quantidade de processos por leiloeiro +  valor total daqeule leiloeiro
processos <- analise %>% 
  # as duas próximas linhas são pra pegar o valor total DE CADA PROCESSO
  dplyr::group_by(id_processo, leiloeiro) %>% 
  dplyr::summarise(valor_total_processo = sum(valor_avaliacao_inicial, na.rm=T)) %>% 
  # as duas próximas são pra resumir a quantidade de processos por leiloeiro e o valor médio dos processos de cada leiloeiro
  group_by(leiloeiro) %>% 
  summarise(qtd_processos = n(), vtp = mean(valor_total_processo, na.rm=T)) %>% 
  filter(!is.na(leiloeiro)) %>% 
  arrange(desc(qtd_processos))

# SUCESSO) pegar o valor por bem
# A) ordenar de forma decrescente por data do edital 
# B) agrupar por id_processo e descrição
# C) slice(1)
# o perigo disso é se a gente muda o nome na descrição
# a gnt muda? muda... Então VOILÁ o REGEX

# analise1 <- analise %>% 
#  mutate(descricao2 = stringr::str_remove_all(descricao, stringr::regex("lote *(nº *)?[0-9.]+ *[:;-–]? *(?=[a-z0-9- ]{1,5})", TRUE)))
# Esse regex ta no tidy.R já

sucesso <- analise %>% 
  # Essas três funções a seguir são essenciais: elas servem para selecionar apenas 1 versão bem, se ele for repetido em vários editais
  arrange(desc(data_edital)) %>% 
  group_by(id_processo, descricao) %>% 
  slice(1) %>% 
  # A partir disso, eu posso selecionar minhas colunas de interesse
  select(id_processo, descricao, leiloeiro, valor_avaliacao_inicial, vendeu, valor_total_arrematado) %>% 
  # Tem alguns casos, em que a avaliação inicial é 0 (são 50 casos). Isso acontece, mas quero excluir isso. São bens sem valor comercial algum
  filter(is.na(valor_avaliacao_inicial) | valor_avaliacao_inicial > 0) %>%
  mutate(across(
    .cols = contains("valor"),
    .fns = ~case_when(is.na(.x) ~ 0,
           TRUE ~ .x)
  )) %>% 
  mutate(taxa_venda = valor_total_arrematado / valor_avaliacao_inicial) %>%
  filter(taxa_venda <= 10)
  
# PLOTS
# 1) Quantidade de processos por leiloeiro
processos %>% 
  arrange(qtd_processos) %>% 
  mutate(leiloeiro = forcats::as_factor(leiloeiro)) %>% 
  ggplot() +
    geom_col(mapping = aes(x = qtd_processos, y = leiloeiro))
  
# 2) Valor médio de cada leiloeiro
processos %>% 
  arrange(vtp) %>% 
  mutate(leiloeiro = forcats::as_factor(leiloeiro)) %>% 
  ggplot() +
  geom_col(mapping = aes(x = vtp, y = leiloeiro)) +
  scale_x_log10(labels = scales::label_number_si(), breaks = 10^c(1:8))

# 3) Sucessos


# Peguei um processo pra cada leiloeiro pra analisar ----------------
a <- analise %>% 
  dplyr::select(id_processo, leiloeiro) %>% 
  unique() %>% 
  filter(!is.na(leiloeiro)) %>% 
  group_by(leiloeiro) %>% 
  slice(1)

