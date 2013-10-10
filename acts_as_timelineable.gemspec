# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{acts_as_timelineable}
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nunzio Fiore"]
  s.autorequire = %q{acts_as_timelineable}
  s.description = %q{Plugin/gem that provides timeline functionality}
  s.email = %q{info@laboop.com}
  s.extra_rdoc_files = ["README.rdoc", "MIT-LICENSE"]
  s.files = ["MIT-LICENSE", "README.rdoc", "lib/acts_as_timelineable.rb", "lib/timeline_methods.rb", "lib/timelineable_methods.rb", "lib/generators", "lib/generators/timeline", "lib/generators/timeline/timeline_generator.rb", "lib/generators/timeline/templates", "lib/generators/timeline/templates/timeline.rb", "lib/generators/timeline/templates/create_timelines.rb", "lib/generators/timeline/USEGA", "init.rb", "install.rb"]
  s.has_rdoc = false
  s.homepage = %q{http://www.laboop.com/}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Plugin/gem that provides timeline functionality}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
