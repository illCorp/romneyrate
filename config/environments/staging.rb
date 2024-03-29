Romneyrate::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  config.action_controller.asset_host = "https://romneyrate-staging.s3.amazonaws.com"

  config.assets.compress = false
  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = true
  config.assets.debug = false
  #config.assets.js_compressor  = nil
  #config.assets.css_compressor = nil
  config.serve_static_assets = false
  #  config.assets.digest = true
 
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = true

  config.perform_caching = true
  config.action_controller.perform_caching = true

  config.after_initialize do
    config.cache_store = :dalli_store, 'dev-cache.vzvdas.0001.use1.cache.amazonaws.com:11211',
      { :namespace => "romneyrate_staging", :expires_in => 1.day, :compress => true }
  end

  # Specifies the header that your server uses for sending files
  # (comment out if your front-end server doesn't support this)
  config.action_dispatch.x_sendfile_header = "X-Sendfile" # Use 'X-Accel-Redirect' for nginx
  

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default :charset => "utf-8"
  config.action_mailer.logger =  Logger.new("log/action_mailer-#{Rails.env}.log")
  config.action_mailer.logger.level = Logger::DEBUG
  
  
  ActionMailer::Base.smtp_settings = {
      :address => "smtp.sendgrid.net",
      :port => 587,
      :domain => "romneyrate.org",
      :authentication => :plain,
      :user_name => "mranauro@meeps.com",
      :password => "Beantown79*",
      :enable_starttls_auto => true
  }
  
  
  
end
