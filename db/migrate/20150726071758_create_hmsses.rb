class CreateHmsses < ActiveRecord::Migration
  def change
    create_table :hmsses do |t|

      t.timestamps
    end
  end
end
