class CreateSapphires < ActiveRecord::Migration
  def change
    create_table :sapphires do |t|
      t.references :user
      t.string :icp_path
      t.string :mns_path
      t.string :third_party_path

      t.timestamps
    end
    add_index :sapphires, :user_id
  end
end
