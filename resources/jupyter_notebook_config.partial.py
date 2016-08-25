# Configuration file for Jupyter-notebook.
# https://github.com/jupyter/docker-demo-images/blob/master/resources/jupyter_notebook_config.partial.py

# These four lines are already included in the original base notebook config
#c = get_config()
#c.NotebookApp.ip = '*'
#c.NotebookApp.open_browser = False
#c.NotebookApp.port = 8888 #9999

# Whether to trust or not X-Scheme/X-Forwarded-Proto and X-Real-Ip/X-Forwarded-
# For headerssent by the upstream reverse proxy. Necessary if the proxy handles
# SSL
c.NotebookApp.trust_xheaders = True

# Include our extra templates
c.NotebookApp.extra_template_paths = ['/srv/templates/']

# Supply overrides for the tornado.web.Application that the IPython notebook
# uses.
#c.NotebookApp.tornado_settings = {
#    'headers': {
#        'X-Frame-Options': 'ALLOW FROM nature.com'
#    },
#    'template_path':['/srv/ga/', '/srv/ipython/IPython/html',
#                     '/srv/ipython/IPython/html/templates']
#}

#c.Spawner.env_keep = ['PATH', 'PYTHONPATH', 'CONDA_ROOT', 'CONDA_DEFAULT_ENV', 'VIRTUAL_ENV', 'LANG', 'LC_ALL', 'NRN_NMODL_PATH']

# http://www.harrisgeospatial.com/Support/HelpArticlesDetail/TabId/219/ArtMID/900/ArticleID/14776/Integrating-the-Jupyter-Notebook-with-ESE.aspx
# We need to create an exception in the Jupyter Notebook security that will allow the Jupyter web page to be embedded in an HTML iframe
import notebook
c.NotebookApp.tornado_settings = {
   'headers': {
       'Content-Security-Policy': "frame-ancestors 'self' http://*.projectpyrho.org "
   },
   'static_url_prefix': 'https://cdn.jupyter.org/notebook/%s/' % notebook.__version__
}
#'http://yourhostname:9191/Jupyter/'
