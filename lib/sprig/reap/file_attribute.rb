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
        input.url if input.url.present? && open(input.url).is_a?(Tempfile)
      rescue
        input.path
      end
    end

    def filename
      File.basename(existing_location)
    end

    def target_folder
      @target_folder ||= begin
        path = Rails.root.join('db', 'seeds', Sprig::Reap.target_env, 'files')
        FileUtils.mkdir_p(path)
        path
      end
    end

    def target_location
      target_folder.join(filename)
    end

    def local_file
      @local_file ||= LocalFile.new(existing_location, target_location)
    end

    private

    class LocalFile < Struct.new(:uri, :target_location)
      delegate :path, :size, :to => :file

      def file
        @file ||= File.open(unique_location, 'w', :encoding => encoding).tap do |file|
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

      def sprig_location
        "<%= sprig_file('#{File.basename(file.path)}') %>"
      end

      private

      def unique_location
        File.exist?(target_location) ? target_location.to_s.gsub(basename, basename + rand(99999).to_s) : target_location
      end

      def basename
        @basename ||= File.basename(target_location).gsub(File.extname(target_location), '')
      end
    end
  end
end
