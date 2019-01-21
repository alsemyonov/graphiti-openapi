root = File.expand_path("../..", __dir__)
packs = File.directory?("app/assets/packs") ? "app/assets/packs" : "app/javascripts/packs"

say "Copying api.js to #{packs}/"
copy_file "#{root}/app/assets/packs/api.js", "#{packs}/api.js"

say "Copying openapi.yml to config/"
copy_file "#{root}/config/openapi.yml", "config/openapi.yml"

say "Ignoring openapi specifications"
File.write ".gitignore", "" unless File.file?(".gitignore")
append_to_file ".gitignore" do
  <<~IGNORE
    public/api/v1/openapi.json
    public/api/v1/openapi.yaml
  IGNORE
end

say "Installing JavaScript dependencies"
run "yarn add swagger-ui"
