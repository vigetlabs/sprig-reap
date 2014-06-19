module RailsStubs
  # Setup fake `Rails.root`
  def stub_rails_root(path='./spec/fixtures')
    Rails.stub(:root).and_return(Pathname.new(path))
  end

  # Setup fake `Rails.env`
  def stub_rails_env(env='development')
    Rails.stub(:env).and_return(env)
  end

  def stub_rails_application
    application_double = double("application", :eager_load! => true)

    Rails.stub(:application).and_return(application_double)
  end
end
