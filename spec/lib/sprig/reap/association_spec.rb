require 'spec_helper'

describe Sprig::Reap::Association do
  let(:polymorphic) { { :polymorphic => true } }
  let(:named_assoc) { { :class_name => 'User' } }
  let(:association) { double('ActiveRecord::Reflection::AssociationReflection', :name => :user, :options => Hash.new) }

  subject { described_class.new(association) }

  describe "#polymorphic?" do
    context "when given a non-polymorphic dependency" do
      its(:polymorphic?) { should == false }
    end

    context "when given a polymorphic dependency" do
      before do
        association.options.merge!(polymorphic)
      end

      its(:polymorphic?) { should == true }
    end
  end

  describe "#klass" do
    context "given a standard association" do
      its(:klass) { should == User }
    end

    context "given a named association" do
      before do
        association.options.merge!(named_assoc)
      end

      its(:klass) { should == User }
    end
  end

  describe "#polymorphic_dependencies" do
    context "when the association is not polymorphic" do
      its(:polymorphic_dependencies) { should == [] }
    end

    context "when the association is polymorphic" do
      let(:models) { double('Models', :select => 'dependencies') }

      before do
        association.options.merge!(polymorphic)
        ActiveRecord::Base.stub(:subclasses).and_return(models)
      end

      its(:polymorphic_dependencies) { should == 'dependencies' }
    end
  end

  describe "#polymorphic_match?" do
    let(:model) { double('Model') }
    let(:match) { { :as => :user } }

    before do
      model.stub(:reflect_on_all_associations).with(:has_many).and_return([association])
    end

    context "when the given model does not have a matching polymorphic association" do
      it "returns false" do
        subject.polymorphic_match?(model).should == false
      end
    end

    context "when the given model has a matching polymorphic association" do
      before do
        association.options.merge!(match)
      end

      it "returns true" do
        subject.polymorphic_match?(model).should == true
      end
    end
  end

  describe "#dependencies" do
    context "when the association is polymorphic" do
      let(:model)  { double('Post') }
      let(:models) { [model] }
      let(:match)  { { :as => :user } }
      let(:assoc)  { double('ActiveRecord::Reflection::AssociationReflection', :name => :post, :options => match) }

      before do
        association.options.merge!(polymorphic)
        ActiveRecord::Base.stub(:subclasses).and_return(models)
        model.stub(:reflect_on_all_associations).with(:has_many).and_return([assoc])
      end

      its(:dependencies) { should == [model] }
    end

    context "when the association is not polymorphic" do
      its(:dependencies) { should == [User] }
    end
  end
end
