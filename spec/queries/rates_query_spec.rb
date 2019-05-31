require 'rails_helper'

describe RatesQuery do
	subject { described_class.new(start_datetime: '2015-07-01T07:00:00-05:00', end_datetime: '2015-07-01T12:00:00-05:00') }
	
	describe '.initialize' do
		context 'with correctly formatted datetime parameters' do
			it 'does not record any errors' do
				expect(subject.errors).to be_empty
			end

			it 'completes successfully' do
				expect(subject.successful).to be true
			end
		end

		context 'with incorrectly formatted datetime parameters' do
			subject { described_class.new(start_datetime: start_datetime, end_datetime: end_datetime) }

			shared_examples 'raises errors and does not complete successfully' do
				it 'records an error' do
					expect(subject.errors.first).to eq("not a time is not iso8601 compliant")
				end

				it 'does not complete successfully' do
					expect(subject.successful).to be false
				end
			end

			context 'incorrectly formatted start_datetime' do
				let(:start_datetime) { 'not a time' }
				let(:end_datetime) { '2015-07-01T07:00:00-05:00' }

				it_behaves_like 'raises errors and does not complete successfully'
			end

			context 'incorrectly formatted end_datetime' do
				let(:start_datetime) { '2015-07-01T07:00:00-05:00' }
				let(:end_datetime) { 'not a time' }

				it_behaves_like 'raises errors and does not complete successfully'
			end
		end
	end

	describe '#find_rate' do
		context 'datetime range has start datetime that is past the end datetime' do
			subject { described_class.new(start_datetime: '2015-07-01T20:00:00-05:00', end_datetime: '2015-07-01T19:00:00-05:00') }

			before do
				allow(Rate).to receive(:pluck).with(:time_zone).and_return(['America/Chicago'])
			end

			it 'records an error explaining the invalid datetime range' do
				subject.find_rate
				
				expect(subject.errors.first).to eq("Invalid datetime range")
			end

			it 'does not complete successfully' do
				subject.find_rate

				expect(subject.successful).to be false
			end
		end

		context 'datetime range is valid for rates' do
			context 'datetime range spans more than one day' do
				subject { described_class.new(start_datetime: '2015-07-01T20:00:00-05:00', end_datetime: '2015-07-02T01:00:00-05:00') }

				it 'returns unavailable' do
					actual_rate = subject.find_rate

					expect(actual_rate).to eq 'unavailable'
				end
			end

			context 'datetime range spans more than one day due to timezone conversion' do
				subject { described_class.new(start_datetime: '2015-07-01T20:00:00-07:00', end_datetime: '2015-07-01T24:00:00-07:00') }

				it 'returns unavailable' do
					actual_rate = subject.find_rate

					expect(actual_rate).to eq 'unavailable'
				end
			end

			context 'with one rate that matches the datetime range' do
				it 'returns the price for that rate' do
					Time.zone = 'America/Chicago'
					Rate.create(day: 'wed', start_time: 600, end_time: 1800, time_zone: 'America/Chicago', price: 1750)

					actual_rate = subject.find_rate

					expect(actual_rate).to eq '1750'
				end
			end

			context 'with multiple rates that span the datetime range' do
				subject { described_class.new(start_datetime: '2015-07-01T01:00:00-05:00', end_datetime: '2015-07-01T12:00:00-05:00') }

				it 'returns unavailable' do
					Time.zone = 'America/Chicago'
					Rate.create(day: 'wed', start_time: 600, end_time: 1800, time_zone: 'America/Chicago', price: 1750)
					Rate.create(day: 'wed', start_time: 100, end_time: 500, time_zone: 'America/Chicago', price: 1750)
					
					actual_rate = subject.find_rate

					expect(actual_rate).to eq 'unavailable'
				end
			end
		end
	end
end