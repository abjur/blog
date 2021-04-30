library(tidyverse)

leiloes <- obsFase3::da_leilao_tidy

# PROCESSOS) quantidade de processos por leiloeiro +  valor total daqeule leiloeiro
processos <- analise %>% 
  select(!leiloeiro) %>% 
  rename(leiloeiro = leiloeiro_usar) %>% 
  # as duas próximas linhas são pra pegar o valor total DE CADA PROCESSO
  dplyr::group_by(id_processo, leiloeiro) %>% 
  dplyr::summarise(valor_total_processo = sum(valor_avaliacao_inicial, na.rm=T)) %>% 
  # as duas próximas são pra resumir a quantidade de processos por leiloeiro e o valor médio dos processos de cada leiloeiro
  group_by(leiloeiro) %>% 
  summarise(qtd_processos = n(), vtp = mean(valor_total_processo, na.rm=T)) %>% 
  arrange(desc(qtd_processos)) %>% 
  filter(vtp > 100)

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
  group_by(leiloeiro) %>% 
  # Por que o forcats só funciona quando eu faço summarise() ?
  summarise(taxa_sucesso = taxa_sucesso) %>% 
  arrange(taxa_sucesso) %>% 
  mutate(leiloeiro = forcats::as_factor(leiloeiro)) %>% 
  ggplot() + 
    geom_col(mapping = aes(x = taxa_sucesso, y = leiloeiro))
  
# B) "Quem vende com menores perdas?" Taxa_venda (arremate / avaliacao)
# Disclaimer pro 3B: o  leiloeiro vender com menores perdas não significa que ele é responsável por isso! 
# Pode ser que o leiloeiro só aceite vender bens com grandes chances de vender
# Enfim tem várias hipóteses, e esse artigo não se prestou a testar essas hipóteses, o que exigiria algum tipo de modelagem
# A única constatação aqui é sobre o taxa de desvalorização do bem para cada leiloeiro, mas isso não é causal
sucesso  %>% 
  group_by(leiloeiro) %>% 
  summarise(media_venda = mean(taxa_venda_valor)) %>% 
  arrange(media_venda) %>% 
  mutate(leiloeiro = forcats::as_factor(leiloeiro)) %>%
  ggplot() +
    geom_col(mapping = aes(y = leiloeiro, x = media_venda))

# 4) Score dos leiloeiros
# Pra uma das 4 análises, eu vou associar uma ordem. No fim, eu só somo os pontos de cada um dos leiloeiros
# E apresento uma tabela assim:
# Leiloeiro - Score 1 - Score 2 - Score 3 - Score 4 - Posição total 

