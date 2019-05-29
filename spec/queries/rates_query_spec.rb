require 'rails_helper'

describe RatesQuery do
	describe '.initialize' do
		context 'with correctly formatted datetime parameters' do
			subject { described_class.new(start_datetime: '2015-07-01T07:00:00-05:00', end_datetime: '2015-07-01T12:00:00-05:00') }
			it 'does not record any errors' do
				expect(subject.errors).to be_empty
			end

			it 'completes successfully' do
				expect(subject.successful).to be true
			end

			it 'converts the datetimes to the America/Chicago timezone (CST)' do
				expect(subject.local_start_datetime).to eq(Time.parse('2015-07-01T06:00:00-06:00'))
				expect(subject.local_end_datetime).to eq(Time.parse('2015-07-01T11:00:00-06:00'))
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
end