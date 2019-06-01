# README

To run this application, type `bundle install` and then `rails s` from the project directory. 
To run tests, type `bundle install` and then `bundle exec rspec`
To view API endpoints available, visit `localhost:3000/api-docs`.

Design decisions: All rates must be submitted in the same timezone
- Stored timezone with each rate to eventually support rates that could be submitted by different groups/parking garages