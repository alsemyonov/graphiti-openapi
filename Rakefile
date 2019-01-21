require "bundler/setup"
require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'rdoc/task'

APP_RAKEFILE = File.expand_path("spec/dummy/Rakefile", __dir__)
load 'rails/tasks/engine.rake'
task environment: "app:yarn:install"
load 'rails/tasks/statistics.rake'

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Graphiti::OpenAPI'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

RSpec::Core::RakeTask.new(:spec)
task default: :spec
