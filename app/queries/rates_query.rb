class RatesQuery
	class InvalidDateFormatException < Exception; end

	attr_reader :local_start_datetime, :local_end_datetime, :successful, :errors

	def initialize(start_datetime:, end_datetime:)
		@successful = true
		@errors = []
		@local_start_datetime = local_time_for(start_datetime)
		@local_end_datetime = local_time_for(end_datetime)
	end
	
	def find(start_datetime, end_datetime)
		return unless @successful
	end

	private

	def local_time_for(datetime)
		begin
			raise InvalidDateFormatException unless iso8601_compliant?(datetime)
			return Time.parse(datetime).getlocal('-06:00')
		rescue InvalidDateFormatException
			@successful = false
			@errors << "#{datetime} is not iso8601 compliant"
		end
	end

	def iso8601_compliant?(datetime)
		/(\d{4})-(\d{2})-(\d{2})T(\d{2})\:(\d{2})\:(\d{2})[+-](\d{2})\:(\d{2})/.match?(datetime)
	end
end