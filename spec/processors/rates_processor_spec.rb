require 'rails_helper'

describe RatesProcessor do
	describe '#create' do
		shared_examples 'a successful request to update the rate' do
			it 'creates the rate' do
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