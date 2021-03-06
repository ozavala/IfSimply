# IfSimply

IfSimply is a "What you see is what you get" membership building site. The code contained within
is constructed to support end-users signing up and creating their own "Clubs" using the WYSIWYG
style of interaction. Payments and billing are handled automatically through scheduled jobs and
links with the PayPal billing service. The site was an attempt to foster community-constructed
membership sites by providing proven out of box marketing techniques, allowing the user to focus
solely on their content creation. The inline editing features of the site was specifically focused
to allow non-technical and technical users alike to create content about a subject they are
passionate about and are looking to either prompote for community collaboration or for monetary
gain.

NOTE: This repository contains the IfSimply website developed during ownership of the business
"Simple Media Technology, LLC". The website code contains older libraries and functionality
but is free to use in part or in full and in accordance with the MIT license contained within
this repository as the code can now be considered "Open Source".

## Screenshots

Below are some screenshots of the website capabilities.

![Homepage](img/homepage.png "Homepage")

![Inline Editor for Club](img/editor.png "Inline Editor for Club")

## Clone

- Clone the repository:

```
git clone <URL_TO_IFSIMPLY_CODE> ifsimply
```

## Bundler

- Install gems for Production deployment:

```
cd ifsimply/
bundle install --without deveopment test
```

## Settings

- Copy and update the settings file:

```
cp config/settings.yml.sample config/settings.yml
vim config/settings.yml   # update all values to reflect current machine/VM
```

- Copy and update the database settings file:

```
cp config/database.yml.sample config/database.yml
vim config/database.yml   # update all values for database being used
```

- Copy and update the PayPal settings file:

```
cp config/paypal.yml.sample config/paypal.yml
vim config/paypal.yml   # update all values for PayPal live API
```

- (Optional) Download an utilize a new NewRelic settings file:

```
scp Downloads/newrelic.yml <target>:ifsimply/config/   # newrelic config file with key
```

## HostMonster (on the HostMonster server)

Perform the following if you are hosting the solution on HostMonster:

- .htaccess file:

```
cp config/htaccess.sample public/.htaccess
vim public/.htaccess   # update all values for htaccess
```

- Environment settings for Ruby/Gems:

```
vim ~/.bashrc

# add the following to the .bashrc file
export HPATH=$HOME
export GEM_HOME=$HPATH/ruby/gems
export GEM_PATH=$GEM_HOME:/lib64/ruby/gems/1.9.3
export GEM_CACHE=$GEM_HOME/cache
export PATH=$PATH:$HPATH/ruby/gems/bin
export PATH=$PATH:$HPATH/ruby/gems
```

- restart.txt to force Passenger restart:

```
touch tmp/restart.txt
# this will force passenger to restart on next request
# note that it will not delete the restart.txt but, rather, use the timestamp
# to determine whether it needs to restart from this point forth
```

- Symlink for active application:

```
mkdir -p ~/public_html/ifSimply/
ln -s ~/ifsimply/public ~/public_html/ifSimply/HTML
```

## Background Mailers

WARNING: DelayedJob caches all configs, including email URLs and views for mailers.
         If ANY of these change, it requires a restart of the delayed_job service.

- Start the mailer

```
RAILS_ENV=development script/delayed_job start -n 3   # start with 3 workers
RAILS_ENV=development script/delayed_job stop
```

- Or, you can manually work off jobs during production:

```
RAILS_ENV=production rake jobs:work     # work all jobs and persist
RAILS_ENV=production rake jobs:workoff	# work all jobs and exit
```

## Whenever (crontab scheduling)

- Create the crontab entries for the billing process

```
whenever --write-crontab -s 'environment=production'
crontab -l  # double-check the crontab entries
```

## Database and Migrations

- Create the database, create the schema, and populate with seed data

```
rake db:create  RAILS_ENV=production
rake db:migrate RAILS_ENV=production
rake db:seed    RAILS_ENV=production
```

## Asset Pipeline

- Precompile all assets

```
rm -rf public/assets/*
rake assets:precompile RAILS_ENV=production
```

## Apache Web / Passenger

- Install Apache Web and Passenger:

```
sudo yum install httpd
gem install passenger
passenger-install-apache2-module  # PAY ATTENTION TO END OF THIS - COPY 3 REQUIRED LINES
```

- Add the following to the /etc/httpd/conf/httpd.conf, noting that the first 3 lines are from
the passenger-install-apache2-module command above:

```
LoadModule passenger_module /home/user/.rvm/gems/ruby-1.9.3-p194@ifsimply/gems/passenger-4.0.27/buildout/apache2/mod_passenger.so
PassengerRoot /home/user/.rvm/gems/ruby-1.9.3-p194@ifsimply/gems/passenger-4.0.27
PassengerDefaultRuby /home/user/.rvm/wrappers/ruby-1.9.3-p194@ifsimply/ruby

<VirtualHost *:3999>
  ServerName www.example.com
  DocumentRoot /opt/ifsimply/public

  <Directory /opt/ifsimply/public>
    RailsEnv development
    PassengerEnabled on
    PassengerMinInstances 3
    Options Indexes FollowSymLinks
    Order allow,deny
    Allow from all
  </Directory>
</VirtualHost>
```

- Start the Apache service

```
sudo service httpd start
```

## Database Backups/Restores

- Back up the database without the 'create database' statement.

NOTE: If you get a "failed to write to /tmp/#..." error, restart mysqld service - this is due to the
      fact that the default tmpdir is specified as /tmp, but it's mounted from within the mysqld
      process, and that /tmp directory is auto-cleaned on a routine basis by the Linux OS.

```
# PostgreSQL 8.x
pg_dump -U root ifsimply_production > ~/ifsimply_prod_pg_<YYYYMMDD>.sql

# MySQL
mysqldump -v -u root -p --no-create-db ifsimply_production > ~/ifsimply_prod_<YYYYMMDD>.sql
```

- Restore database data to a particular database name:

```
# PostgreSQL 8.x
psql -U root ifsimply_production < ifsimply_prod_pg_<YYYYMMDD>.sql

# MySQL
mysql -u root -p
sql> CREATE DATABASE 'ifsimply_backup';
sql> quit;
mysql -u root -p ifsimply_backup < ifsimply_prod_<YYYYMMDD>.sql
```
