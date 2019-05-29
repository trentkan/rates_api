require 'rails_helper'

describe RatesProcessor do
	describe '#create' do
		shared_examples 'a successful request to update the rate' do
			it 'creates the rate' do
				expect(Rate).to receive(:delete_all)
				expect(Rate).to receive(:import).with(expected_rate)
				
				subject.create(rates[:rates])
			end
		end

		shared_examples 'an unsuccessful request to update the rate' do
			it 'creates the rate' do
				expect(Rate).not_to receive(:import).with(expected_rate)
				
				subject.create(rates[:rates])
			end

			it 'records an error' do
				subject.create(rates[:rates])

				expect(subject.errors).not_to be_empty
			end
		end

		context 'malformed input' do
			shared_examples 'error due to malformed input' do
				it 'records an error' do
					subject.create(rates[:rates])

					expect(subject.errors.first).to eq 'Poorly formatted input, please try again.'
				end
			end

			context 'rates is not an array' do
				let(:rates) do
					{
						rates: 'bad parameter'
					}
				end

				it_behaves_like 'error due to malformed input'
			end

			context 'malformed days parameter' do
				context 'days parameter is empty string' do
					let(:rates) do
						{
							'rates': [
								{
									'days': '',
									"times": '0900-2100',
									"tz": "America/Chicago",
									"price": 1500
								}
							]
						}
					end

					it_behaves_like 'error due to malformed input'
				end

				context 'days parameter is not a valid day format' do
					let(:rates) do
						{
							'rates': [
								{
									'days': 'monday',
									"times": '0900-2100',
									"tz": "America/Chicago",
									"price": 1500
								}
							]
						}
					end

					it_behaves_like 'error due to malformed input'
				end

				context 'days parameter is not comma separated' do
					let(:rates) do
						{
							'rates': [
								{
									'days': 'mon.tues',
									"times": '0900-2100',
									"tz": "America/Chicago",
									"price": 1500
								}
							]
						}
					end

					it_behaves_like 'error due to malformed input'
				end

				context 'days parameter has a space in between days and commas' do
					let(:rates) do
						{
							'rates': [
								{
									'days': 'mon, tues',
									"times": '0900-2100',
									"tz": "America/Chicago",
									"price": 1500
								}
							]
						}
					end

					it_behaves_like 'error due to malformed input'
				end
			end

			context 'malformed times parameter' do
				context 'start time and end time is not separated by - character' do
					let(:rates) do
						{
							"rates": [
								{
									"days": "mon",
									"times": "09002100",
									"tz": "America/Chicago",
									"price": 1500
								}
							]
						}
					end

					it_behaves_like 'error due to malformed input'
				end

				context 'start time is not between 0000 and 2400' do
					let(:rates) do
						{
							"rates": [
								{
									"days": "mon",
									"times": "2500-2100",
									"tz": "America/Chicago",
									"price": 1500
								}
							]
						}
					end

					it_behaves_like 'error due to malformed input'
				end
				
				context 'end time is not between 0000 and 2400' do
					let(:rates) do
						{
							"rates": [
								{
									"days": "mon",
									"times": "0900-2500",
									"tz": "America/Chicago",
									"price": 1500
								}
							]
						}
					end

					it_behaves_like 'error due to malformed input'
				end
			end

			context 'malformed price parameter' do
				context 'price is not an integer' do
					let(:rates) do
						{
							"rates": [
								{
									"days": "mon",
									"times": "0900-2100",
									"tz": "America/Chicago",
									"price": '1500'
								}
							]
						}
					end

					it_behaves_like 'error due to malformed input'
				end
			end

			# Not necessary for day missing because rate will not be posted
			context 'missing parameters' do
				context 'times missing' do
					let(:rates) do
						{
							"rates": [
								{
									"days": "mon",
									"tz": "America/Chicago",
									"price": 1500
								}
							]
						}
					end

					it_behaves_like 'error due to malformed input'
				end

				context 'tz missing' do
					let(:rates) do
						{
							"rates": [
								{
									"days": "mon",
									"times": "0900-2100",
									"price": 1500
								}
							]
						}
					end

					it_behaves_like 'error due to malformed input'
				end

				context 'price missing' do
					let(:rates) do
						{
							"rates": [
								{
									"days": "mon",
									"times": "0900-2100",
									"tz": "America/Chicago"
								}
							]
						}
					end

					it_behaves_like 'error due to malformed input'
				end
			end
		end

		context 'for one day' do
			let(:rates) do
				{
					"rates": [
						{
							"days": "mon",
							"times": "0900-2100",
							"tz": "America/Chicago",
							"price": 1500
						}
					]
				}
			end

			let(:expected_rate) do 
				[{ day: 'mon', start_time: '09:00', end_time: '21:00', time_zone: 'America/Chicago', price: 1500 }]
			end

			it_behaves_like 'a successful request to update the rate'
		end

		context 'for multiple days' do
			let(:rates) do
				{
					"rates": [
						{
							"days": "mon,tues",
							"times": "0900-2100",
							"tz": "America/Chicago",
							"price": 1500
						}
					]
				}
			end

			let(:expected_rate) do
				[
					{ day: 'mon', start_time: '09:00', end_time: '21:00', time_zone: 'America/Chicago', price: 1500 },
					{ day: 'tues', start_time: '09:00', end_time: '21:00', time_zone: 'America/Chicago', price: 1500 }
				]
			end
				
			it_behaves_like 'a successful request to update the rate'

			context 'with overlapping rates' do
				let(:rates) do
					{
						"rates": [
							{
								"days": "mon",
								"times": "0900-2100",
								"tz": "America/Chicago",
								"price": 1500
							},
							{
								"days": "tues",
								"times": "0100-1000",
								"tz": "America/Chicago",
								"price": 2500
							}
						]
					}
				end

				let(:expected_rate) do
					[
						{ day: 'mon', start_time: '09:00', end_time: '21:00', time_zone: 'America/Chicago', price: 1500 },
						{ day: 'tues', start_time: '01:00', end_time: '10:00', time_zone: 'America/Chicago', price: 2500 }
					]
				end
					
				it_behaves_like 'a successful request to update the rate'
			end
		end

		context 'for same day' do
			context 'with non-overlapping rates' do
				let(:rates) do
					{
						"rates": [
							{
								"days": "mon",
								"times": "0900-2100",
								"tz": "America/Chicago",
								"price": 1500
							},
							{
								"days": "mon",
								"times": "0100-0900",
								"tz": "America/Chicago",
								"price": 2500
							}
						]
					}
				end

				let(:expected_rate) do
					[
						{ day: 'mon', start_time: '09:00', end_time: '21:00', time_zone: 'America/Chicago', price: 1500 },
						{ day: 'mon', start_time: '01:00', end_time: '09:00', time_zone: 'America/Chicago', price: 2500 }
					]
				end
					
				it_behaves_like 'a successful request to update the rate'
			end

			context 'with non-overlapping, but touching rates' do
				let(:rates) do
					{
						"rates": [
							{
								"days": "mon",
								"times": "0900-2100",
								"tz": "America/Chicago",
								"price": 1500
							},
							{
								"days": "mon",
								"times": "2100-2400",
								"tz": "America/Chicago",
								"price": 2500
							}
						]
					}
				end

				let(:expected_rate) do
					[
						{ day: 'mon', start_time: '09:00', end_time: '21:00', time_zone: 'America/Chicago', price: 1500 },
						{ day: 'mon', start_time: '21:00', end_time: '24:00', time_zone: 'America/Chicago', price: 2500 }
					]
				end
					
				it_behaves_like 'a successful request to update the rate'
			end

			context 'with overlapping rates' do
				context 'new rate start overlaps' do
					let(:rates) do
						{
							"rates": [
								{
									"days": "mon",
									"times": "0900-2100",
									"tz": "America/Chicago",
									"price": 1500
								},
								{
									"days": "mon",
									"times": "2000-2400",
									"tz": "America/Chicago",
									"price": 2500
								}
							]
						}
					end

					let(:expected_rate) do
						[
							{ day: 'mon', start_time: '09:00', end_time: '21:00', time_zone: 'America/Chicago', price: 1500 },
							{ day: 'mon', start_time: '20:00', end_time: '24:00', time_zone: 'America/Chicago', price: 2500 }
						]
					end
						
					it_behaves_like 'an unsuccessful request to update the rate'
				end

				context 'new rate end overlaps' do
					let(:rates) do
						{
							"rates": [
								{
									"days": "mon",
									"times": "0900-2100",
									"tz": "America/Chicago",
									"price": 1500
								},
								{
									"days": "mon",
									"times": "0100-1000",
									"tz": "America/Chicago",
									"price": 2500
								}
							]
						}
					end

					let(:expected_rate) do
						[
							{ day: 'mon', start_time: '09:00', end_time: '21:00', time_zone: 'America/Chicago', price: 1500 },
							{ day: 'mon', start_time: '01:00', end_time: '10:00', time_zone: 'America/Chicago', price: 2500 }
						]
					end
						
					it_behaves_like 'an unsuccessful request to update the rate'
				end
				
				context 'old rate end within' do
					let(:rates) do
						{
							"rates": [
								{
									"days": "mon",
									"times": "0900-1100",
									"tz": "America/Chicago",
									"price": 1500
								},
								{
									"days": "mon",
									"times": "0800-1200",
									"tz": "America/Chicago",
									"price": 2500
								}
							]
						}
					end
					
					let(:expected_rate) do
						[
							{ day: 'mon', start_time: '09:00', end_time: '11:00', time_zone: 'America/Chicago', price: 1500 },
							{ day: 'mon', start_time: '08:00', end_time: '12:00', time_zone: 'America/Chicago', price: 2500 }
						]
					end
						
					it_behaves_like 'an unsuccessful request to update the rate'
				end
			end
		end
	end
end