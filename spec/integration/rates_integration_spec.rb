require 'swagger_helper'

describe 'Rates API' do
  path '/rates' do
    get 'Finds a rate that matches a given date time range' do
      tags 'Rates'
      consumes 'application/json'
      parameter name: :start_datetime, :in => :query, type: :string, required: true
      parameter name: :end_datetime, :in => :query, type: :string, required: true

      response '200', 'rate found' do
        schema type: :object,
          properties: {
            price: { type: :string }
          },
          required: [ 'price' ]

        let(:start_datetime) { '2015-07-01T07:00:00-05:00' }
        let(:end_datetime) { '2015-07-01T12:00:00-05:00' }
        
        run_test!
      end

      response '400', 'rate not found' do
        let(:start_datetime) { '2015-07-01T13:00:00-05:00' }
        let(:end_datetime) { '2015-07-01T12:00:00-05:00' }

        before do |example|
          Time.zone = 'America/Chicago'
          Rate.create(day: 'wed', start_time: 600, end_time: 1800, time_zone: 'America/Chicago', price: 1750)        
          submit_request(example.metadata)
        end

        it 'returns a 400 response' do |example|
          assert_response_matches_metadata(example.metadata)
        end
      end
    end
  end

	path '/rates' do
    post 'Creates a set of rates' do
      tags 'Rates'
      consumes 'application/json'
      parameter name: :rates, in: :body, schema: {
        type: :object,
        required: true,
        properties: {
          rates: {
            type: :array,
            items: {
              type: :object,
              properties: {
                days: { type: :string, required: true },
                times: { type: :string, required: true },
                tz: { type: :string, required: true },
                price: { type: :integer, required: true },
              }
            }
          }
        },
        description: <<-HEREDOC 
        	A list of rates that have the following attributes:
        	- days: A comma separated string of days this rate is valid. Valid days are mon, tues, wed, thurs, fri, sat sun
        	- times: A dash separated string of two times that are between 0000 and 2400
        	- tz: A string that represents a time zone. Ex: America/Chicago
        	- price: An integer that represents the price of the rate.
        HEREDOC
      }

      response '201', 'rate created' do
        let(:rates) { {rates: [{ days: 'mon,tues', times: '0000-2400', tz: 'America/Chicago', price: 100 }]} }
        run_test!
      end

      response '400', 'rate not created' do
        let(:rates) { {} }
        run_test!
      end
    end
  end
end