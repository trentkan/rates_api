require 'rails_helper'

describe RatesProcessor do
	describe '#create' do
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

			it 'creates the rate' do
				expect(Rate).to receive(:import).with([
					{ day: 'mon', start_time: '09:00', end_time: '21:00', time_zone: 'America/Chicago', price: 1500 }
				])
				
				subject.create(rates[:rates])
			end
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

			it 'creates the rate' do
				expect(Rate).to receive(:import).with([
					{ day: 'mon', start_time: '09:00', end_time: '21:00', time_zone: 'America/Chicago', price: 1500 },
					{ day: 'tues', start_time: '09:00', end_time: '21:00', time_zone: 'America/Chicago', price: 1500 }
				])
				
				subject.create(rates[:rates])
			end

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

				it 'does not creates the rate' do
					expect(Rate).to receive(:import).with([
						{ day: 'mon', start_time: '09:00', end_time: '21:00', time_zone: 'America/Chicago', price: 1500 },
						{ day: 'tues', start_time: '01:00', end_time: '10:00', time_zone: 'America/Chicago', price: 2500 }
					])
					
					subject.create(rates[:rates])
				end
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

				it 'creates the rate' do
					expect(Rate).to receive(:import).with([
						{ day: 'mon', start_time: '09:00', end_time: '21:00', time_zone: 'America/Chicago', price: 1500 },
						{ day: 'mon', start_time: '01:00', end_time: '09:00', time_zone: 'America/Chicago', price: 2500 }
					])
					
					subject.create(rates[:rates])
				end
			end

			context 'with non-overlapping, but touching' do
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

				it 'creates the rate' do
					expect(Rate).to receive(:import).with([
						{ day: 'mon', start_time: '09:00', end_time: '21:00', time_zone: 'America/Chicago', price: 1500 },
						{ day: 'mon', start_time: '21:00', end_time: '24:00', time_zone: 'America/Chicago', price: 2500 }
					])
					
					subject.create(rates[:rates])
				end
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

					it 'does not creates the rate' do
						expect(Rate).not_to receive(:import).with([
							{ day: 'mon', start_time: '09:00', end_time: '21:00', time_zone: 'America/Chicago', price: 1500 },
							{ day: 'mon', start_time: '20:00', end_time: '24:00', time_zone: 'America/Chicago', price: 2500 }
						])
						
						subject.create(rates[:rates])
					end
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

					it 'does not creates the rate' do
						expect(Rate).not_to receive(:import).with([
							{ day: 'mon', start_time: '09:00', end_time: '21:00', time_zone: 'America/Chicago', price: 1500 },
							{ day: 'mon', start_time: '01:00', end_time: '10:00', time_zone: 'America/Chicago', price: 2500 }
						])
						
						subject.create(rates[:rates])
					end
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
					
					it 'does not creates the rate' do
						expect(Rate).not_to receive(:import).with([
							{ day: 'mon', start_time: '09:00', end_time: '11:00', time_zone: 'America/Chicago', price: 1500 },
							{ day: 'mon', start_time: '08:00', end_time: '12:00', time_zone: 'America/Chicago', price: 2500 }
						])
						
						subject.create(rates[:rates])
					end
				end
			end
		end
	end
end