# README
## Description
This API allows a user to enter a date time range and receive the rate that they would be charged to park for that time span. The project was generated using `rails new --api`, meaning that it is optimized to only serve JSON content. Therefore, trying to hit localhost:3000 in a web browser will render no web page and a 204 status.

There are two endpoints that this API exposes:
GET /rates
This endpoint retrieves a rate if one exists for a given date time range. 

Parameters:


Output:

Notes: 

Datetime ranges should be specified in ISO-8601 format. A rate must completely
encapsulate a datetime range for it to be available.

POST /rates
Headers:
Content-Type: application/json

Parameters:

Output: 

Notes: 

## Application setup
### Database
This application runs on top of PostgreSQL and was built on top of version 11.3. 

Install PostgreSQL using homebrew (available at https://brew.sh/) on your local machine:
`brew install postgresql`

Start the service after the installation is complete by running: `brew services start postgresql`

11.3 is the current stable version available on homebrew. If the command above does not install version 11.3, consider installing version 11.3 using the source code, detailed here: https://www.wikihow.com/Install-PostgreSQL-Using-the-Source-Code.

### Ruby
RUBY VERSION: 2.6.1
This application runs on ruby 2.6.1. To download the correct version, you will need to install a ruby version manager and set your ruby version to 2.6.1. A common ruby version manager is `rbenv` found at https://github.com/rbenv/rbenv and can be installed with homebrew:
`brew install rbenv`. Run through the setup steps listed in the `rbenv` README. To install the specific version of ruby, run: `rbenv install 2.6.1`.

Once you have installed and configured your local ruby version to 2.6.1, you can confirm you are running the correct version by making sure `ruby -v` outputs `ruby 2.6.1` on the command line. 

### Rails
Run `bundle install` to install all gems associated with this application.

Once PostgreSQL is installed locally and ruby is configured correctly, you will need to setup the application development and test databases. This is done by running `rake db:setup` from the project's root directory. 

To run this application, run `rails s` from the project's root directory. 
To run tests, run `rspec` from the project's root directory.
To view API endpoints available, start the rails server (run `rails s`) and visit `localhost:3000/api-docs`.

### IMPORTANT: Retrieving a rate
Before you try to retrieve a rate, you must POST your rates using the /rates endpoint. Otherwise, you will get unavailable for every rate you query. This was done on purpose in order to decouple the implementation of this API application to what was given as sample expected input/output.

## Design decisions
All rates must be submitted in the same timezone when creating rates
- Stored timezone with each rate to eventually support rates that could be submitted by different groups/parking garages.

All existing rates are deleted when a new set of rates are posted. 
- This can be easily reversed by adding a soft delete column. 