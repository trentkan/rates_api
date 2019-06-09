=begin
 This object is responsible for taking a start and end date time,
 verifying that it meets an iso-8601 datetime format (http://support.sas.com/documentation/cdl/en/lrdict/64316/HTML/default/viewer.htm#a003169814.htm)
 and returning a rate if there is one rate for the time range provided.

 If there is more than one range that meets the requested time range, it will return 'unavailable'
 If there are no rates that meet the requested time range, it will return 'unavailable'

 Invalid ranges can occur if the range spans more than one day when converted to the range of stored timezones or
 if the start of the range is after the end of the range. This will result in an Invalid datetime range error.

 If the start or end datetime is not iso-8601 compliant, the <datetime> is not iso8601 compliant error will be raised.
 If no date is provided with the start or end datetime, it will assume the current date in the UTC timezone.
 If no time is provided with the start or end datetime, it will assume 00:00:00 in the UTC timezone.
=end

class RatesQuery
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

				@start_datetime = start_datetime.in_time_zone
				@end_datetime = end_datetime.in_time_zone

				raise InvalidDateTimeException unless valid_range_for_datetimes?
				
				if same_day_for_datetimes?
					rates = Rate.where(day: days[start_datetime.wday])
											.where("start_time <= #{formatted_time_from(start_datetime)}")
											.where("end_time >= #{formatted_time_from(end_datetime)}")

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
			DateTime.iso8601(datetime)
		rescue ArgumentError
			@successful = false
			@errors << "#{datetime} is not iso8601 compliant"
		end
	end

	def iso8601_compliant?(datetime)
		/(\d{4})-(\d{2})-(\d{2})T(\d{2})\:(\d{2})\:(\d{2})[+-](\d{2})\:(\d{2})/.match?(datetime)
	end
end