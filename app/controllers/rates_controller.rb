class RatesController < ApplicationController
	# User can query rates
	def index

	end

	# User can create a new rate group
	def create
		rates_processor.create

		if rates_processor.successful
			render :json, code: 200
		else
			render :json, { errors: @errors }, code: 400
	end

	private

	def rates_processor
		@rates_processor ||= RatesProcessor.new
	end
end