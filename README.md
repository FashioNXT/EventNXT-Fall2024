# README

TEAM Fall 2024

# How to Locally Run the Applicatiion

Clone the repo: 

```bash
git clone https://github.com/FashioNXT/EventNXT-Fall2024.git
```

## Recommanded: Running in Containers by Docker

> For now you need to swtich to the branch: `setup-ming`.
> ```bash
> git checkout setup-ming 
> ```

Please check you have Docker deamon running on your machine. If not, install it following https://docs.docker.com/engine/install/.

We recommand this approach because there is no need to install any other packages to run the app. You can run and test the app by one SINGLE command, wihout extra actions or environment configurations.

### Run Server

```bash
$ ./script/run_app
```
It builds the images for the app and database,  create a named volume to store the data, and start running containers from the images.

If errors occur, you can view the log by
```bash
$ docker-compose log
```
- To view the log of the app:
    ```bash
    $ docker-compose log web
    ```
- To view the log of the database:
    ```bash
    $ docker-compose log db
    ``` 

### Run Tests

#### Rspec
```
$ ./script/run_test_rspec [rspec_args]
```

#### Cucumber
```
$ ./script/run_test_cucumber [cucumber_args]
```

### Tear Down
Use this to remove the containers.
```
docker-compose down [-v] [--rmi all]
```
- `-v`: remove the nameed volumes for db data.
- `--rmi`: remove the images built by docker-compose.

## Legacy: Running directly on Your Host Machine

By Team Spring-2024.

Please check whether you have the ruby and rails installed. 
```
ruby -v
```
Ruby version is 3.2.2 as mentioned in Gemfile
```
rails -v
```
The rails version is 7.0.4

If you don't have the ruby or rails. Please follow the below processes.

* Install ruby-3.2.0 using Ruby version manager
  * `rvm get stable`
  * `rvm install "ruby-3.2.0"` or try `rvm install "ruby-3.2.2"`
  * `rvm use 3.2.0` or try `rvm use 3.2.2`

* Install PostgreSQL
  * `sudo apt-get update`
  * `sudo apt-get install postgresql postgresql-contrib libpq-dev`
  * PostgreSQL may require to create a role to allow rails to connect to the Postgre database. In AWS cloud9 ubuntu system, we executed `sudo -u postgres createuser --interactive ubuntu`

* Clone the latest git repo
  * `git clone https://github.com/CSCE-606-Event360/Spring2024EventNXT.git`

* Change directory to the new app
  * `cd Spring2024EventNXT/EventNXT_new_app` 

* Bundle install
  * `bundle install`
    
* Set ENVIRONMENT VARIABLES
    * NXT_APP_URL -> events360 website link
    * NXT_APP_ID -> client ID (registered with events360)
    * NXT_APP_SECRET -> client secret (registered with events360)
    * EVENT_NXT_APP_URL -> eventNXT WEBSITE LINK.
    * ALLOWED_HOST -> eventnxt url in heroku or local url
      
* To set environment variables, please follow below procedure:
command: 
   - export NXT_APP_URL="http://events360.herokuapp.com/"
   - export NXT_APP_ID="aCgXCUDxHSvkp12ZaLweRSVq0pmznGpFasldrE3EZpQ"
   - export NXT_APP_SECRET="iN9O2qGyA9n3nauMXOl6x5SDh08i27Nb1gs-fIjI6g0"
   - export EVENT_NXT_APP_URL="https://eventnxt-0fcb166cb5ae.herokuapp.com/" #your eventnxt app url in development heroku
   - export ALLOWED_HOST="your eventnxt app url in development heroku"

NOTE: NXT_APP_URL, NXT_APP_ID, NXT_APP_SECRET are env variables used for oauth client registration with CRM event360 server.
http://events360.herokuapp.com/ is customer production CRM server.

You should not use this for development. For development you need to clone Event360 repo and run the app.
This admin login details are present in db/seeds.rb file of Event360 repo.
Then you can go to application management and create a new test client. once the new client is registered
you can get NXT_APP_ID and NXT_APP_SECRET from the UI and set it in your development env as shown above.
you need to save client callback in this new test client in event360 app.
To get an Idea:
 - go to http://events360.herokuapp.com/, login as admin user, use same login details as mentioned above from seeds.rb file in Event360 repo.
 - go to EventNXT and look for the fields to get idea.

* Migrate Database
  * `rails db:migrate`

* Start server in local development environment
  * `rails s`
 
### Problems
1. If Bundler complains that the wrong Ruby version is installed,

    * rvm: verify that rvm is installed (for example, rvm --version) and run rvm list to see which Ruby versions are available and rvm use <version> to make a particular version active. If no versions satisfying the Gemfile dependency are installed, you can run rvm install <version> to install a new version, then rvm use <version> to use it.
    
    * rbenv: verify that rbenv is installed (for example, rbenv --version) and run rbenv versions to see which Ruby versions are available and rbenv local <version> to make a particular version active. If no versions satisfying the Gemfile dependency are installed, you can run rbenv install <version> to install a new version, then rbenv local <version> to use it.
    
    Then you can try bundle install again.

### How to run Test cases

*cucumber test cases:

```console
RAILS_ENV=test rake cucumber
```

*rspec test cases:

```console
bundle exec rspec
```