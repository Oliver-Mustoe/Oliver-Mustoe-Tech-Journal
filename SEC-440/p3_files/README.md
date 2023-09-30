# Installation
On db01 I created the needed database (would be replicated on db02 and 03):
```bash
wget https://raw.githubusercontent.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/main/SEC-440/p3_files/database.sql 
mysql -u olivermustoe -p < database.sql
```

On xubuntulan I downloaded my git repository and scp'd the needed files to web02 (webapp was developed on web01 so it didnt need scp)
```bash
sudo apt install git -y
git clone https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal.git
scp -r Oliver-Mustoe-Tech-Journal/SEC-440/p3_files olivermustoe@10.0.5.101:
```

On web01/02 I added the following to end of `/etc/httpd/conf/httpd.conf`:
```bash
IncludeOptional sites-enabled/*.conf
LoadModule wsgi_module "/var/www/p3_webapp/env/lib64/python3.6/site-packages/mod_wsgi/server/mod_wsgi-py36.cpython-36m-x86_64-linux-gnu.so"
WSGIPythonHome "/var/www/p3_webapp/env"
```

On web01/02 I created a python virtual environment and installed the necessary requirements (all steps need to be done as root as /var/www is managed by root):
```bash
sudo -i
yum install httpd-devel python3 python3-devel policycoreutils-python gcc -y
cp -r --context=system_u:object_r:httpd_sys_content_t:s0 /home/olivermustoe/p3_files/p3_webapp /var/www/
python3 -m venv /var/www/p3_webapp/env
source /var/www/p3_webapp/env/bin/activate
pip install -r /var/www/p3_webapp/requirements.txt
mkdir -p /etc/httpd/sites-available /etc/httpd/sites-enabled
cp /home/olivermustoe/p3_files/p3_webapp.conf /etc/httpd/sites-available/p3_webapp.conf
ln -s /etc/httpd/sites-available/p3_webapp.conf /etc/httpd/sites-enabled/p3_webapp.conf
# setup selinux settings for the installed webapp
restorecon -vRF /var/www/p3_webapp
chcon -R -h -t httpd_sys_script_exec_t /var/www/p3_webapp/env/lib64/python3.6/site-packages/mod_wsgi/server/mod_wsgi-py36.cpython-36m-x86_64-linux-gnu.so
semanage fcontext -a -t httpd_sys_script_exec_t /var/www/p3_webapp/env/lib64/python3.6/site-packages/mod_wsgi/server/mod_wsgi-py36.cpython-36m-x86_64-linux-gnu.so
setsebool -P httpd_can_network_connect_db on
```

Then update the `/home/olivermustoe/p3_files/p3_webapp.conf` with the IP of the system (either web01 or 02 depending on the system) next to the `ServerName` directive:
![image](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/assets/71083461/e64dc62b-9a09-4dea-990c-3a1bf0b5111e)

And inside `/var/www/p3_webapp/app.py` set the correct DB and salt information:  
![image](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/assets/71083461/cf381c74-1619-410b-9cf2-742b3a9143e4)

Finally restart httpd
```bash
systemctl restart httpd
```
Big credit to https://codeshack.io/login-system-python-flask-mysql/ as they provided a lot of code that I used!!!

# All sources used
- https://testdriven.io/blog/flask-sessions/
- https://computingforgeeks.com/install-python-3-on-centos-rhel-7/?expand_article=1
- https://computingforgeeks.com/how-to-install-python-3-on-centos/?expand_article=1
- https://www.digitalocean.com/community/tutorials/how-to-store-and-retrieve-data-in-mariadb-using-python-on-ubuntu-18-04
- https://dev.mysql.com/doc/connector-python/en/connector-python-installation.html
- https://vegibit.com/how-to-use-mysql-and-mariadb-in-python/
- https://flask.palletsprojects.com/en/2.3.x/deploying/apache-httpd/
- https://www.psycopg.org/psycopg3/docs/basic/params.html
- https://stackoverflow.com/questions/58633027/handling-flask-url-for-behind-nginx-reverse-proxy - maybe use
- https://www.geeksforgeeks.org/how-to-hash-passwords-in-python/#
- https://docs.python.org/3/library/hashlib.html#hashlib.sha3_512
- https://dev.mysql.com/doc/connector-python/en/connector-python-api-mysqlconnection-commit.html
- https://stackoverflow.com/questions/4271740/how-can-i-use-python-to-get-the-system-hostname
- https://plainenglish.io/blog/how-to-securely-deploy-flask-with-apache-in-a-linux-server-environment
- https://www.codementor.io/@abhishake/minimal-apache-configuration-for-deploying-a-flask-app-ubuntu-18-04-phu50a7ft
- https://tecadmin.net/deploying-flask-application-on-ubuntu-apache-wsgi/
- https://www.digitalocean.com/community/tutorials/how-to-install-the-apache-web-server-on-centos-7
- https://blog.codeasite.com/how-do-i-find-apache-http-server-log-files/
- https://flask.palletsprojects.com/en/2.3.x/deploying/mod_wsgi/
- https://flask.palletsprojects.com/en/2.3.x/deploying/proxy_fix/
- https://pypi.org/project/mod-wsgi/
- https://unix.stackexchange.com/questions/297701/how-to-label-a-newly-created-file-with-system-u
- https://serverfault.com/questions/503489/cant-connect-to-mysql-server-13-using-php-function
- https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/security-enhanced_linux/sect-security-enhanced_linux-selinux_contexts_labeling_files-persistent_changes_semanage_fcontext
- https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/security-enhanced_linux/sect-security-enhanced_linux-booleans-configuring_booleans
- https://stackoverflow.com/questions/20919771/centos-6-4-failed-to-map-segment-from-shared-object-permission-denied
- https://stackoverflow.com/questions/44914961/install-mod-wsgi-on-ubuntu-with-python-3-6-apache-2-4-and-django-1-11
