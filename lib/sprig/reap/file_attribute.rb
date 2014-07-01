module Sprig::Reap
  class FileAttribute
    attr_reader :input

    def initialize(input)
      @input = input
    end

    def file
      local_file if file?
    end

    def file?
      input.is_a? CarrierWave::Uploader::Base
    end

    def existing_location
      begin
        input.url
      rescue
        input.path
      end
    end

    def filename
      File.basename(existing_location)
    end

    def target_location
      Rails.root.join('db', 'seeds', Sprig::Reap.target_env, 'files', filename)
    end

    def local_file
      @local_file ||= LocalFile.new(existing_location, target_location)
    end

    private

    class LocalFile < Struct.new(:uri, :target_location)
      def file
        @file ||= File.open(target_location, 'w', :encoding => encoding).tap do |file|
          io.rewind
          file.write(io.read)
        end
      end

      def io
        @io ||= open uri
      end

      def encoding
        io.rewind
        io.read.encoding
      end

      def path
        file.path
      end
    end
  end
end
