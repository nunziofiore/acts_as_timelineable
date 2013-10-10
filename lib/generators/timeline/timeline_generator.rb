require 'rails/generators/migration'

class TimelineGenerator < Rails::Generators::Base
  include Rails::Generators::Migration

  def self.source_root
    @_acts_as_timelineable_source_root ||= File.expand_path("../templates", __FILE__)
  end

  def self.next_migration_number(path)
    Time.now.utc.strftime("%Y%m%d%H%M%S")
  end

  def create_model_file
    template "timeline.rb", "app/models/timeline.rb"
    migration_template "create_timelines.rb", "db/migrate/create_timelines.rb"
  end
end
