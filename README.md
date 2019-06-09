# README
## Description


## Application setup
This application runs on top of PostgreSQL and was built on top of version 11.3. 

Install PostgreSQL using homebrew (available at https://brew.sh/) on your local machine:
`brew install postgres`

11.3 is the current stable version available on homebrew. If the command above does not install version 11.3, consider installing version 11.3 using the source code, detailed here: https://www.wikihow.com/Install-PostgreSQL-Using-the-Source-Code.

Once PostgreSQL is installed locally, you will need to setup the application development and test databases. This is done by running `rake db:setup` from the project's root directory. 

To run this application, type `bundle install` and then `rails s` from the project directory. 
To run tests, type `bundle install` and then `rspec`.
To view API endpoints available, start the rails server (run `rails s`) and visit `localhost:3000/api-docs`.

## Design decisions
All rates must be submitted in the same timezone
- Stored timezone with each rate to eventually support rates that could be submitted by different groups/parking garages