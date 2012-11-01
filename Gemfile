source 'https://rubygems.org'

gem 'pg'
gem 'rails', '3.2.8'
gem 'bundler'
gem 'whenever'
gem 'aws-sdk'
gem 'haml'
gem 'paperclip'
gem 'capistrano'
gem 'capistrano_colors'
gem 'capistrano-ext'
gem 'rvm-capistrano'
gem 'unicorn'
gem 'koala'
gem 'mailcatcher', :group => [:development, :szehnder, :test]
gem 'dalli'

group :development, :szehnder, :test, :staging do 
  gem 'linecache19', '0.5.13'
  gem 'ruby-debug-base19', '0.11.26'
  gem 'ruby-debug19', :require => 'ruby-debug'
end

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'sqlite3'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'asset_sync', :git => 'git@github.com:illCorp/asset_sync.git'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'