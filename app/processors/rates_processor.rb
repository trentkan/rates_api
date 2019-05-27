class RatesProcessor
	class InvalidParametersViolation < Exception; end

	attr_reader :errors, :successful

	def initialize
		@errors = []
		@successful = true
	end

	def create(rates)
		begin
			raise InvalidParametersViolation unless rates.is_a?(Array)

			existing_rates_with_times = {}

			formatted_rates = rates.each_with_object([]) do |rate, master_rates|
				raise InvalidParametersViolation unless parameters_valid?(rate)
				
				add_rate_if_no_overlap(rate, existing_rates_with_times, master_rates)

				break if @errors.present?
			end

			if @errors.present?
				@successful = false
			else
				Rate.import(formatted_rates)
			end
		rescue ActiveRecord::NotNullViolation, InvalidParametersViolation
			@successful = false

			@errors << 'Poorly formatted input, please try again.'
		end
	end

	private

	def add_rate_if_no_overlap(rate, existing_rates, master_rates)
		rate[:days].split(',').each do |day|
			if times_overlap?(existing_rates, rate[:times], day)
				@errors << "Overlapping rate for day at #{rate[:times]}"
				break
			else
				master_rates << format_rate(rate, day)
			end
		end
	end

	def format_rate(rate, day)
		time = rate[:times].split('-')
		{
			day: day,
			start_time: time.first.scan(/../).join(':'),
			end_time: time.last.scan(/../).join(':'),
			time_zone: rate[:tz],
			price: rate[:price]
		}
	end

	def times_overlap?(existing_rates, new_rate_times, day)
		new_rate_times = new_rate_times.split('-')
		new_rate = (new_rate_times.first...new_rate_times.last)

		if existing_rates[day]
			existing_rates[day].each do |existing_rate|
				existing_rate_expanded = existing_rate.to_a

				# It is necessary to call to_a before #last because of the implementation of ranges and last
				new_rate_within_existing = existing_rate.include?(new_rate.first) || existing_rate.include?(new_rate.to_a.last)
				existing_rate_within_new = new_rate.include?(existing_rate_expanded.first) || new_rate.include?(existing_rate_expanded.last)
				
				return true if new_rate_within_existing || existing_rate_within_new
			end
		end
		
		existing_rates[day] = [new_rate]

		false
	end

	def parameters_valid?(rate)
		times = rate[:times] && rate[:times].split('-')
		times_valid = times && times.length == 2 && ('0000'..'2400').include?(times.first) && ('0000'..'2400').include?(times.last)
		price_valid = rate[:price] && rate[:price].is_a?(Integer)

		times_valid && price_valid && rate[:days] && rate[:tz]
	end
end