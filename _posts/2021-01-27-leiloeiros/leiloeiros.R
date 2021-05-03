library(tidyverse)

leiloes <- obsFase3::da_leilao_tidy

# PROCESSOS) quantidade de processos por leiloeiro +  valor total daqeule leiloeiro
processos <- analise %>% 
  select(!leiloeiro) %>% 
  rename(leiloeiro = leiloeiro_usar) %>% 
  # as duas próximas linhas são pra pegar o valor total DE CADA PROCESSO
  group_by(id_processo, leiloeiro) %>% 
  summarise(valor_total_processo = sum(valor_avaliacao_inicial, na.rm=T)) %>% 
  # as duas próximas são pra resumir a quantidade de processos por leiloeiro e o valor médio dos processos de cada leiloeiro
  group_by(leiloeiro) %>% 
  summarise(qtd_processos = n(), vtp = mean(valor_total_processo, na.rm=T)) %>% 
  arrange(desc(qtd_processos)) %>% 
  filter(vtp > 100)

# SUCESSO) pegar o valor por be + quantidade total de processos
# A) ordenar de forma decrescente por data do edital 
# B) agrupar por id_processo e descrição
# C) slice(1)
# o perigo disso é se a gente muda o nome na descrição
# a gnt muda? muda... Então VOILÁ o REGEX

# analise1 <- analise %>% 
#  mutate(descricao2 = stringr::str_remove_all(descricao, stringr::regex("lote *(nº *)?[0-9.]+ *[:;-–]? *(?=[a-z0-9- ]{1,5})", TRUE)))
# Esse regex ta no tidy.R já

sucesso <- analise %>% 
  # 3 funções pra corrigir o nome de leiloeiro_usar
  select(!leiloeiro) %>% 
  rename(leiloeiro = leiloeiro_usar) %>% 
  filter(leiloeiro != "Lance Alienações Eletrônicas Ltda") %>% # Eu tirei isso, porque ele é a única PJ e só tem 100 reais... 
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
  mutate(vendeu = case_when(
    is.na(vendeu) ~ "nao", 
    TRUE ~ vendeu
  )) %>% 
  mutate(taxa_venda_valor = valor_total_arrematado / valor_avaliacao_inicial) %>% 
  filter(taxa_venda_valor <= 10)
  
  
# PLOTS
# 1) Quantidade de processos por leiloeiro
processos %>% 
  mutate(leiloeiro = forcats::fct_reorder(leiloeiro, qtd_processos)) %>% 
  ggplot() +
    geom_col(mapping = aes(x = qtd_processos, y = leiloeiro))
  
# 2) Valor médio de cada leiloeiro
processos %>% 
  mutate(leiloeiro = forcats::fct_reorder(leiloeiro, vtp)) %>% 
  ggplot() +
    geom_col(mapping = aes(x = vtp, y = leiloeiro)) +
    scale_x_log10(labels = scales::label_number_si(), breaks = 10^c(1:8))

# 3) Sucessos
# A) "Quem consegue vender mais?" Total de bens em que vende == SIM / Total de bens relacionados àquele leiloeiro 
sucesso %>%
  group_by(leiloeiro, vendeu) %>%
  summarise(qtd_bens = n()) %>% 
  tidyr::pivot_wider(
    names_from = vendeu,
    values_from = qtd_bens
  ) %>% 
  mutate(across(
    c(sim, nao),
    ~replace_na(.x, 0)
  )) %>% 
  mutate(total_bens = sim + nao, taxa_sucesso = sim / total_bens) %>% 
  ungroup(leiloeiro) %>% 
  mutate(leiloeiro = forcats::fct_reorder(leiloeiro, taxa_sucesso)) %>% 
  ggplot() + 
    geom_col(mapping = aes(x = taxa_sucesso, y = leiloeiro))
  
# B) "Quem vende com menores perdas?" Taxa_venda (arremate / avaliacao)
# Disclaimer pro 3B: o  leiloeiro vender com menores perdas não significa que ele é responsável por isso! 
# Pode ser que o leiloeiro só aceite vender bens com grandes chances de vender
# Enfim tem várias hipóteses, e esse artigo não se prestou a testar essas hipóteses, o que exigiria algum tipo de modelagem
# A única constatação aqui é sobre o taxa de desvalorização do bem para cada leiloeiro, mas isso não é causal
sucesso  %>% 
  filter(vendeu == "sim") %>% 
  group_by(leiloeiro) %>% 
  summarise(taxa_venda_media = mean(taxa_venda_valor)) %>% 
  arrange(taxa_venda_media) %>% 
  mutate(leiloeiro = forcats::as_factor(leiloeiro)) %>%
  ggplot() +
  geom_col(mapping = aes(y = leiloeiro, x = taxa_venda_media))

# 4) PLacar de cada jogo
# Jogo 1
placar_jogo1 <- processos %>% 
  mutate(score_jogo_1 = as.numeric(forcats::as_factor(qtd_processos))) %>% 
  select(leiloeiro, qtd_processos, score_jogo_1) %>% 
  arrange(desc(score_jogo_1))

knitr::kable(placar_jogo1)

# Jogo 2
placar_jogo2 <- processos %>% 
  mutate(score_jogo_2 = as.numeric(forcats::as_factor(vtp))) %>% 
  select(leiloeiro, vtp, score_jogo_2) %>% 
  arrange(desc(score_jogo_2))

left_join(placar_jogo1, placar_jogo2, by = "leiloeiro") %>% 
  mutate(pontos_acumulados = score_jogo_1 + score_jogo_2) %>% 
  select(leiloeiro, vtp, score_jogo_2, pontos_acumulados) %>% 
  arrange(desc(score_jogo_2)) %>% 
  knitr::kable()

# Jogo 3
placar_jogo3 <- sucesso %>% 
  group_by(leiloeiro, vendeu) %>%
  summarise(qtd_bens = n()) %>% 
  tidyr::pivot_wider(
    names_from = vendeu,
    values_from = qtd_bens
  ) %>% 
  mutate(across(
    c(sim, nao),
    ~replace_na(.x, 0)
  )) %>% 
  mutate(total_bens = sim + nao, taxa_sucesso = sim / total_bens) %>% 
  ungroup(leiloeiro) %>% 
  mutate(score_jogo_3 = as.numeric(forcats::as_factor(taxa_sucesso))) %>% 
  select(leiloeiro, taxa_sucesso, score_jogo_3) %>% 
  arrange(desc(score_jogo_3))

left_join(placar_jogo3, left_join(placar_jogo1, placar_jogo2, by = "leiloeiro"), by = "leiloeiro") %>% 
  mutate(pontos_acumulados = score_jogo_1 + score_jogo_2 + score_jogo_3) %>% 
  select(leiloeiro, taxa_sucesso, score_jogo_3, pontos_acumulados) %>% 
  arrange(desc(score_jogo_3)) %>% 
  knitr::kable()

# Jogo 4
placar_jogo4 <- sucesso %>% 
  group_by(leiloeiro) %>% 
  summarise(taxa_venda_media = mean(taxa_venda_valor)) %>% 
  arrange(taxa_venda_media) %>% 
  mutate(score_jogo_4 = as.numeric(forcats::as_factor(taxa_venda_media))) %>% 
  select(leiloeiro, taxa_venda_media, score_jogo_4) %>% 
  arrange(desc(score_jogo_4))

left_join(placar_jogo4, left_join(placar_jogo3, left_join(placar_jogo1, placar_jogo2, by = "leiloeiro"), by = "leiloeiro"), by = "leiloeiro") %>% 
  mutate(pontos_acumulados = score_jogo_1 + score_jogo_2 + score_jogo_3 + score_jogo_4) %>% 
  select(leiloeiro, taxa_venda_media, score_jogo_4, pontos_acumulados) %>% 
  arrange(desc(score_jogo_4)) %>% 
  knitr::kable()

# 5) Score dos leiloeiros
# Pra uma das 4 análises, eu vou associar uma ordem. No fim, eu só somo os pontos de cada um dos leiloeiros
# E apresento uma tabela assim:
# Leiloeiro - Score 1 - Score 2 - Score 3 - Score 4 - Posição total 
left_join(placar_jogo4, left_join(placar_jogo3, left_join(placar_jogo1, placar_jogo2, by = "leiloeiro"), by = "leiloeiro"), by = "leiloeiro") %>% 
  mutate(pontos_acumulados = score_jogo_1 + score_jogo_2 + score_jogo_3 + score_jogo_4) %>% 
  mutate(score_total = as.numeric(forcats::as_factor(pontos_acumulados))) %>% 
  arrange(desc(score_total)) %>% 
  select(leiloeiro, score_jogo_1, score_jogo_2, score_jogo_3, score_jogo_4, pontos_acumulados, score_total) %>% 
  knitr::kable()
