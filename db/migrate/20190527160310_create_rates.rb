class CreateRates < ActiveRecord::Migration[5.2]
  def change
    create_table :rates do |t|
    	t.string :day, null: false
    	t.time :start_time, null: false
    	t.time :end_time, null: false
    	t.string :time_zone, null: false
    	t.integer :price, null: false
      t.timestamps
    end
  end
end
