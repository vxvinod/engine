class AddSimulatorPathToPlums < ActiveRecord::Migration
  def change
    add_column :plums, :simulator_path, :string
  end
end
