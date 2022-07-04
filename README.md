# bbnj-app
Interactive app for evaluating high seas marine reserves

The old app:

https://ecoquants.shinyapps.io/bbnj/

The new app:

https://shiny.ecoquants.com/bbnj-app/

## load vector tile dynamic db

```bash
# log onto server
ssh root@ssh.calcofi.io

# get shell in postgis container
docker exec -it postgis bash

# create database bbnj
createdb -U admin bbnj

# cyberduck copy Gdrive bbnj-app/data/* via SFTP root@ssh.calcofi.io
#   to /share/data/bbnj
cd /share/data/bbnj
ogr2ogr -f PostgreSQL PG:"dbname=gis user=admin" hex_res2.geojson -nln roads

```

## notebooks

These web pages (\*.html) are typically rendered from Rmarkdown (\*.Rmd):

<!-- Jekyll rendering: https://marineenergy.github.io/apps/ -->
{% for file in site.static_files %}
  {% if file.extname == '.html' %}
* [{{ file.basename }}]({{ site.baseurl }}{{ file.path }})
  {% endif %}
{% endfor %}
