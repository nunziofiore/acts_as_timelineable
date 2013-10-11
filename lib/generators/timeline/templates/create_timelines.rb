class CreateTimelines < ActiveRecord::Migration
  def self.up
    create_table :timelines do |t|
      t.string :title,  :default => "" 
      t.text :timeline
      t.references :timelineable, :polymorphic => true
      t.references :timelined, :polymorphic => true
      t.references :user
      t.string :role, :default => "timelines"
      t.timestamps
    end

    add_index :timelines, :timelineable_type
    add_index :timelines, :timelineable_id
    add_index :timelines, :timelined_id
    add_index :timelines, :user_id
  end

  def self.down
    drop_table :timelines
  end
end
