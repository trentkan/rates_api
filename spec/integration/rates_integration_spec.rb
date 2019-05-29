require 'swagger_helper'

describe 'Rates API' do
	path '/rates' do
    post 'Creates a set of rates' do
      tags 'Rates'
      consumes 'application/json'
      parameter name: :rates, in: :body, schema: {
        type: :array,
        items: {
          type: :object,
          properties: {
          	days: { type: :string },
          	times: { type: :string },
          	tz: { type: :string },
          	price: { type: :integer },
          }
        },
        required: [ 'days', 'times', 'tz', 'price' ],
        description: <<-HEREDOC 
        	A list of rates that have the following attributes:
        	- days: A comma separated string of days this rate is valid. Valid days are mon, tues, wed, thurs, fri, sat sun
        	- times: A dash separated string of two times that are between 0000 and 2400
        	- tz: A string that represents a time zone. Ex: America/Chicago
        	- price: An integer that represents the price of the rate.
        HEREDOC
      }

      response '200', 'rate created' do
        let(:rates) { { days: 'mon,tues', times: '0000-2400', tz: 'America/Chicago', price: 100 } }
        run_test!
      end
    end
  end
end