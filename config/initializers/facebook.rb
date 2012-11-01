config_path = File.expand_path(File.dirname(__FILE__)+"/../facebook.yml")
FACEBOOK_CONFIG = YAML.load(File.read(config_path))[Rails.env]
