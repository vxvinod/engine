class CreatePcas < ActiveRecord::Migration
  def change
    create_table :pcas do |t|
      t.references :user
      t.string :icp_path
      t.string :mns_path
      t.string :third_party_path

      t.timestamps
    end
    add_index :pcas, :user_id
  end
end
