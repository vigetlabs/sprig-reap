require 'spec_helper'

class Very; end

describe Sprig::Reap::Record do
  let(:record)       { double('ActiveRecord::Base Instance') }
  let(:model)        { double('Sprig::Reap::Model') }
  let(:reap_record)  { double('Sprig::Reap::Record for class Very', :sprig_id => 5) }
  let(:association) do
    double('Sprig::Reap::Association',
      :foreign_key  => "very_id",
      :klass        => Very,
      :polymorphic? => false
    )
  end
  let(:sprig_record) { "<%= sprig_record(Very, 5).id %>" }

  subject { described_class.new(record, model) }

  before do
    attrs = {
      'id'      => 0,
      'such'    => 1,
      'wow'     => 2,
      'very_id' => 3
    }

    attrs.each_pair do |attr, val|
      record.stub(attr).and_return(val)
    end

    model.stub(:attributes).and_return(attrs.keys)
    model.stub(:existing_sprig_ids).and_return([])
    model.stub(:associations).and_return([association])

    Sprig::Reap::Model.stub(:find).and_return(reap_record)
  end

  its(:id) { should == 0 }

  describe "#attributes" do
    it "returns an array of attributes from the given model sans id" do
      subject.attributes.should == %w(
        such
        wow
        very_id
      )
    end
  end

  describe "#to_hash" do
    it "returns its attributes and their values in a hash" do
      subject.to_hash.should == {
        'sprig_id' => 0,
        'such'     => 1,
        'wow'      => 2,
        'very_id'  => sprig_record
      }
    end
  end

  describe "#sprig_id" do
    its(:sprig_id) { should == record.id }

    context "when an existing seed record has a sprig_id equal to the record's id" do
      before do
        model.stub(:existing_sprig_ids).and_return([record.id])
        model.stub(:generate_sprig_id).and_return(25)
      end

      its(:sprig_id) { should == 25 }
    end
  end
end
