class RatesController < ApplicationController
	# This endpoint will return a rate for a given time range if one exists
	# If there are multiple rates for a given time range, it will return unavailable
	# If a given time range spans over a day, it will return unavailable
	# Parameter format:
	# start_datetime: iso-8601 datetime
	# end_datetime: iso-8601 datetime
	def index
		result = rates_query.find_rate

		if rates_query.successful
			render json: { price: result }, code: 200
		else
			render json: { errors: rates_processor.errors }, code: 400
		end
	end

	# This endpoint will delete the list of current rates and create a new list of rates
	# if the rate list was formatted correctly and no rates overlap on any given day
	# Parameter format:
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

	# Need to gsub spaces with + because + gets stripped as a query parameter
	def rates_query
		@rates_query ||= RatesQuery.new(start_datetime: params[:start_datetime].gsub(' ', '+'), end_datetime: params[:end_datetime].gsub(' ', '+'))
	end
end