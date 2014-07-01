RSpec::Matchers.define(:be_same_file_as) do |exected_file|
  match do |actual_file|
    md5_hash(relevant_contents_of(actual_file)).should == md5_hash(relevant_contents_of(exected_file))
  end

  def md5_hash(string)
    Digest::MD5.hexdigest(string)
  end

  def relevant_contents_of(file)
    file.read.encode('UTF-8', 'binary', :invalid => :replace, :undef => :replace, :replace => '').tap do |contents|
      contents.sub!(/\/Title[^\n]*/, '')
      contents.sub!(/\/CreationDate[^\n]*/, '')
      contents.sub!(/\/ModDate[^\n]*/, '')
      contents.sub!(/\/Producer[^\n]*/, '')
      contents.sub!(/\/ID[^\]]*/, '')
      contents.sub!(/\/DocChecksum[^\n]*/, '')
      contents.sub!(/startxref\n[\d]+/, '')
    end
  end
end
