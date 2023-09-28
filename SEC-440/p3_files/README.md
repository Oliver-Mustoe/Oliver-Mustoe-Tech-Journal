# Installation
On db01 I created the needed database (would be replicated on db02 and 03):
```
wget https://raw.githubusercontent.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/main/SEC-440/p3_files/database.sql 
mysql -u olivermustoe -p < database.sql
```

On xubuntulan I downloaded my git repository and scp'd the needed files to web02 (webapp was developed on web01 so it didnt need scp)
```
sudo apt install git -y
git clone https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal.git
scp -r Oliver-Mustoe-Tech-Journal/SEC-440/p3_files olivermustoe@10.0.5.101:
```

On web01/02 I added the following to end of `/etc/httpd/conf/httpd.conf`:
```
IncludeOptional sites-enabled/*.conf
LoadModule wsgi_module "/var/www/p3_webapp/env/lib64/python3.6/site-packages/mod_wsgi/server/mod_wsgi-py36.cpython-36m-x86_64-linux-gnu.so"
WSGIPythonHome "/var/www/p3_webapp/env"
```

On web01/02 I created a python virtual environment and installed the necessary requirements (all steps need to be done as root as /var/www is managed by root):
```
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
semanage fcontext -a -t httpd_sys_script_exec_t -s system_u "/var/www/p3_webapp(/.*)?"
restorecon -vRF /var/www/p3_webapp
setsebool -P httpd_can_network_connect_db on
systemctl restart httpd
```

And inside "app.py" set the correct DB and salt information:
![image](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/assets/71083461/cf381c74-1619-410b-9cf2-742b3a9143e4)


Big credit to https://codeshack.io/login-system-python-flask-mysql/ as they provided a lot of code that I used!!!
