library(tidyverse)

leiloes <- obsFase3::da_leilao_tidy

cores_abj <- viridis::viridis(2, 1, .2, .8)

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
  
# JOGOS =============
# JOgo 1) Quantidade de processos por leiloeiro -------------
# 1.1) Plot 1
media1 <- mean(processos$qtd_processos)

processos %>% 
  mutate(leiloeiro = forcats::fct_reorder(leiloeiro, qtd_processos)) %>% 
  ggplot() +
    geom_col(mapping = aes(x = qtd_processos, y = leiloeiro), fill=cores_abj[1]) +
    geom_vline(xintercept=media1, size=.5, color="red") + 
    labs(x="quantidade de processos", y="leiloeiros") +
    theme_minimal()

# 1.2) Placar 1
placar1 <- processos %>% 
  mutate(score_jogo_1 = as.numeric(forcats::as_factor(qtd_processos))) %>%
  mutate(score_jogo_1 = score_jogo_1 / 9) %>% # o valor máximo foi 9
  select(leiloeiro, qtd_processos, score_jogo_1) %>% 
  arrange(desc(score_jogo_1))

placar1 %>% 
  knitr::kable(digits=2, col.names = gsub("[_]", " ", names(placar1))) %>% 
  kableExtra::scroll_box(height = "500px", width = "550px")

# Jogo 2) Valor médio de cada leiloeiro
# 2.1) Plot
media2 <- mean(processos$vtp)

processos %>% 
  mutate(leiloeiro = forcats::fct_reorder(leiloeiro, vtp)) %>% 
  ggplot() +
    geom_col(mapping = aes(x = vtp, y = leiloeiro), fill=cores_abj[1]) +
    geom_vline(xintercept = media2, size=.5, color="red") +
    scale_x_log10(labels = scales::label_number_si(), breaks = 10^c(1:8)) +
    labs(x = "valor médio por processo", y="leiloeiros") +
    theme_minimal()

# 2.2) PLacar 2
preplacar2 <- processos %>% 
  mutate(score_jogo_2 = as.numeric(forcats::as_factor(vtp))) %>% 
  mutate(score_jogo_2 = score_jogo_2 / 24) %>% # o valor máximo foi 24
  select(leiloeiro, vtp, score_jogo_2) %>% 
  arrange(desc(score_jogo_2))

placar2 <- left_join(placar1, preplacar2, by = "leiloeiro") %>% 
  mutate(pontos_acumulados = score_jogo_1 + score_jogo_2) %>%
  select(leiloeiro, vtp, score_jogo_2, score_jogo_2, pontos_acumulados) %>%
  rename(valor_medio_processo = vtp) %>%
  mutate(valor_medio_processo = formattable::currency(
    valor_medio_processo, "R$", big.mark = ".", decimal.mark = ","
  )) %>% 
  arrange(desc(score_jogo_2))

knitr::kable(placar2, digits=2, col.names = gsub("[_]", " ", names(placar2))) %>% 
  kableExtra::scroll_box(height = "500px", width = "100%")

# Jogo 3) Taxa de sucesso
# 3.1) Plot
#"Quem consegue vender mais?" Total de bens em que vende == SIM / Total de bens relacionados àquele leiloeiro 
jogo3 <- sucesso %>% 
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
  mutate(leiloeiro = forcats::fct_reorder(leiloeiro, taxa_sucesso))

media3 <- mean(jogo3$taxa_sucesso)

ggplot(jogo3) + 
  geom_col(mapping = aes(x = taxa_sucesso, y = leiloeiro), fill=cores_abj[1]) +
  geom_vline(xintercept=media3, size=.5, color="red") +
  labs(x="taxa de sucesso", y="leiloeiros") +
  theme_minimal()
  
# 3.2) Placar 3
preplacar3 <- jogo3 %>% 
  mutate(score_jogo_3 = as.numeric(forcats::as_factor(taxa_sucesso))) %>%
  mutate(score_jogo_3 = score_jogo_3 / 18) %>% # o valor máxim foi 18
  select(leiloeiro, taxa_sucesso, score_jogo_3) %>% 
  arrange(desc(score_jogo_3))

placar3 <- left_join(preplacar3, placar2, by = "leiloeiro") %>% 
  mutate(pontos_acumulados = pontos_acumulados + score_jogo_3) %>%
  select(leiloeiro, taxa_sucesso, score_jogo_3, pontos_acumulados) %>% 
  arrange(desc(score_jogo_3))

knitr::kable(placar3, digits=2, col.names = gsub("[_]", " ", names(placar3))) %>% 
  kableExtra::scroll_box(height = "500px", width = "100%")

# Jogo 4) Taxa de venda média
# "Quem vende com menores perdas?" Taxa_venda (arremate / avaliacao)
# Disclaimer pro 3B: o  leiloeiro vender com menores perdas não significa que ele é responsável por isso! 
# Pode ser que o leiloeiro só aceite vender bens com grandes chances de vender
# Enfim tem várias hipóteses, e esse artigo não se prestou a testar essas hipóteses, o que exigiria algum tipo de modelagem
# A única constatação aqui é sobre o taxa de desvalorização do bem para cada leiloeiro, mas isso não é causal
# 4.1) Plot
jogo4 <- sucesso  %>% 
  filter(vendeu == "sim") %>% 
  group_by(leiloeiro) %>% 
  summarise(taxa_venda_media = mean(taxa_venda_valor)) %>% 
  mutate(leiloeiro = forcats::fct_reorder(leiloeiro, taxa_venda_media))

media4 <- mean(jogo4$taxa_venda_media)

ggplot(jogo4) +
  geom_col(mapping = aes(y = leiloeiro, x = taxa_venda_media), fill=cores_abj[1]) +
  geom_vline(xintercept = media4, size=.5, color="red") +
  labs(x="taxa de venda média",y="leiloeiros") +
  theme_minimal()

# 4.2) Placar 4
preplacar4 <- sucesso %>% 
  group_by(leiloeiro) %>% 
  summarise(taxa_venda_media = mean(taxa_venda_valor)) %>%
  arrange(taxa_venda_media) %>% 
  mutate(score_jogo_4 = as.numeric(forcats::as_factor(taxa_venda_media))) %>% 
  mutate(score_jogo_4= score_jogo_4 / 23) %>% 
  select(leiloeiro, taxa_venda_media, score_jogo_4) %>% 
  arrange(desc(score_jogo_4))

placar4 <- left_join(preplacar4, placar3, by = "leiloeiro") %>% 
  mutate(pontos_acumulados = pontos_acumulados + score_jogo_4) %>%
  select(leiloeiro, taxa_venda_media, score_jogo_4, pontos_acumulados) %>% 
  arrange(desc(score_jogo_4))

knitr::kable(placar4, digits=2, col.names = gsub("[.]", " ", names(placar4))) %>% 
  kableExtra::scroll_box(height = "500px", width = "100%")

# 5) Score Final 
# Pra uma das 4 análises, eu vou associar uma ordem. No fim, eu só somo os pontos de cada um dos leiloeiros
# E apresento uma tabela assim:
# Leiloeiro - Score 1 - Score 2 - Score 3 - Score 4 - Posição total 
placar_final <- left_join(preplacar4, left_join(preplacar3, left_join(preplacar2, placar1, by = "leiloeiro"), by = "leiloeiro"), by = "leiloeiro") %>% 
  mutate(pontos_acumulados = score_jogo_1 + score_jogo_2 + score_jogo_3 + score_jogo_4) %>% 
  mutate(colocacao_final = forcats::as_factor(pontos_acumulados)) %>% 
  mutate(colocacao_final = fct_rev(colocacao_final)) %>% 
  mutate(colocacao_final = as.numeric((colocacao_final))) %>% 
  arrange(colocacao_final) %>% 
  select(leiloeiro, score_jogo_1, score_jogo_2, score_jogo_3, score_jogo_4, pontos_acumulados, colocacao_final) %>% 
  rename(jogo_1 = score_jogo_1,
         jogo_2 = score_jogo_2,
         jogo_3 = score_jogo_3,
         jogo_4 = score_jogo_4)

placar_final %>% 
  knitr::kable(digits=2, col.names = gsub("[_]", " ", names(placar_final))) %>% 
  kableExtra::row_spec(1:3, bold=TRUE, background=cores_abj[2]) %>% 
  kableExtra::scroll_box(height = "500px", width = "100%")
