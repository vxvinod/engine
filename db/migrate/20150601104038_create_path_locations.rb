class CreatePathLocations < ActiveRecord::Migration
  def change
    create_table :path_locations do |t|
      t.string :path

      t.timestamps
    end
  end
end
