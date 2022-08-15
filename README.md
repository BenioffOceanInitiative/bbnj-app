# bbnj-app

Interactive application for evaluating high seas conservation plans. Funded by Pew Trust.

Live application for internal review of results:

  https://shiny.bbnj.app/map
  
  ![](./data/app_map.png)

## Rendering Conservation Plans

### Install Software

Install the prerequisite software:

- [R](https://cran.r-project.org)
- [Gurobi](https://www.gurobi.com); see [Install Gurobi academic license for prioritizr](https://prioritizr.net/articles/gurobi_installation_guide.html)
- [Git](https://git-scm.com) (optional)
- [RStudio IDE](https://www.rstudio.com/products/rstudio/download) (optional)

### Download Scripts & Data

Download these Github repositories into _**the same folder**_:

- `BenioffOceanInitiative/bbnj-app`\
  Download [`bbnj-app-main.zip`](https://github.com/BenioffOceanInitiative/bbnj-app/archive/refs/heads/main.zip) and unzip; or use:\
  `git clone https://github.com/BenioffOceanInitiative/bbnj-app`
  
- `BenioffOceanInitiative/bbnj-scripts`\
  Download [`bbnj-scripts-main.zip`](https://github.com/BenioffOceanInitiative/bbnj-scripts/archive/refs/heads/main.zip) and unzip; or use:\
  `git clone https://github.com/BenioffOceanInitiative/bbnj-scripts`

### Run script

If using RStudio, open `bbnj-app/bbnj-app.Rproj` to set working directory (or in R: `setwd("/your/path/to/bbnj-app")`).

In RStudio, open [`generate.Rmd`](./generate.Rmd) and **Knit** (or in R standalone: `rmarkdown::render("generate.Rmd")`) after you first:

- Update paths as needed, e.g. for Google Drive (or any local folder) path `dir_gdata`.

## Notebooks

These web pages (\*.html) are typically rendered from Rmarkdown (\*.Rmd):

<!-- Jekyll rendering: https://marineenergy.github.io/apps/ -->
{% for file in site.static_files %}
  {% if file.extname == '.html' %}
* [{{ file.basename }}]({{ site.baseurl }}{{ file.path }})
  {% endif %}
{% endfor %}

## 
