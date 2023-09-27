import logging
import sys
logging.basicConfig(stream=sys.stderr)
sys.path.insert(0,'/var/www/p3_webapp')
sys.path.insert(0,'/var/wwwp3_webapp/env/lib/python3.6/site-packages/')
from app import app as application
