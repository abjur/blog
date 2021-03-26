library(tidyverse)

leiloes <- obsFase3::da_leilao_tidy

# Todos leiloeiros ---------------
# selecionar todas as grafias possíveis de leiloeiros
todos_leiloeiros <- leiloes %>% 
  group_by(id_leiloeiro) %>% 
  select(leiloeiro, cpf_cnpj, id_leiloeiro, modalidade) %>% 
  filter(modalidade == "leilao") %>%
  unique() %>%  
  arrange(leiloeiro)

# Eu vou primeiro arrumar a base todos_leiloeiros, como forma teste. Quando eu conseguir arrumar essa base, eu vou pegar o código e repetir ele pra "leilões"
todos_leiloeiros <- todos_leiloeiros %>% 
  dplyr::mutate(
    leiloeiro_arrumado = dplyr::case_when(
      str_detect(leiloeiro, regex("ron.*faro|ron.*mon", ignore_case=TRUE)) ~ "Ronaldo Sérgio Montenegro Rodrigues Faro",
      str_detect(leiloeiro, regex("Cerello", ignore_case=TRUE)) ~ "Fernando José Cerello Gonçalves Pereira",
      str_detect(leiloeiro, regex("Alexandridis", ignore_case=TRUE)) ~ "Georgios José Ilias Bernabé Alexandridis",
      str_detect(leiloeiro, regex("Moretto", ignore_case=TRUE)) ~ "Gustavo Moretto Guimarães de Oliveira",
      str_detect(leiloeiro, regex("Thais Silva", ignore_case=TRUE)) ~ "Thais Silva Moreira de Sousa",
      str_detect(leiloeiro, regex("Macedo Campos", ignore_case=TRUE)) ~ "André Macedo Campos Toledo",
      str_detect(leiloeiro, regex("Sato", ignore_case=TRUE)) ~ "Antonio Hissao Sato Junio",
      str_detect(leiloeiro, regex("Wendell", ignore_case=TRUE)) ~ "Wendell Marcel Calixto Félix",
      str_detect(leiloeiro, regex("badolato", ignore_case=TRUE)) ~ "Cezar Augusto Badolato Silva",
      str_detect(leiloeiro, regex("Dannae", ignore_case=TRUE)) ~ "Dannae Vieira Avila",
      str_detect(leiloeiro, regex("Dora Plat", ignore_case=TRUE)) ~ "Dora Plat",
      str_detect(leiloeiro, regex("Zukerman", ignore_case=TRUE)) ~ "Fabio Zukerman",
      str_detect(leiloeiro, regex("Samuel", ignore_case=TRUE)) ~ "Gustavo Cristiano Samuel dos Reis",
      str_detect(leiloeiro, regex("Moy", ignore_case=TRUE)) ~ "Renato Schlobach Moysés",
      # Gold Leilões e Uilan Aparecido são a mesma coisa
      str_detect(leiloeiro, regex("Uilian", ignore_case=TRUE)) ~ "Uilian Aparecido da Silva",
      str_detect(cpf_cnpj, "18.067.544/0001-36") ~ "Gold Leilões - Gold Intermediação de Ativos LTDA",
      str_detect(leiloeiro, regex("Villa Nova", ignore_case=TRUE)) ~ "Sérgio Villa Nova de Freitas",
      str_detect(leiloeiro, regex("Boya", ignore_case=TRUE)) ~ "Eduardo Jordão Boyadjian",
      str_detect(leiloeiro, regex("Franklin", ignore_case=TRUE)) ~ "Renata Franklin Simões",
      str_detect(leiloeiro, regex("Cardoso", ignore_case=TRUE)) ~ "Danilo Cardoso da Silva",
      str_detect(leiloeiro, regex("Fidalgo", ignore_case=TRUE)) ~ "Douglas José Fidalgo",
      str_detect(leiloeiro, regex("Affonso", ignore_case=TRUE)) ~ "Alfio Carlos Affonso Zalli Neto",
      str_detect(leiloeiro, regex("Mega", ignore_case=TRUE)) ~ "Mega Leilões",
      str_detect(leiloeiro, regex("casa reis", ignore_case=TRUE)) ~ "Casa Reis Leilões",
      str_detect(leiloeiro, regex("juiz|Furtado|adm|AJ|trustee", ignore_case=TRUE)) ~ "não leiloeiro",
      str_detect(leiloeiro, regex("juiz", ignore_case=TRUE)) ~ "zjuiz",
      str_detect(cpf_cnpj, "15.086.104/0001") ~ "Lance Alienações Eletrônicas LTDA",
      # HastaPublicaBR e Euclides Maraschi Junior são a mesma coisa
      str_detect(cpf_cnpj, "144.470.838-41") ~ "Euclides Maraschi Junior",
      str_detect(cpf_cnpj, "16.792.811/0001-02") ~ "HastaPublicaBR Promotora de Eventos LTDA",
      str_detect(cpf_cnpj, "19.962.222/0001-13") ~ "D1Lance Intermediação de Ativos LTDA",
      str_detect(cpf_cnpj, "537.866.888-34") ~ "Ronaldo Milan", 
    ),
    
    cpf_cnpj = dplyr::case_when(
      leiloeiro_arrumado == "Ronaldo Sérgio Montenegro Rodrigues Faro" ~ "08046824887",
      leiloeiro_arrumado == "Fernando José Cerello Gonçalves Pereira" ~ "21989241883",
      leiloeiro_arrumado == "Georgios José Ilias Bernabé Alexandridis" ~ "25419334879",
      leiloeiro_arrumado == "Gustavo Moretto Guimarães de Oliveira" ~ " 28034586838",
      leiloeiro_arrumado == "Thais Silva Moreira de Sousa" ~ " 36171181862",
      leiloeiro_arrumado == "André Macedo Campos Toledo" ~ "",
      leiloeiro_arrumado == "Antonio Hissao Sato Junio" ~ "27110999890",
      leiloeiro_arrumado == "Wendell Marcel Calixto Félix" ~ "16239428884",
      leiloeiro_arrumado == "Cezar Augusto Badolato Silva" ~ "07538221808",
      leiloeiro_arrumado == "Dannae Vieira Avila" ~ "36947855829",
      leiloeiro_arrumado == "Dora Plat" ~ "07080906806",
      leiloeiro_arrumado == "Fabio Zukerman" ~ "21575323826",
      leiloeiro_arrumado == "Gustavo Cristiano Samuel dos Reis" ~ "27358397886",
      leiloeiro_arrumado == "Renato Schlobach Moysés" ~ "09141676858",
      leiloeiro_arrumado == "Uilian Aparecido da Silva" ~ "11645230821",
      leiloeiro_arrumado == "Sérgio Villa Nova de Freitas" ~ "33201862800",
      leiloeiro_arrumado == "Eduardo Jordão Boyadjian" ~ "12634759819",
      leiloeiro_arrumado == "Renata Franklin Simões" ~ "20538037890",
      leiloeiro_arrumado == "Danilo Cardoso da Silva" ~ "31191072800",
      leiloeiro_arrumado == "Alfio Carlos Affonso Zalli Neto" ~ " 39681014804",
      leiloeiro_arrumado == "Douglas José Fidalgo" ~ "16499659827",
      leiloeiro_arrumado == "Mega Leilões" ~ "03122040000102",
      leiloeiro_arrumado == "Casa Reis Leilões" ~ " 19116554000187",
      leiloeiro_arrumado == "Lance Alienações Eletrônicas LTDA" ~ "15086104000138",
      leiloeiro_arrumado == "Euclides Maraschi Junior" ~ "14447083841",
      leiloeiro_arrumado == "HastaPublicaBR Promotora de Eventos LTDA" ~ "16792811000102",
      leiloeiro_arrumado == "Gold Leilões - Gold Intermediação de Ativos LTDA" ~ "18067544000136",
      leiloeiro_arrumado == "D1Lance Intermediação de Ativos LTDA" ~ "19962222000113",
      leiloeiro_arrumado == "Ronaldo Milan" ~ "53786688834",
      TRUE ~ cpf_cnpj
    ),
    
    id_leiloeiro = dplyr::case_when(
      leiloeiro_arrumado == "Ronaldo Sérgio Montenegro Rodrigues Faro" ~ "6331",
      leiloeiro_arrumado == "Fernando José Cerello Gonçalves Pereira" ~ "5406",
      leiloeiro_arrumado == "Georgios José Ilias Bernabé Alexandridis" ~ "7633",
      leiloeiro_arrumado == "Gustavo Moretto Guimarães de Oliveira" ~ "7979",
      leiloeiro_arrumado == "Thais Silva Moreira de Sousa" ~ "34064",
      leiloeiro_arrumado == "André Macedo Campos Toledo" ~ "",
      leiloeiro_arrumado == "Antonio Hissao Sato Junio" ~ "858",
      leiloeiro_arrumado == "Wendell Marcel Calixto Félix" ~ "23601",
      leiloeiro_arrumado == "Cezar Augusto Badolato Silva" ~ "5393",
      leiloeiro_arrumado == "Dannae Vieira Avila" ~ "28025",
      leiloeiro_arrumado == "Dora Plat" ~ "5608",
      leiloeiro_arrumado == "Fabio Zukerman" ~ "5508",
      leiloeiro_arrumado == "Gustavo Cristiano Samuel dos Reis" ~ "5596",
      leiloeiro_arrumado == "Renato Schlobach Moysés" ~ "466",
      leiloeiro_arrumado == "Uilian Aparecido da Silva" ~ "26542",
      leiloeiro_arrumado == "Sérgio Villa Nova de Freitas" ~ "5604",
      leiloeiro_arrumado == "Eduardo Jordão Boyadjian" ~ "924",
      leiloeiro_arrumado == "Renata Franklin Simões" ~ "669",
      leiloeiro_arrumado == "Danilo Cardoso da Silva" ~ "7794",
      leiloeiro_arrumado == "Alfio Carlos Affonso Zalli Neto" ~ "21977",
      leiloeiro_arrumado == "Douglas José Fidalgo" ~ "5535",
      leiloeiro_arrumado == "Mega Leilões" ~ "5426",
      leiloeiro_arrumado == "Casa Reis Leilões" ~ " 5448",
      leiloeiro_arrumado == "Lance Alienações Eletrônicas LTDA" ~ "5937",
      leiloeiro_arrumado == "Euclides Maraschi Junior" ~ "5665",
      leiloeiro_arrumado == "HastaPublicaBR Promotora de Eventos LTDA" ~ "1057",
      leiloeiro_arrumado == "Gold Leilões - Gold Intermediação de Ativos LTDA" ~ "620",
      leiloeiro_arrumado == "D1Lance Intermediação de Ativos LTDA" ~ "5366",
      leiloeiro_arrumado == "Ronaldo Milan" ~ "29112",
      TRUE ~ id_leiloeiro
    )
  ) 

# analise -------------------
analise <- leiloes %>% 
  dplyr::filter(modalidade == "leilao") %>% 
  dplyr::mutate(
    leiloeiro = dplyr::case_when(
      str_detect(leiloeiro, regex("ron.*faro|ron.*mon", ignore_case=TRUE)) ~ "Ronaldo Sérgio Montenegro Rodrigues Faro",
      str_detect(leiloeiro, regex("Cerello", ignore_case=TRUE)) ~ "Fernando José Cerello Gonçalves Pereira",
      str_detect(leiloeiro, regex("Alexandridis", ignore_case=TRUE)) ~ "Georgios José Ilias Bernabé Alexandridis",
      str_detect(leiloeiro, regex("Moretto", ignore_case=TRUE)) ~ "Gustavo Moretto Guimarães de Oliveira",
      str_detect(leiloeiro, regex("Thais Silva", ignore_case=TRUE)) ~ "Thais Silva Moreira de Sousa",
      str_detect(leiloeiro, regex("Macedo Campos", ignore_case=TRUE)) ~ "André Macedo Campos Toledo",
      str_detect(leiloeiro, regex("Sato", ignore_case=TRUE)) ~ "Antonio Hissao Sato Junio",
      str_detect(leiloeiro, regex("Wendell", ignore_case=TRUE)) ~ "Wendell Marcel Calixto Félix",
      str_detect(leiloeiro, regex("badolato", ignore_case=TRUE)) ~ "Cezar Augusto Badolato Silva",
      str_detect(leiloeiro, regex("Dannae", ignore_case=TRUE)) ~ "Dannae Vieira Avila",
      str_detect(leiloeiro, regex("Dora Plat", ignore_case=TRUE)) ~ "Dora Plat",
      str_detect(leiloeiro, regex("Zukerman", ignore_case=TRUE)) ~ "Fabio Zukerman",
      str_detect(leiloeiro, regex("Samuel", ignore_case=TRUE)) ~ "Gustavo Cristiano Samuel dos Reis",
      str_detect(leiloeiro, regex("Moy", ignore_case=TRUE)) ~ "Renato Schlobach Moysés",
      # Gold Leilões e Uilan Aparecido são a mesma coisa
      str_detect(leiloeiro, regex("Uilian", ignore_case=TRUE)) ~ "Uilian Aparecido da Silva",
      str_detect(cpf_cnpj, "18.067.544/0001-36") ~ "Gold Leilões - Gold Intermediação de Ativos LTDA",
      str_detect(leiloeiro, regex("Villa Nova", ignore_case=TRUE)) ~ "Sérgio Villa Nova de Freitas",
      str_detect(leiloeiro, regex("Boya", ignore_case=TRUE)) ~ "Eduardo Jordão Boyadjian",
      str_detect(leiloeiro, regex("Franklin", ignore_case=TRUE)) ~ "Renata Franklin Simões",
      str_detect(leiloeiro, regex("Cardoso", ignore_case=TRUE)) ~ "Danilo Cardoso da Silva",
      str_detect(leiloeiro, regex("Fidalgo", ignore_case=TRUE)) ~ "Douglas José Fidalgo",
      str_detect(leiloeiro, regex("Affonso", ignore_case=TRUE)) ~ "Alfio Carlos Affonso Zalli Neto",
      str_detect(leiloeiro, regex("Mega", ignore_case=TRUE)) ~ "Mega Leilões",
      str_detect(leiloeiro, regex("casa reis", ignore_case=TRUE)) ~ "Casa Reis Leilões",
      str_detect(leiloeiro, regex("juiz|Furtado|adm|AJ|trustee", ignore_case=TRUE)) ~ "não leiloeiro",
      str_detect(leiloeiro, regex("juiz", ignore_case=TRUE)) ~ "zjuiz",
      str_detect(cpf_cnpj, "15.086.104/0001") ~ "Lance Alienações Eletrônicas LTDA",
      # HastaPublicaBR e Euclides Maraschi Junior são a mesma coisa
      str_detect(cpf_cnpj, "144.470.838-41") ~ "Euclides Maraschi Junior",
      str_detect(cpf_cnpj, "16.792.811/0001-02") ~ "HastaPublicaBR Promotora de Eventos Ltda",
      str_detect(cpf_cnpj, "19.962.222/0001-13") ~ "D1Lance Intermediação de Ativos LTDA",
      str_detect(cpf_cnpj, "537.866.888-34") ~ "Ronaldo Milan", 
    ),
    
    cpf_cnpj = dplyr::case_when(
      leiloeiro == "Ronaldo Sérgio Montenegro Rodrigues Faro" ~ "08046824887",
      leiloeiro == "Fernando José Cerello Gonçalves Pereira" ~ "21989241883",
      leiloeiro == "Georgios José Ilias Bernabé Alexandridis" ~ "25419334879",
      leiloeiro == "Gustavo Moretto Guimarães de Oliveira" ~ " 28034586838",
      leiloeiro == "Thais Silva Moreira de Sousa" ~ " 36171181862",
      leiloeiro == "André Macedo Campos Toledo" ~ "",
      leiloeiro == "Antonio Hissao Sato Junio" ~ "27110999890",
      leiloeiro == "Wendell Marcel Calixto Félix" ~ "16239428884",
      leiloeiro == "Cezar Augusto Badolato Silva" ~ "07538221808",
      leiloeiro == "Dannae Vieira Avila" ~ "36947855829",
      leiloeiro == "Dora Plat" ~ "07080906806",
      leiloeiro == "Fabio Zukerman" ~ "21575323826",
      leiloeiro == "Gustavo Cristiano Samuel dos Reis" ~ "27358397886",
      leiloeiro == "Renato Schlobach Moysés" ~ "09141676858",
      leiloeiro == "Uilian Aparecido da Silva" ~ "11645230821",
      leiloeiro == "Sérgio Villa Nova de Freitas" ~ "33201862800",
      leiloeiro == "Eduardo Jordão Boyadjian" ~ "12634759819",
      leiloeiro == "Renata Franklin Simões" ~ "20538037890",
      leiloeiro == "Danilo Cardoso da Silva" ~ "31191072800",
      leiloeiro == "Alfio Carlos Affonso Zalli Neto" ~ " 39681014804",
      leiloeiro == "Douglas José Fidalgo" ~ "16499659827",
      leiloeiro == "Mega Leilões" ~ "03122040000102",
      leiloeiro == "Casa Reis Leilões" ~ " 19116554000187",
      leiloeiro == "Lance Alienações Eletrônicas LTDA" ~ "15086104000138",
      leiloeiro == "Euclides Maraschi Junior" ~ "14447083841",
      leiloeiro == "HastaPublicaBR Promotora de Eventos Ltda" ~ "16792811000102",
      leiloeiro == "Gold Leilões - Gold Intermediação de Ativos LTDA" ~ "18067544000136",
      leiloeiro == "D1Lance Intermediação de Ativos LTDA" ~ "19962222000113",
      leiloeiro == "Ronaldo Milan" ~ "53786688834",
      TRUE ~ cpf_cnpj
    ),
    
    id_leiloeiro = dplyr::case_when(
      leiloeiro == "Ronaldo Sérgio Montenegro Rodrigues Faro" ~ "6331",
      leiloeiro == "Fernando José Cerello Gonçalves Pereira" ~ "5406",
      leiloeiro == "Georgios José Ilias Bernabé Alexandridis" ~ "7633",
      leiloeiro == "Gustavo Moretto Guimarães de Oliveira" ~ "7979",
      leiloeiro == "Thais Silva Moreira de Sousa" ~ "34064",
      leiloeiro == "André Macedo Campos Toledo" ~ "",
      leiloeiro == "Antonio Hissao Sato Junio" ~ "858",
      leiloeiro == "Wendell Marcel Calixto Félix" ~ "23601",
      leiloeiro == "Cezar Augusto Badolato Silva" ~ "5393",
      leiloeiro == "Dannae Vieira Avila" ~ "28025",
      leiloeiro == "Dora Plat" ~ "5608",
      leiloeiro == "Fabio Zukerman" ~ "5508",
      leiloeiro == "Gustavo Cristiano Samuel dos Reis" ~ "5596",
      leiloeiro == "Renato Schlobach Moysés" ~ "466",
      leiloeiro == "Uilian Aparecido da Silva" ~ "26542",
      leiloeiro == "Sérgio Villa Nova de Freitas" ~ "5604",
      leiloeiro == "Eduardo Jordão Boyadjian" ~ "924",
      leiloeiro == "Renata Franklin Simões" ~ "669",
      leiloeiro == "Danilo Cardoso da Silva" ~ "7794",
      leiloeiro == "Alfio Carlos Affonso Zalli Neto" ~ "21977",
      leiloeiro == "Douglas José Fidalgo" ~ "5535",
      leiloeiro == "Mega Leilões" ~ "5426",
      leiloeiro == "Casa Reis Leilões" ~ " 5448",
      leiloeiro == "Lance Alienações Eletrônicas LTDA" ~ "5937",
      leiloeiro == "Euclides Maraschi Junior" ~ "5665",
      leiloeiro == "HastaPublicaBR Promotora de Eventos Ltda" ~ "1057",
      leiloeiro == "Gold Leilões - Gold Intermediação de Ativos LTDA" ~ "620",
      leiloeiro == "D1Lance Intermediação de Ativos LTDA" ~ "5366",
      leiloeiro == "Ronaldo Milan" ~ "29112",
      TRUE ~ id_leiloeiro
    )
  ) #%>% 
  # o unite() faz o que o paste() fazia, mas ele já deleta as colunas antigas + ele tem um sep = "_" por default
  #unite(leiloeiro_infos, leiloeiro, cpf_cnpj, id_leiloeiro)

# ----------
# valor total dos processos por leiloeiro (vtp)
vtp <- analise %>% 
  group_by(id_processo, leiloeiro) %>% 
  unique() %>% 
  summarise(valor_total_processo = sum(valor_avaliacao_inicial, na.rm=T))

# quantidade de processos por leiloeiro com o valor total que cada leiloeiro mexe
processos <- analise %>% 
  select(leiloeiro, id_processo) %>%  
  unique() %>% 
  group_by(leiloeiro) %>% 
  summarise(qtd_processos = n())

a <- full_join(vtp, processos, by = "id_processo")
# quantidade de processos por leiloeiro
processos <- vtp %>% 
  unique() %>% 
  group_by(leiloeiro) %>% 
  summarise(qtd_processos = n(), vtp = mean(valor_total_processo, na.rm=T))

processos %>% 
  slice(18:26)
