require 'spec_helper'

describe Sprig::Reap do
  describe ".reap" do
    let(:seed_file) { double('Sprig::Reap::SeedFile', :write => 'such seeds') }

    before do
      stub_rails_root
      stub_rails_env
      Sprig::Reap::SeedFile.stub(:new).and_return(seed_file)
    end

    around do |example|
      setup_seed_folder('./spec/fixtures/db/seeds/dreamland', &example)
    end

    after do
      subject.clear_config
    end

    it "outputs log messages when starting and on completion" do
      log_should_receive :debug, :with => "Reaping records from the database...\r"
      log_should_receive :debug, :with => "Finished reaping!"

      subject.reap
    end

    it "generates a seed file for each model" do
      count = Sprig::Reap.models.count

      seed_file.should_receive(:write).exactly(count).times

      subject.reap
    end

    context "when passed an environment in the options hash" do
      context "in :target_env" do
        it "sets the environment" do
          subject.reap(:target_env => 'dreamland')
          subject.target_env.should == 'dreamland'
        end
      end

      context "in 'TARGET_ENV'" do
        it "sets the environment" do
          subject.reap('TARGET_ENV' => ' Dreamland')
          subject.target_env.should == 'dreamland'
        end
      end
    end

    context "when passed a set of models in the options hash" do
      context "in :models" do
        it "sets the models" do
          subject.reap(:models => [User, Post])

          subject.models.all? { |model| model.class == Sprig::Reap::Inputs::Model }.should == true
          subject.models.map(&:klass).should == [User, Post]
        end
      end

      context "in 'MODELS'" do
        it "sets the models" do
          subject.reap('MODELS' => 'User, Post')

          subject.models.all? { |model| model.class == Sprig::Reap::Inputs::Model }.should == true
          subject.models.map(&:klass).should == [User, Post]
        end
      end

      context "as an ActiveRecord::Relation" do
        it "sets the relation to one of the models" do
          subject.reap(:models => [Post.published.with_content])

          subject.models.all? { |model| model.class == Sprig::Reap::Inputs::Model }.should == true
          subject.models.map(&:klass).should == [Post]
        end
      end
    end

    context "when passed a list of ignored attributes in the options hash" do
      context "in :ignored_attrs" do
        it "sets ignored attributes" do
          subject.reap(:ignored_attrs => [:willy, :nilly])
          subject.ignored_attrs.should == ['willy', 'nilly']
        end
      end

      context "in IGNORED_ATTRS" do
        it "sets ignored attributes" do
          subject.reap('IGNORED_ATTRS' => ' willy, nilly')
          subject.ignored_attrs.should == ['willy', 'nilly']
        end
      end
    end

    context "when passed a value for omitting empty attributes in the options hash" do
      context "in :omit_empty_attrs" do
        it "sets the flag to omit empty attributes" do
          subject.reap(:omit_empty_attrs => true)
          subject.omit_empty_attrs.should == true
        end
      end

      context "in OMIT_EMPTY_ATTRS" do
        it "sets the flag to omit empty attributes" do
          subject.reap('OMIT_EMPTY_ATTRS' => ' TRUE ')
          subject.omit_empty_attrs.should == true
        end
      end
    end
  end

  describe ".clear_config" do
    it "sets the configuration to nil" do
      subject.clear_config

      subject.class_variable_get(:@@configuration).should == nil
    end
  end
end
