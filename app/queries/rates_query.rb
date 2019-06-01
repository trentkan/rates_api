class RatesQuery
	class InvalidDateFormatException < Exception; end
	class InvalidDateTimeException < Exception; end

	attr_reader :successful, :errors

	def initialize(start_datetime:, end_datetime:)
		@successful = true
		@errors = []
		@start_datetime = time_for(start_datetime)
		@end_datetime = time_for(end_datetime)
	end
	
	def find_rate
		begin
			stored_timezones = Rate.pluck(:time_zone).uniq
			stored_timezones.each do |stored_timezone| 
				Time.zone = ActiveSupport::TimeZone[stored_timezone]

				@start_datetime = Time.zone.parse(start_datetime)
				@end_datetime = Time.zone.parse(end_datetime)

				raise InvalidDateTimeException unless valid_range_for_datetimes?
				
				if same_day_for_datetimes?
					rates = Rate.where(day: days[start_datetime.wday])
											.where("start_time < #{formatted_time_from(start_datetime)}")
											.where("end_time > #{formatted_time_from(end_datetime)}")

					return rates.first.price.to_s if rates.length == 1
				end
			end
			
			return 'unavailable'
		rescue InvalidDateTimeException
			@errors << "Invalid datetime range"
			@successful = false
		end
	end

	private

	attr_reader :start_datetime, :end_datetime

	def formatted_time_from(datetime)
		datetime.strftime('%H%M').to_i
	end

	def valid_range_for_datetimes?
	 	start_datetime < end_datetime
	end

	# This may be an issue if we allow rates to be stored with different timezones
	# For example, a datetime range may be valid for rates in america but not in australia
	def same_day_for_datetimes?
		days[start_datetime.wday] == days[end_datetime.wday]
	end

	def days
		@days ||= ['sun', 'mon', 'tues', 'wed', 'thurs', 'fri', 'sat']
	end

	def time_for(datetime)
		begin
			raise InvalidDateFormatException unless iso8601_compliant?(datetime)
			datetime
		rescue InvalidDateFormatException
			@successful = false
			@errors << "#{datetime} is not iso8601 compliant"
		end
	end

	def iso8601_compliant?(datetime)
		/(\d{4})-(\d{2})-(\d{2})T(\d{2})\:(\d{2})\:(\d{2})[+-](\d{2})\:(\d{2})/.match?(datetime)
	end
end