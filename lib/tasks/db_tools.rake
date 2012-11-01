MYAPP_IN_RAKE = true

def connect_to_s3
  if (@s3_connection.nil?)
    config_path = File.join(Rails.root, "config", "aws.yml")
    config = YAML.load(File.read(config_path))[ENV['RAILS_ENV']]
    @s3_connection = Fog::Storage.new(
        :provider                 => 'AWS',
        :aws_secret_access_key    => config['secret_access_key'],
        :aws_access_key_id        => config['access_key_id']
    )
  end
end

namespace :db do
  desc "Reinitialize Database completely"
  task :reinit, [:target] => :environment do |t, args|
    orig_env = ENV['RAILS_ENV']
    ENV['RAILS_ENV'] = args[:target] if args[:target]
    ActiveRecord::Base.observers.disable :all
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:seed'].invoke
    ENV['RAILS_ENV'] = orig_env
  end
  
  desc "takes a snapshot of the database"
  task :backup, [:source] => :environment do |t, args|
    env = (args[:source]) ? args[:source] : ENV['RAILS_ENV']
    database_config = YAML.load_file(File.join(Rails.root, "config", "database.yml"))[env]
    paperclip_config = YAML.load_file(File.join(Rails.root, "config", "paperclip.yml"))[env]
    bucket = paperclip_config['bucket']

    filename = "#{Rails.application.class.parent_name.downcase}_#{env}_#{Time.now.strftime('%F-%T').gsub(':', '_')}.sql"
    file_path = Tempfile.new(filename)#File.join(Rails.root, 'tmp', filename)

    dump_statement = "pg_dump -u#{database_config['username']} -p#{database_config['password']} -h #{database_config['host']} -P #{database_config['port']} #{database_config['database']}  > #{file_path}"
    puts dump_statement
    `#{dump_statement}`
    `gzip #{file_path}`
    connect_to_s3()
    
    storage_directory = @s3_connection.directories.get(bucket)
  
    data = File.read("#{file_path}.gz")
  
    file = storage_directory.files.create(
      :key    => "backups/#{File.basename(filename)}.gz",
      :body   => data,
      :public => false
    )
  
    file = storage_directory.files.create(
      :key    =>  'backups/latest.sql.gz',
      :body   => data,
      :public => false
    )    
    
    File.delete("#{file_path}.gz")
  end

  desc "takes a snapshot of the database and pushes it to the target server's database"
  task :push, [:source, :target] => :environment do |t, args|
    require 'open-uri'
    
    source = args[:source]
    target = args[:target]
    
    raise ArgumentError, 'Pushing to production is not allowed!' if target == 'production'
    
    Rake::Task["db:backup"].invoke(source)
    
    paperclip_config = YAML.load_file(File.join(Rails.root, "config", "paperclip.yml"))[source]
    database_config = YAML.load_file(File.join(Rails.root, "config", "database.yml"))[target]
    
    connect_to_s3()
    
    bucket = AWS::S3::Bucket.find(paperclip_config['bucket'])
    latest_file = bucket.objects(:prefix => "backups/latest.sql").first
    
    # get the latest
    temp_file = File.join(Rails.root, 'tmp', 'latest.sql')
    open(temp_file, 'wb') do |file|
      file.write open(latest_file.url).read
    end
    
    base_statement = "psql"
    base_statement << " -u #{database_config['username']}" unless database_config['username'].nil?
    base_statement << " -p#{database_config['password']}" unless database_config['password'].nil?
    base_statement << " -h #{database_config['host']}" unless database_config['host'].nil?
    base_statement << " -P #{database_config['port']}" unless database_config['port'].nil?
    
    # clear out the db
    clear_statement = "#{base_statement} DROP #{database_config['database']} --force"
    recreate_statement = "#{base_statement} CREATE #{database_config['database']}"

    puts clear_statement
    puts `#{clear_statement}`

    puts recreate_statement
    puts `#{recreate_statement}`
    
    base_statement = "psql"
    base_statement << " -u #{database_config['username']}" unless database_config['username'].nil?
    base_statement << " -p#{database_config['password']}" unless database_config['password'].nil?
    base_statement << " -h #{database_config['host']}" unless database_config['host'].nil?
    base_statement << " -P #{database_config['port']}" unless database_config['port'].nil?
    
    # send it to the db
    dump_statement = "#{base_statement} #{database_config['database']} < #{temp_file}"
    puts dump_statement

    puts `#{dump_statement}`
  end
end