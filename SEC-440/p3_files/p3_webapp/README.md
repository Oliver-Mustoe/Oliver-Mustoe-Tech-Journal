# Installation
On db01 I created the needed database (would be replicated on db02 and 03):
```
wget https://raw.githubusercontent.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/main/SEC-440/p3_files/database.sql 
mysql -u olivermustoe -p < database.sql
```

On xubuntulan I downloaded my git repository and scp'd the needed files to web02 (webapp was developed on web01
```
sudo apt install git -y
git clone https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal.git
cp Oliver-Mustoe-Tech-Journal/SEC-440/p3_files/p3_webapp olivermustoe@10.0.5.101:
```

On web01/02 I created a python virtual environment and installed the necessary requirements:
```
sudo yum install httpd-devel python3 policycoreutils-python -y
cp p3_webapp /var/www/
python3 -m venv /var/www/p3_webapp/env
source /var/www/p3_webapp/env/bin/activate
pip install /var/www/p3_webapp/requirements.txt
mkdir -p /etc/httpd/sites-available /etc/httpd/sites-enabled
sudo cp p3_webapp/p3_webapp.conf /etc/httpd/sites-available/p3_webapp.conf
sudo ln -s /etc/httpd/sites-available/p3_webapp.conf /etc/httpd/sites-enabled/p3_webapp.conf
# setup selinux settings for the installed webapp
sudo semanage fcontext -a -t httpd_sys_content_t -s system_u "/var/www/p3_webapp(/.*)?"
sudo semanage fcontext -a -t httpd_sys_script_exec_t /var/www/p3_webapp/env/lib64/python3.6/site-packages/mod_wsgi/server/mod_wsgi-py36.cpython-36m-x86_64-linux-gnu.so
sudo setsebool -P httpd_can_network_connect_db on
sudo reboot now
```


Big credit to https://codeshack.io/login-system-python-flask-mysql/ as they provided a lot of code that I used!!!
