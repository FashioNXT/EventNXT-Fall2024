# README

TEAM Spring 2024

### Install ruby and rails

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

## How to run Test cases

*cucumber test cases:

```console
RAILS_ENV=test rake cucumber
```

*rspec test cases:

```console
bundle exec rspec
```

If you want to deploy to personal Heroku account:
 Register a Heroku account
 Log into Heroku with heroku login -i, enter your email
 If multi-factor authentication is enabled, login the Heroku webpage and get the API key as password to enter in CLI
 Create an app with heroku create eventnxt
 Push code to App repo on Heroku, git push heroku main
 Migrate database on Heroku, heroku run rake db:migrate
 App is deployed to Heroku, go to the website and test it out

 Make sure, use have heroku postgress plugin addon configured for the container as ruby needs this to create schema migration table, Go to resources of the app in heroku UI and search for heroku postgress in add-on search:
 ![image](https://github.com/CSCE-606-Event360/EventNXT/assets/143028516/0ebc8e90-141c-4fbe-8aa8-699b2d547642)


You can also deploy code to Heroku using GitHub codespaces:

Steps for the same are as follows:

Step 1: Create a github codespace.

![image](https://github.com/CSCE-606-Event360/EventNXT/assets/143128193/fe934f0f-d848-4d5b-b862-c273fae498b2)

Step2: Install heroku CLI:

https://devcenter.heroku.com/articles/heroku-cli

### Create heroku project
 heroku login -i

 heroku container:login

 heroku create -a eventnxt

### Build repo into container and deploy to heroku

 heroku container:login

 heroku container:push web -a eventnxt

 heroku container:release web -a eventnxt

### Tail the logs:
 heroku logs --tail -a eventnxt


### Contacts:
 * Email the team if you have any questions:
  * Anirith Pampati: anirith@tamu.edu | text/call @ 9797210622
  * Amalesh Arivanan: amalesh.arivanan-22@tamu.edu
  * Louis Turrubiartes: louis.turrubiartes@tamu.edu
  * Alex Wise: alex2by4@tamu.edu
  * Tianchen Huang: th20@tamu.edu
  * Tong Wu: syca.red@tamu.edu
  * Xin Tong: xintong@tamu.edu



### The content below is by - TEAM SPRING 2024

## Introduction

The major fault of this legacy app has been faulty authentication, which allowed every user to visit the event dashboard regardless of being logged in, i.e., lack of security. In addition, it was not possible to connect the app to the central authentication developed by the CRM team. After several attempts and meetings with the instructor, we decided to redesign and build a new Ruby-on-Rails app from scratch, which not only imitates all the existing features of the old app, but all also provides the following benefits:

* Fully functional authentication
* Secure app, i.e., no access to any page unless the user is signed into the app.
* Multiple registration methods, including EventNXT-based registration and Google registration, which allows users to register via their gmail account.
* Easy integration to the CRM’s central authentication system
* Faster operation
* Using only Ruby language, i.e., no hacky implementation
* No Javascript implementation
* Replicable features, i.e., similar features have similar implementations
* Comprehensive explanation of changes made to each line of the application.

On top of all these benefits, we only focused on implementing features instead of spending time on styling with CSS or Bootstrap. We believe that front-end changes can be done when all features are implemented. Since there are still some features remaining to be completed, we did not add any front-end styling to the new app to make it easier for the next team to understand the codes.


## Naming Convetion for Branches

The repo contains multiple branches. Keep in mind that the "main" branch does not have the changes made in any of other branches.

Multiple branches are made to clearly shows the development process of the app. The naming convention used for each branch is **`AI_<feature name>_<iteration number>_<next feature name>_<iteration number>`**. For example, **`AI_home_001_event_005`** means that the first implemented feature is a **home page** with only one iteration and the next feature implemented after **home page** is **event dashboard** with 5 iterations.

To avoid long names, the naming restarted after **`AI_home_001_event_005_seat_001_guest_001_devise_001_omniauth_001_mailer_006`**, i.e., the next branch built on top of this branch is **`AI_mailer006_simplecov_001`**.


## How to Load the new Application

The following simple steps should be taken to deploy the app into your local machine. Same steps can be used for Amazon Web Service (AWS) Cloud-9 as well.

1. Check if Ruby, Rails, and Bundle are installed

```sh
$ ruby -v
$ rails -v
$ bundle -v
```

2. If you are using AWS-Cloud9, you can install all these by running the following commands. Please make sure you’re not entered the app folder yet. Run the following command in your created environment, before entering your app’s local folder.

```sh
# For Amazon Linux:
$ sudo yum -y update
$ sudo yum -y install ruby

# Update RVM by running:
$ rvm get stable

# Install ruby version:
$ rvm install 3.1.2

# Set default version in RVM
$ rvm --default use 3.1.2

# Update/install bundler
$ gem install bundler

# Update/install rails
$ gem install rails
```

3. Now, you can clone the app’s GitHub repo and run the app on your local server.

```sh
$ git clone <github repo>
$ cd <app name>
$ bundle install
$ rails db:migrate
$ rails s
```

4. If you are using AWS-Cloud9, you will get access to the web app via “Preview”. You will probably be asked to add the host address to your app’s environment. For example, in the case of development, you may put the following code line in your “development.rb” located at “config/environments/developement.rb”. Change the URL with your own AWS cloud-9 url. Now, you will be able to rerun the server and preview the app.

```ruby
config.hosts << "da8311—-.vfs.cloud9.us-east-2.amazonaws.com"
```


## To-Do List (partial) for the Next Team for the New App

The following items need to be implemented.

1. **Test Cases (Rspec and Cucumber):** some Rspec tests are written for the new app. The new team should develop more tests cases for every single feature. You can get some ideas on how to write them by looking at the tests written for the old app.

2. **Add CRM Authentication:** the new app already has two authentication methods, you need to add another option to allow users to use the central authentication developed by the CRM team.
Associate Event to each User: the app currently allows all users to see all the created events. You need to associate each event to each user that limits the signed-in users to only see their own created events, not others. You can find numerous online tutorials on how to do it.

3. **Mailer System:** the event organizers were able to send individual or bulk emails to the guests in the old app. You can find all the mailing templates in the old app. You need to transfer those into the new app. Furthermore, you should allow every event organizer to be able to send emails from their own email address. The app is currently configured in a way that only allows certain gmail addresses to send email from. You can learn more about it online by searching how to send email from gmail in the third-party app. As a hint, there are some other mailer service providers, such as “mailgun” and “sendgrid” that may be the way to allow sending emails from any email address.

4. **Referral System:** the referral system header is only placed in the show page of each event, but nothing about referral is implemented in the new app. You need to fully understand what exactly the client wants for this system and learn from the implemented referral system in the old app. Then you can implement a fully functional referral system.

5. **Inline CRUD Scaffold:** rails recently introduced a very powerful tool called “Hotwire” to create dynamic tables. From which, you can create inline editable tables inside any page of the app. It is highly suggested to learn and implement it for this app, instead of using Javascript.

6. **CSS Styling:** it is highly suggested to do styling after all features are implemented in ruby language. Styling or front-end changes can be done as the final step of building the app.

7. **Test Cases (Rspec and Cucumber):** to remind you, don’t forget to write test cases!
