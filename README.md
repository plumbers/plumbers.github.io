$ mkdocs serve
$ mkdocs build

sudo nginx -c /usr/repo/plumbers.github.io/nginx.conf
sudo killall -9 nginx

pip install mkdocs-git-revision-date-localized-plugin
#pip install mkdocs-custom-tags-attributes --upgrade
pip install git+https://github.com/jldiaz/mkdocs-plugin-tags.git


auto-Table Of Content in nav:
pip install mkdocs-awesome-pages-plugin

    
extra plugins: cards, Gantt, OpenAPI
    pip install neoteroi-mkdocs
    https://github.com/Neoteroi/mkdocs-plugins

---
title: Tags
---
# Contents grouped by tag

{% for tag, pages in tags %}

## <span class="tag">{{tag}}</span>
{%  for page in pages %}
  * [{{page.title}}]({{page.filename}})
{% endfor %}

{% endfor %}

JavaScript keyword highlighting. Mark text with with options that fit every application. Also available as jQuery plugin.
    https://github.com/julmot/mark.js

https://www.webpro.nl/articles/how-to-add-search-to-your-static-site
https://artem.krylysov.com/blog/2020/07/28/lets-build-a-full-text-search-engine/
minisearch:
    https://lucaongaro.eu/blog/2019/01/30/minisearch-client-side-fulltext-search-engine.html
    https://github.com/lucaong/minisearch

tinysearch:
    https://endler.dev/2019/tinysearch
    https://github.com/tinysearch/tinysearch    

cite:
    https://www.npmjs.com/package/citeproc-cite-service/v/2.1.37
    https://www.google.com/search?q=javascript+%22citation+management%22+open+source+github&ei=dcWVY-3jCLOQwPAPr_iuyAc&ved=0ahUKEwit8tqhwfH7AhUzCBAIHS-8C3kQ4dUDCBA&uact=5&oq=javascript+%22citation+management%22+open+source+github&gs_lcp=Cgxnd3Mtd2l6LXNlcnAQAzIFCAAQogQyBQgAEKIEMgUIABCiBDIFCAAQogRKBAhBGABKBAhGGABQAFjnJGCjJmgAcAF4AIABhwGIAboMkgEEMC4xM5gBAKABAcABAQ&sclient=gws-wiz-serp
    https://github.com/vict0rsch/PaperMemory
    https://github.com/JabRef/cloudref
    https://github.com/DavidRalph/search-mendeley
 
https://www.webpro.nl/articles/how-to-add-search-to-your-static-site
https://github.com/nextapps-de/flexsearch
    
    