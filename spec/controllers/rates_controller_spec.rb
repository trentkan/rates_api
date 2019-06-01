require 'rails_helper'

describe RatesController do
	describe '#index' do
		it 'returns a 200 response for valid parameters that match a rate' do
			Rate.create(day: 'wed', start_time: 600, end_time: 1800, time_zone: 'America/Chicago', price: 1750)

			get :index, params: { start_datetime: '2015-07-01T07:00:00-05:00', end_datetime: '2015-07-01T12:00:00-05:00' }

			expect(response.code).to eq('200')
		end

		it 'returns a 400 response for invalid parameters' do
			Rate.create(day: 'wed', start_time: 600, end_time: 1800, time_zone: 'America/Chicago', price: 1750)

			get :index, params: { start_datetime: '2015-07-01T08:00:00-05:00', end_datetime: '2015-07-01T07:00:00-05:00' }

			expect(response.code).to eq('400')
		end
	end

	describe '#create' do
		it 'returns a 201 response for valid parameters lead to a created rate' do
			request.accept = "application/json"

			post :create, params: {
					"rates": [
						{
							"days": "mon,tues",
							"times": "0900-2100",
							"tz": "America/Chicago",
							"price": 1500
						}
					],
				},
				as: :json

			expect(response.code).to eq('201')
		end

		it 'returns a 400 response for invalid parameters' do
			request.accept = "application/json"

			post :create, params: {
					"rates": [
						{
							"days": "mon,tuesday",
							"times": "0900-2100",
							"tz": "America/Chicago",
							"price": 1500
						}
					]
				},
				as: :json

			expect(response.code).to eq('400')
		end
	end
end