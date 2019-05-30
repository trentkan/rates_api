class RatesController < ApplicationController
	# User can query rates
	def index
		# Convert time to UTC
		# Figure out dates

	end

	# This endpoint will delete the list of current rates and create a new list of rates
	# if the rate list was formatted correctly and no rates overlap on any given day
	# Format:
	# "days": comma separated, no spaces list of days
	# sun - Sunday, mon - Monday, tues - Tuesday, wed - Wednesday, thurs - Thursday, fri - Friday, sat - Saturday
	# "times": two numbers with four digits each between 0000 and 2400 separated by a dash character
	# "tz": a valid IANA standard timezone (should be standard amongst all rates or will return an error)
	# "price": an integer
	def create
		params.permit!
		rates_processor.create(params[:rates])

		if rates_processor.successful
			render :json, code: 200
		else
			render json: { errors: rates_processor.errors }, code: 400
		end
	end

	private

	def rates_processor
		@rates_processor ||= RatesProcessor.new
	end
end