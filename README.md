# blog

Repositório para produção de textos da ABJ

# Instruções básicas

- Um texto deve ficar dentro da pasta `_posts`
- Eventualmente evoluiremos o repo para um blog do tipo `distill`
- Um texto é um Rmd simples
- Textos que demoram para renderizar são desencorajados.
- Não precisamos rodar grandes bases de dados on the fly:
    - Guardar gráficos gerados em imagens
    - Deixar bases de dados na máquina
- Seguir essas instruções: https://rstudio.github.io/distill/blog.html#creating-a-blog
    - Usar `distill::create_post`
    - Rodar o post com `ctrl+shift+k`
    - Para renderizar: `rmarkdown::render_site()` ou `ctrl+shift+b`
- Inspiração: rstudio tensorflow blog