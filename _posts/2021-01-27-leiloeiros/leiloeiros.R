library(tidyverse)

leiloes <- obsFase3::da_leilao_tidy

# tem que usar o regex aqui

# 1) valor total dos processos por leiloeiro (vtp)
vtp <- analise %>% 
  dplyr::group_by(id_processo, leiloeiro) %>% 
  dplyr::summarise(valor_total_processo = sum(valor_avaliacao_inicial, na.rm=T))

# 2) quantidade de processos por leiloeiro +  valor total daqeule leiloeiro
processos <- vtp %>% 
  group_by(leiloeiro) %>% 
  summarise(qtd_processos = n(), vtp = mean(valor_total_processo, na.rm=T))

# 3) pegar o valor por bem
# A) ordenar de forma decrescente por data do edital 
# B) agrupar por id_processo e descrição
# C) slice(1)
# o perigo disso é se a gente muda o nome na descrição
# a gnt muda? muda... Então VOILÁ o REGEX

analise1 <- analise %>% 
  mutate(descricao2 = stringr::str_remove_all(descricao, stringr::regex("lote *(nº *)?[0-9.]+ *[:;-–]? *(?=[a-z0-9- ]{1,5})", TRUE)))

sucesso <- analise1 %>% 
  # Essas três funções a seguir são essenciais: elas servem para selecionar apenas 1 versão bem, se ele for repetido em vários editais
  arrange(desc(data_edital)) %>% 
  group_by(id_processo, descricao2) %>% 
  slice(1) %>% 
  # A partir disso, eu posso selecionar minhas colunas de interesse
  select(id_processo, descricao2, leiloeiro, valor_avaliacao_inicial, vendeu, valor_total_arrematado) %>% 
  # Tem alguns casos, em que a avaliação inicial é 0 (são 50 casos). Isso acontece, mas quero excluir isso. São bens sem valor comercial algum
  filter(valor_avaliacao_inicial > 0)
  rename(descricao = descricao2)
  mutate(valor_total_arrematado = tidyr::replace_na(0)) %>% 
  mutate(taxa_venda = valor_total_arrematado / valor_avaliacao_inicial) %>%
  # mutate(valor_total_arrematado = ifelse(vendeu == "nao", NA, ~valor_total_arrematado))
  filter(taxa_venda <= 10)
  
sucesso_leiloeiro <- sucesso %>% 
  group_by(leiloeiro, vendeu) %>% 
  summarise(sucesso_absoluto = n())
  
