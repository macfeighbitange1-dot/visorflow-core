class AddLastUsedAtToWorkloads < ActiveRecord::Migration[8.0]
  def change
    add_column :workloads, :last_used_at, :datetime
  end
end
