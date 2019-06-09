class RatesController < ApplicationController
	
	# This endpoint will return a rate for a given time range if one exists
	
	# Parameter format:
	# start_datetime: string
	# end_datetime: string

	# Return format:
	# { price: integer } if a rate exists.
	# { price: string } if a rate does not exist or there is more than one rate.
	# { errors: string } if there were any errors in the parameter format
	def index
		result = rates_query.find_rate

		if rates_query.successful
			render json: { price: result }, status: 200
		else
			render json: { errors: rates_query.errors }, status: 400
		end
	end

	# This endpoint will delete the list of current rates and create a new list of rates
	
	# Parameter format:
	# "days": string
	# "times": string
	# "tz": string
	# "price": integer

	# Return format:
	# { }, status; 201 if rates were successfully created
	# { errors: string } if there were any errors in the parameter format
	def create
		params.permit!
		rates_processor.create(params[:rates])

		if rates_processor.successful
			render :json, status: 201
		else
			render json: { errors: rates_processor.errors }, status: 400
		end
	end

	private

	def rates_processor
		@rates_processor ||= RatesProcessor.new
	end

	def rates_query
		# There is a need to gsub spaces with + because + gets stripped as a query parameter
		@rates_query ||= RatesQuery.new(start_datetime: params[:start_datetime].gsub(' ', '+'), end_datetime: params[:end_datetime].gsub(' ', '+'))
	end
end