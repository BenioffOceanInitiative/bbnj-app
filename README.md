# bbnj-app
Interactive app for evaluating high seas marine reserves

The old app:

https://ecoquants.shinyapps.io/bbnj/

The new app:

https://shiny.ecoquants.com/bbnj-app/

## notebooks

These web pages (\*.html) are typically rendered from Rmarkdown (\*.Rmd):

<!-- Jekyll rendering: https://marineenergy.github.io/apps/ -->
{% for file in site.static_files %}
  {% if file.extname == '.html' %}
* [{{ file.basename }}]({{ site.baseurl }}{{ file.path }})
  {% endif %}
{% endfor %}
