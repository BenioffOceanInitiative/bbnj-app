# bbnj-app

Interactive application for evaluating high seas conservation plans. Funded by Pew Trust.

Live application for internal review of results:

https://shiny.bbnj.app/map

## Rendering Conservation Plans

### Install Software

Install the prerequisite software:

- [R](https://cran.r-project.org)
- [Gurobi](https://www.gurobi.com); see [Install Gurobi academic license for prioritizr](https://prioritizr.net/articles/gurobi_installation_guide.html)
- [Git](https://git-scm.com) (optional)
- [RStudio IDE](https://www.rstudio.com/products/rstudio/download) (optional)

### Download Scripts & Data

Download and unzip these Github repositories into the same folder:

- [BenioffOceanInitiative/`bbnj-app`](https://github.com/BenioffOceanInitiative/bbnj-app/archive/refs/heads/main.zip)
- [BenioffOceanInitiative/`bbnj-scripts`](https://github.com/BenioffOceanInitiative/bbnj-scripts/archive/refs/heads/master.zip)

### Run script

If using RStudio, open `bbnj-app/bbnj-app.Rproj` to set working directory (or in R: `setwd("/your/path/to/bbnj-app")`).

In RStudio, Knit `generate.Rmd`. (in R: `rmarkdown::render("generate.Rmd")`) after first:

- Update paths as needed, eg for Google Drive: `dir_gdata`.


## Notebooks

These web pages (\*.html) are typically rendered from Rmarkdown (\*.Rmd):

<!-- Jekyll rendering: https://marineenergy.github.io/apps/ -->
{% for file in site.static_files %}
  {% if file.extname == '.html' %}
* [{{ file.basename }}]({{ site.baseurl }}{{ file.path }})
  {% endif %}
{% endfor %}

## 