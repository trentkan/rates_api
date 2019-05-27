class RatesController < ApplicationController
	# User can query rates
	def index

	end

	# User can create a new rate group
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