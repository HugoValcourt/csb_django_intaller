#!/bin/bash

echo "$(tput setaf 7) $(tput setab 1)IMPORTANT to run this script with sudo or root.$(tput sgr 0)"

### IMPORTANT!! ###
#
# To be able to install dependencies for the project csb, you need to add the ssh key of
# the machine recieving the install.
#
# THE BELLOW PORTION IS AN EXPLANATION FOR THE MANUAL APPROACH. THE FIRST PORTION OF COMMANDS BELLOW WILL TAKE CARE OF THAT.
#
# To do so, 
# - Run this command on the machine recieving the install:
#	ssh-keygen -t rsa
#
# - Then run this command to display your key:
#	cat ~/.ssh/id_rsa.pub
# 	- Your key should start with 'ssh-rsa' and end with 'username@devicename' 
#
# - Go in the settings of your Github account
#	- Then SSH and GPG keys
#	- New SSH key
#	- Give it a name and paste the ssh-rsa key from the previous step
#
#Setting up the ssh keys for git
ssh-keygen -t rsa
eval $(ssh-agent -s)
ssh-add ~/.ssh/id_rsa
echo "$(tput setaf 7) $(tput setab 8)Make a new SSH KEY on your github account with this key.$(tput sgr 0)"
cat ~/.ssh/id_rsa.pub
read -p "$(tput setaf 7) $(tput setab 8)Press any key to continue$(tput sgr 0)"
#

#General setup
apt-get install curl -y
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3 get-pip.py
pip install pipenv
apt-get install postgresql-9.6 -y
apt-get install git -y
apt-get install postgis -y
apt-get install make -y
apt-get install g++ -y
apt-get install libz-dev -y
apt-get install libsqlite3-dev -y
git clone https://github.com/mapbox/tippecanoe
cd tippecanoe
make -j
make install
cd ..
git clone https://github.com/csb-comren/csb-django
cd csb-django
wget -O schema.sql https://raw.githubusercontent.com/csb-comren/csb-django/serverSettings/schema.sql?token=AjEYWpk6swsodEYGe26xc28sNk88o-3Dks5cGVfjwA%3D%3D

#Dependencies installation
pipenv install
pipenv run pip install -r requirements.txt
pipenv run pip install psycopg2-binary

#Database configuration
echo "$(tput setaf 7) $(tput setab 8)This password will be for the superuser of postgresql.$(tput sgr 0)"
sudo -u postgres psql postgres -c "\password postgres"
sudo -u postgres psql postgres -c "\i schema.sql"

#Settings config
cd ~/csb-django
cp secret_settings_dummy.py secret_settings.py

echo "$(tput setaf 7) $(tput setab 8)You now must edit the config of the files $(tput setaf 2)secrect_settings.py $(tput setaf 7)and $(tput setaf 2)csb/settings.py$(tput sgr 0)"
echo "$(tput setaf 7) $(tput setab 8)In the file $(tput setaf 2)csb/settings.py$(tput setaf 7), all you need to do is add your ip to the Allowed hosts$(tput sgr 0)"
echo "$(tput setaf 7) $(tput setab 8)ALLOWED_HOSTS = ['YOUR.IP']$(tput sgr 0)"
echo "$(tput setaf 7) $(tput setab 8)And for the file $(tput setaf 2)secret_settings.py$(tput setaf 7), you need to fill in your database info$(tput sgr 0)"
echo "$(tput setaf 7) $(tput setab 1)When this is done, run the command within this virtualenv. If you are not in this virtual environment, it won't work.$(tput sgr 0)"
echo "$(tput setaf 3) $(tput setab 8)python3 manage.py makemigrations$(tput sgr 0)"
echo "$(tput setaf 3) $(tput setab 8)python3 manage.py migrate$(tput sgr 0)"
echo "$(tput setaf 7) $(tput setab 1)EXIT this virtual environment first, $(tput setab 8)then run this extra long command:$(tput sgr 0)"
echo '$(tput setaf 3) $(tput setab 8)sudo -u postgres psql csbcomren -c "CREATE TABLE batch_files ( batch_id INTEGER NOT NULL, file_id INTEGER NOT NULL, CONSTRAINT batch_files_pk PRIMARY KEY (batch_id, file_id), CONSTRAINT batch_files_file_fk FOREIGN KEY (file_id) REFERENCES django.upload_file ON DELETE CASCADE, CONSTRAINT batch_files_batch_fk FOREIGN KEY (batch_id) REFERENCES batches ON DELETE CASCADE );"$(tput sgr 0)'
echo "$(tput setaf 7) $(tput setab 8)After, go back into the virtual environment with the command: $(tput setaf 3)sudo pipenv shell $(tput setaf 7)you are now ready to run the server: $(tput sgr 0)"
echo "$(tput setaf 3) $(tput setab 8)python3 manage.py runserver 0:8080$(tput sgr 0)"

# If any other problem with the webpage, try running these commands in the virtual environment:
# python3 manage.py makemigrations
# python3 manage.py migrate
