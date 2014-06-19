namespace :db do
  namespace :seed do
    desc 'Create Sprig seed files from database records'
    task :reap => :environment do
      Sprig::Reap.reap(ENV)
    end
  end
end
