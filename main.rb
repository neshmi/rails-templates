#Main Template
 
# Delete unnecessary files
  run "rm README"
  run "rm public/index.html"
  run "rm public/favicon.ico"
  run "rm public/robots.txt"
  run "rm -f public/javascripts/*"
 
# Download JQuery
  run "curl -L http://jqueryjs.googlecode.com/files/jquery-1.2.6.min.js > public/javascripts/jquery.js"
  run "curl -L http://jqueryjs.googlecode.com/svn/trunk/plugins/form/jquery.form.js > public/javascripts/jquery.form.js"
 
# Set up git repository
  git :init
  git :add => '.'
  
# Copy database.yml for distribution use
  # run "cp config/database.yml config/database.yml.example"
  
# Set up .gitignore files
  run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
  run %{find . -type d -empty | grep -v "vendor" | grep -v ".git" | grep -v "tmp" | xargs -I xxx touch xxx/.gitignore}
  file '.gitignore', <<-END
.DS_Store
log/*.log
tmp/**/*
db/*.sqlite3
END
 
# Install submoduled plugins
  plugin 'role_requirement', :git => 'git://github.com/timcharper/role_requirement.git', :submodule => true
  plugin 'restful-authentication', :git => 'git://github.com/technoweenie/restful-authentication.git', :submodule => true
  plugin 'attachment_fu', :git=>'git://github.com/technoweenie/attachment_fu.git', :submodule=>true
 
# Install all gems
  gem 'sqlite3-ruby', :lib => 'sqlite3'
  gem 'hpricot', :source => 'http://code.whytheluckystiff.net'
  gem 'RedCloth', :lib => 'redcloth'
  rake('gems:install', :sudo => true)
 
# Set up sessions, RSpec, user model, OpenID, etc, and run migrations
  rake('db:sessions:create')
  generate("authenticated", "user session")
  generate("rspec")
  rake('acts_as_taggable:db:create')
  rake('db:migrate')
 
# Set up session store initializer
  initializer 'session_store.rb', <<-END
ActionController::Base.session = { :session_key => '_#{(1..6).map { |x| (65 + rand(26)).chr }.join}_session', :secret => '#{(1..40).map { |x| (65 + rand(26)).chr }.join}' }
ActionController::Base.session_store = :active_record_store
  END
 
# Initialize submodules
  git :submodule => "init"
 
# Commit all work so far to the repository
  git :add => '.'
  git :commit => "-a -m 'Initial commit'"
 
# Success!
  puts "SUCCESS!"