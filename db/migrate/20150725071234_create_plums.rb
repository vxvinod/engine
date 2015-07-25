class CreatePlums < ActiveRecord::Migration
  def change
    create_table :plums do |t|
      t.references :user
      t.string :icp_path
      t.string :mns_path
      t.string :third_party_path

      t.timestamps
    end
    add_index :plums, :user_id
  end
end
