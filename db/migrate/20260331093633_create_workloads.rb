class CreateWorkloads < ActiveRecord::Migration[8.0]
  def change
    create_table :workloads do |t|
      t.string :agent_id
      t.string :status
      t.string :internal_ip
      t.datetime :last_health_check
      t.text :code_snippet

      t.timestamps
    end
  end
end
