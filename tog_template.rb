
module Colored
  extend self
  COLORS = {'green' => 32, 'yellow' => 33, 'blue' => 34}
  EXTRAS = {'clear' => 0, 'bold' => 1}

  COLORS.each do |color, value|
    define_method(color) { colorize(self, :foreground => color) }
    define_method("on_#{color}") { colorize(self, :background => color) }
    COLORS.each do |highlight, value|
      next if color == highlight
      define_method("#{color}_on_#{highlight}") { colorize(self, :foreground => color, :background => highlight) }
    end
  end

  EXTRAS.each do |extra, value|
    next if extra == 'clear'
    define_method(extra) { colorize(self, :extra => extra) }
  end

  define_method(:to_eol) do
    tmp = sub(/^(\e\[[\[\e0-9;m]+m)/, "\\1\e[2K")
    if tmp == self
      return "\e[2K" << self
    end
    tmp
  end

  def colorize(string, options = {})
    colored = [color(options[:foreground]), color("on_#{options[:background]}"), extra(options[:extra])].compact * ''
    colored << string
    colored << extra(:clear)
  end

  def colors
    @@colors ||= COLORS.keys.sort
  end

  def extra(extra_name)
    extra_name = extra_name.to_s
    "\e[#{EXTRAS[extra_name]}m" if EXTRAS[extra_name]
  end

  def color(color_name)
    background = color_name.to_s =~ /on_/
    color_name = color_name.to_s.sub('on_', '')
    return unless color_name && COLORS[color_name]
    "\e[#{COLORS[color_name] + (background ? 10 : 0)}m"
  end

end unless Object.const_defined? :Colored

String.send(:include, Colored)

def silence!
#  Rails::Generator::Base.logger.quiet = true
end

def verbum!
#  Rails::Generator::Base.logger.quiet = false
end

def add_desert_require
  sentinel = 'Rails::Initializer.run do |config|'
  gsub_file 'config/environment.rb', /(#{Regexp.escape(sentinel)})/mi, "\nrequire 'desert'\n\\1"
end

def create_bundler_gemfile
  rails_version = ask "What version of rails should this project use?"
  puts 'Creating Gemfile...'
  file "Gemfile", %Q{
source 'http://gems.github.com'
source 'http://gemcutter.org'
gem 'rails',                            '#{rails_version}'
gem 'tog-tog',                          '>= 0.5',   :require_as => 'tog'
gem 'mislav-will_paginate',             '~> 2.3.6', :require_as => 'will_paginate'
gem 'desert',                           '>= 0.5.2'
gem 'thoughtbot-factory_girl',                      :require_as => 'factory_girl', :only => :testing
gem 'thoughtbot-shoulda',               '>=2.10.1', :require_as => 'shoulda', :only => :testing
gem 'mocha',                            '0.9.7',    :only => :testing
gem 'jackdempsey-acts_as_commentable',  '2.0.1',    :require_as => 'acts_as_commentable'
gem 'mreinsch-acts_as_rateable',        '2.0.1',    :require_as => 'acts_as_rateable'
gem 'RedCloth',                         '>= 4.2.0', :require_as => 'redcloth'
gem 'mbleigh-acts-as-taggable-on',      '1.0.5',    :require_as => 'acts-as-taggable-on'
gem 'linkingpaths-acts_as_abusable',    '0.0.2',    :require_as => 'acts_as_abusable'
gem 'rubyist-aasm',                     '~> 2.1.1', :require_as => 'aasm'
  }
end

def install_tog_core_plugins
  quiet_git_install('tog_core', "git://github.com/aspgems/tog_core.git", TOG_RELEASE )
  quiet_git_install('tog_social', "git://github.com/aspgems/tog_social.git", TOG_RELEASE )
  quiet_git_install('tog_mail', "git://github.com/aspgems/tog_mail.git", TOG_RELEASE )

  route "map.routes_from_plugin 'tog_core'"
  puts "* adding tog_core routes to host app... #{"added".green.bold}";
  route "map.routes_from_plugin 'tog_social'"
  puts "* adding tog_tog_social routes to host app... #{"added".green.bold}";
  route "map.routes_from_plugin 'tog_mail'"
  puts "* adding tog_mail routes to host app... #{"added".green.bold}";

  generate "update_tog_migration"
  puts "* generating tog_core migration... #{"generated".green.bold}";
end

def install_acts_as_commentable
  generate "comment"
  puts "* acts_as_commentable installed... #{"generated".green.bold}";
end

def generate_acts_as_rateable_migration
  generate "acts_as_rateable_migration "
  puts "* acts_as_rateable migration... #{"generated".green.bold}";
end

def generate_acts_as_shareable_migration
  generate "share_migration"
  puts "* acts_as_shareable migration... #{"generated".green.bold}";
end

def generate_acts_as_abusable_migration
  generate "acts_as_abusable_migration"
  puts "* acts_as_abusable migration... #{"generated".green.bold}";
end

def generate_acts_as_taggable_migration
  generate "acts_as_taggable_on_migration"
  puts "* acts_as_taggable migration... #{"generated".green.bold}";
end

def generate_acts_as_scribe_migration
  generate "acts_as_scribe_migration"
  puts "* acts_as_scribe migration... #{"generated".green.bold}";
end

def install_tog_user_plugin
  verbum!

  if STDIN.gets.strip == ""
    silence!

    quiet_git_install("restful_authentication", "git://github.com/technoweenie/restful-authentication.git")
    File.rename "vendor/plugins/restful-authentication", "vendor/plugins/restful_authentication"

    rake "auth:gen:site_key"

    quiet_git_install('tog_user', "git://github.com/aspgems/tog_user.git", TOG_RELEASE)

    route "map.routes_from_plugin 'tog_user'"
    puts "* adding routes to host app... #{"added".green.bold}";
  else
    silence!
  end
end

def install_svn_plugins(plugins)
  plugins.each_pair do |name, url|
    print "* #{name}... "; STDOUT.flush
    plugin name, :svn => url
    puts "installed".green.bold
  end
end

def install_git_plugins(plugins)
  plugins.each_pair do |name, url|
    quiet_git_install(name, url)
  end
end

def install_plugins_with_template(plugins)
  plugins.each_pair do |name, template|
    print "* #{name}..."; STDOUT.flush
    rake "rails:template LOCATION=#{template}"
  end
end

def quiet_git_install(name, url, tag=nil)
  tag = tag && tag != EDGE ? "-r tag #{tag}'": ""
  print "* #{name} #{tag if tag}... ";
  plugin name, :git => "#{tag} #{url}"
  # Open3 doesn't work on windows, so no quiet install
  # resolution = "installed".green
  #   command = "script/plugin install #{url}"
  #   command << " -r 'tag #{tag}'" if tag && tag != EDGE
  #    Open3.popen3(command) { |stdin, stdout, stderr|
  #      stdout.each { |line| resolution = "already installed -> skipped".yellow if line =~ /already installed/; STDOUT.flush }
  #    }
  # puts resolution.bold
end

def aspsocial_intro_banner
  puts %q{
Welcome to ASPgem's Tog-based sites generator! This program wraps the Tog
installer adding a couple of steps, so next you will:

 1. Install bundler, create the Gemfile and bundle gems.
 2. Configure and create development database (youll need a user with
    'create database' privileges).
 3. Run Tog installer.

Besides, it will change the origin of some plugins, add tog_blueprint so that
extended views use blueprint css framework, clean up the resulting application,
etc.

Before starting, you may want to take a look at ASPsocial development wiki for known
issues, guides...

Press Enter to continue, or Ctrl-C to abort.}
STDIN.gets
end

def introduction_banner
  puts %q{
This installer will guide you through the tog integration process. The installer
downloads a few plugins over the internet so the time it takes depends in a great
measure of your bandwidth, but usually it should take a few minutes.

Here's what you can expect from the installation process:

 1. All the tog's dependencies will be installed for you.
 2. The installer will generate a few migrations required by the dependencies
 4. The host app will be a working tog instance after the installation.

Don't worry if anything goes wrong. This installer will advise you on how to
solve any problems.

Press Enter to continue, or Ctrl-C to abort.}
STDIN.gets
end

def tog_user_banner
  puts <<-eos
Tog includes its own user authentication library: tog_user. It's based
on the great restful-authentication plugin and well suited to work out-the-box.

If you're creating a new app #{"it's definitely recommended to install this plugin".green.bold}.
If you've already using a user library in the host app you can skip this step.

Press Enter to install tog_user, or 'n' to skip this step
eos
end

def congratulations_banner
  puts <<-eos
Hurrah!... everything should be fine now. Some things you could try:

* Run the tests. Just run: '#{"rake db:test:prepare && rake tog:plugins:test".green.bold}'.
* Start the app in your favorite server and check your new, shiny tog installation.
* Visit http://wiki.github.com/tog/tog if you need technical read about the platform.
* You can install more tog plugins. For a list of available plugins check
  http://www.toghq.com/tog_plugins

eos
end

def installation_step(title, &block)
  puts "\n--------------------------------------------  \n\n"
  puts "#{title.yellow_on_blue.bold} \n\n"
  yield
end

EDGE = "EDGE"
TOG_RELEASE = EDGE
#TOG_RELEASE = "v0.5.4"
APP_NAME = @root.split('/').last

silence!

installation_step "..:: ASPgems Social ::.." do
  aspsocial_intro_banner
end

installation_step "Install bundler and bundle gems..." do
  if yes?("Install bundler with sudo?")
    run 'sudo gem install bundler'
  else
    run 'gem install bundler'
  end
  create_bundler_gemfile
  puts 'Bundling gems...'
  run 'gem bundle'
  puts 'Creating preinitializer...'
  file 'config/preinitializer.rb', %q{
require "#{RAILS_ROOT}/vendor/gems/environment"

class Rails::Boot
  def run
    load_initializer
    extend_environment
    Rails::Initializer.run(:set_load_path)
  end

  def extend_environment
    Rails::Initializer.class_eval do
      old_load = instance_method(:load_environment)
      define_method(:load_environment) do
        Bundler.require_env RAILS_ENV
        old_load.bind(self).call
      end
    end
  end
end
}
end

# Create the project's databases
installation_step "#{APP_NAME} database configuration" do
  # Rename database.yml for distribution use
  run 'mv config/database.yml config/database.yml.example'
  adapter  = ask 'Database adapter [mysql]:'
  database = ask "Database name [#{APP_NAME}_development]:"
  username = ask 'Username [root]:' unless adapter == 'sqlite3'
  password = ask 'Password []:' unless adapter == 'sqlite3'
  encoding = ask 'Encoding [utf8]:'

  database_config = <<-EOS
\s\sadapter: #{adapter.blank? ? 'mysql' : adapter}
\s\sencoding: #{encoding.blank? ? 'utf8' : encoding}
\s\sreconnect: false
\s\spool: 5
  EOS

  database_config << %Q{\s\susername: #{username.blank? ? 'root' : username}\n} if username
  database_config << %Q{\s\spassword: #{password}\n} if password

  database_yml = <<-EOF
development:
\s\sdatabase: #{database.blank? ? APP_NAME + '_development' : database}
#{database_config}

  EOF

  if yes? "Do you want me to create the test database (#{APP_NAME + '_test'})?"
    database_yml << <<-EOF
test:
\s\sdatabase: #{APP_NAME + '_test'}
#{database_config}
  EOF
  end

  file 'config/database.yml', database_yml
  rake 'db:create:all'
end

installation_step "Welcome to the Tog installer #{TOG_RELEASE}" do
  introduction_banner
end

installation_step "Installing plugin dependencies..." do

  install_svn_plugins({
    'seo_urls'          => "http://svn.redshiftmedia.com/svn/plugins/seo_urls"
  })

  #also installed restful_authentication by tog_user optional part
  install_git_plugins({
    'acts_as_scribe'    => "git://github.com/linkingpaths/acts_as_scribe.git",
    'paperclip'         => "git://github.com/thoughtbot/paperclip.git",
    'viking'            => "git://github.com/technoweenie/viking.git",
    'acts_as_shareable' => "git://github.com/molpe/acts_as_shareable.git",
    'fckeditor'         => "git://github.com/molpe/fckeditor.git"
  })

end

installation_step "Generating dependencies migrations..." do
  install_acts_as_commentable
  generate_acts_as_rateable_migration
  generate_acts_as_abusable_migration
  generate_acts_as_taggable_migration
  generate_acts_as_scribe_migration
  generate_acts_as_shareable_migration
end


installation_step "Installing tog_user plugin..." do
  tog_user_banner
  install_tog_user_plugin
end

installation_step "Installing tog core plugins..." do
  install_tog_core_plugins
end

installation_step "Installing tog blueprint plugin..." do
  install_git_plugins({
    'tog_blueprint' => 'git://github.com/aspgems/tog_blueprint.git'
  })
end

installation_step "Installing optional plugins..." do
  %w[ tog_conversatio ].each do |plugin|
    if yes? "Install #{plugin}?"
      install_plugins_with_template({
        plugin => "http://tr.im/aspgems_#{plugin}"
      })
    end
  end
end

installation_step "Updating the host app files..." do
  add_desert_require
  environment( "config.reload_plugins = true if RAILS_ENV == 'development'" )
  append_file 'Rakefile', "require 'tasks/tog'\n"
  puts "* including tog rake tasks... #{"done".green.bold}";

  rake "tog:plugins:copy_resources"
  puts "* copy tog plugins resources... #{"done".green.bold}";
  rake "db:migrate"
  puts "* run migrations... #{"done".green.bold}";
  File.delete 'public/index.html'
  puts "* removing index.html... #{"done".green.bold}";
end

installation_step "Tog #{TOG_RELEASE} installed" do
  congratulations_banner
end
