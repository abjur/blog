---
title: "O Judiciário e além: aplicações da jurimetria"
description: |
  
author:
  - name: Ricardo Feliz
    url: https://www.linkedin.com/in/ricardo-feliz-okamoto-a20344171/
date: 2023-07-24
output:
  distill::distill_article:
    self_contained: false
preview: 07-2023.png
---

Normalmente, quando ouvimos falar em jurimetria, associamos este conjunto de
métodos e práticas a análises quantitativas dos tribunais judiciais. Entretanto,
pela própria origem etimológica da palavra, vemos que a jurimetria é um fenômeno
mais amplo do que o litígio: ela trata do fenômeno do juris, isto é, daquilo que
é jurídico. E o fenômeno jurídico em muito supera o fenômeno litigioso. 

A cada pegada que o direito deixa (contratos, processos administrativos, atos
administrativos, decretos, registros), há um campo imenso para ser pesquisado. A
jurimetria, então, pode incidir nestes tantos campos que, hoje, não recebem
muita atenção. Este texto busca ampliar os horizontes das pesquisas em
jurimetria para além dos tribunais. 

## O que já tem sido feito?

O que já está razoavelmente bem consolidado na área é a pesquisa de jurimetria
em tribunais. Já avançamos e aprendemos muito sobre como tratar dados de
processos judiciais. 

Em termos práticos, começamos essas análises desbravando a mata dos tribunais
criando [robôs que extraíam os dados dos processos do site dos
tribunais](https://github.com/jjesusfilho/tjsp). Hoje, já estamos um passo mais
à frente, pois, graças ao Conselho Nacional de Justiça, temos uma forma mais
eficiente de listar os vários processos que tramitam em todos os tribunais do
país por meio do [Datajud](https://www.cnj.jus.br/sistemas/datajud/).  

Em termos metodológicos, hoje já compreendemos alguns problemas que os dados de
processos trazem. Sabemos do problema das [cifras ocultas nas Classes e nos
Assuntos](https://lab.abj.org.br/posts/2020-12-07-cifra-oculta/). Sabemos como
manejar as [Tabelas Processuais Unificadas
(TPUs)](https://github.com/abjur/tpur). Sabemos quais são as melhores práticas
para calcular o tempo dos processos, sem subestimar as estimativas. 

Com esse conhecimento sedimentado, muitas pesquisas foram realizadas, não só
pela ABJ, mas por muitos pesquisadores individuais que, semanalmente, entram em
contato com a associação para conversar sobre suas pesquisas, bem como por
muitas instituições de pesquisa. 

## O que não é feito?

A maior parte das pesquisas realizadas até aqui foram feitas utilizando-se de
dados de tribunais, para pesquisar fenômenos que acontecem dentro das paredes do
Judiciário. Mas, como já dissemos, o fenômeno jurídico é muito maior do que
isso. E, na verdade, o direito que incide na vida de todas as pessoas
diariamente não é o direito do litígio, mas sim, atos jurídicos simples que
acontecem constantemente na vida de todos. 

Prédios são erguidos porque obtiveram da Prefeitura um alvará de construção;
lojas, restaurantes, bares estão em funcionamento porque receberam um alvará de
funcionamento também; grandes eventos fecham as ruas das cidades todos os meses
porque foram autorizados pela autoridade competente. Compramos comida
diariamente, realizando contratos de compra e venda; compramos carros e
passagens de avião, ou um simples chiclete ou um misto quente por causa desse
contrato civil. Tomamos banho por causa de uma concessão realizada entre o
Estado e uma concessionária que trata a água que utilizamos todos os dias. Vemos
televisão e ouvimos ao rádio porque a União e alguns Estados possuem contratos
de concessão da emissão de rádio e TV no país. Hoje podemos fazer PIX porque o
Banco Central regulou esta matéria. E produtos chegam da China até o Brasil por
causa de contratos privados, a regulação pública sobre exportações, e regras de
comércio internacional. 

Esses infinitos alvarás que as Prefeituras do país inteiro estão emitindo podem
se tornar dados, assim como os processos judiciais se tornaram dados, se
quisermos analisar, quantitativamente, a intervenção do Estado na propriedade
privada. Os vários contratos do dia a dia de compra e venda podem se tornar
dados para analisarmos contratos civis (a dificuldade aqui seria listar todos os
contratos de compra e venda realizados em um período). As concessões de serviço
público podem ser vistas como atos passíveis de serem analisados
quantitativamente. E até mesmo os contratos de comércio internacional podem ser
analisados. 
 
## Algumas pesquisas iniciais neste campo

Assim, para além das pesquisas judiciais, podemos olhar para o Direito por meio
de atos mais simples. O foco deve sempre ser os atos jurídicos que foram
realizados e registrados. Se não há registro, não há como sabermos de sua
existência. E se algo não pode ser visto, ele não pode se tornar dado.

Em uma ocasião, já [analisamos](https://abj.org.br/pesquisas/drogas-stf/), não
processos judiciais, mas Boletins de Ocorrência, que nada mais são do que um ato
jurídico de um órgão da Administração Pública que convencionamos chamar de
Polícia Civil. 

Além disso, na ABJ, ao invés de olharmos para processos judiciais, já olhamos
para processos administrativos. A respeito deste tema, já vimos tanto processos
administrativos sancionadores, na [CVM](https://abj.org.br/pesquisas/obsmc/),
como [processos administrativos tributários]
(https://abj.org.br/pesquisas/bid-tributario/) e [decisões do
CARF](https://abj.org.br/pesquisas/carf/). 

Por fim, já olhamos também para [processos de
adoção](https://abj.org.br/pesquisas/adocao/), que, embora tenham uma faceta
judicial (e neste texto estamos procurando análises para além do Judiciário)
também se manifestam administrativamente no Conselho Nacional de Justiça.

## Para onde podemos ir?

O que não fizemos ainda? Em verdade, muita coisa. 

Várias prefeituras disponibilizam em seus sites, na sessão de Transparência,
todos os contratos que ela possui e todos os atos que ela emite (com exceção dos
contratos e atos em sigilo). Há uma oportunidade imensa a ser explorada no campo
administrativo, pois os institutos de direito público foram pouco explorados do
ponto de vista empírico-quantitativo. É possível estudar licitações, alvarás,
requisições, desapropriações e muitos outros institutos utilizando métodos
quantitativos. 

Além do Direito Administrativo, podemos vislumbrar análises quantitativas sobre
o Legislativo também. Embora as pesquisas em Ciência Política já olharem para
este campo, elas não olham para os atos do Legislativo pela forma como um
jurista olharia. Analisar dados quantitativos do processo legislativo por uma
ótica jurídica é diferente da ótica de um cientista político. 

O mais difícil, talvez, seja pensar na ampliação da jurimetria para os contratos
privados. A razão disso é simples: a maior parte destes contratos não são
acessíveis. Embora um contrato de compra e venda deixe um registro, que é o
comprovante de venda, o recibo, ou mesmo a nota fiscal, esse registro não é
público. Contratos de serviço também não são. Não há um local em que todos os
contratos devem ser registrados e armazenados. Se um pintor vai realizar um
serviço na casa de alguém, o contrato que rege essa relação de prestação de
serviço vai ser perdido. 

## Conclusão
Espero, com estas breves divagações, ter instigado quem estiver lendo. Quantas
mais pessoas estiverem pensando sobre estes problemas, mais o conhecimento
humano irá avançar e melhores serão as nossas análises sobre o fenômeno
jurídico. 
