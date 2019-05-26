require 'rails_helper'

describe ApplicationController do
	describe '#index' do
		it 'returns a 200 response' do
			get :index

			expect(response.code).to eq(204)
		end
	end
end