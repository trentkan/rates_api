class RatesProcessor

	attr_reader :errors, :successful

	def initialize
		@errors = []
		@successful = true
	end

	def create(rates)
		existing_rates_with_times = {}

		formatted_rates = rates.each_with_object([]) do |rate, master_rates|
			rate[:days].split(',').each do |day|
				if times_overlap?(existing_rates_with_times, rate[:times], day)
					@errors << "Overlapping rate for day at #{rate[:times]}"
					break
				else
					master_rates << format_rate(rate, day)
				end
			end
			break if @errors.present?
		end

		if @errors.present?
			@successful = false
		else
			Rate.import(formatted_rates)
		end
	end

	private

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
end