# frozen_string_literal: true

require 'zip'

class EPubService
  def self.read(epub_id, file_entry) # called from EPubController.file
    epub_entry_file = EPubService.epub_entry_path(epub_id, file_entry)
    EPubService.cache_epub_entry(epub_id, file_entry) unless File.exist?(epub_entry_file)
    FileUtils.touch(EPubService.epub_path(epub_id))
    File.read(epub_entry_file)
  end

  def self.cache_epub_entry(epub_id, file_entry) # called from EPubService.read
    epub_entry_file = EPubService.epub_entry_path(epub_id, file_entry)
    return if File.exist?(epub_entry_file)

    epub_file = FileSet.find(epub_id)&.original_file
    raise EPubServiceError, "EPub #{epub_id} file is nil." if epub_file.nil?

    EPubServiceJob.perform_later(epub_id) unless Dir.exist?(EPubService.epub_path(epub_id))

    begin
      Zip::File.open_buffer(epub_file.content) do |zip_file|
        EPubService.make_epub_entry_path(epub_id, file_entry)
        zip_file.extract(file_entry, epub_entry_file) unless File.exist?(epub_entry_file)
      end
    rescue Errno::ENOENT
      raise EPubServiceError, "Entry #{file_entry} in EPub #{epub_id} does not exist."
    rescue Zip::Error
      raise EPubServiceError, "EPub #{epub_id} is corrupt."
    end
  end

  def self.cache_epub(epub_id) # called from EPubServiceJob
    epub_file = FileSet.find(epub_id)&.original_file
    raise EPubServiceError, "EPub #{epub_id} file is nil." if epub_file.nil?
    begin
      Zip::File.open_buffer(epub_file.content) do |zip_file|
        zip_file.each do |entry|
          EPubService.make_epub_entry_path(epub_id, entry.name)
          entry.extract(EPubService.epub_entry_path(epub_id, entry.name)) unless File.exist?(EPubService.epub_entry_path(epub_id, entry.name))
        end
      end
    rescue Zip::Error
      raise EPubServiceError, "EPub #{epub_id} is corrupt."
    end
  end

  def self.prune_cache # called from EPubServiceJob
    return unless Dir.exist?(EPubService.epubs_path)
    Dir.glob(File.join(EPubService.epubs_path, "*")).each do |entry|
      FileUtils.rm_rf(entry) if (Time.now - File.mtime(entry)) / 1.day > 1
    end
  end

  def self.clear_cache # not being called (no use case)
    return unless Dir.exist?(EPubService.epubs_path)
    FileUtils.rm_rf(Dir.glob(File.join(EPubService.epubs_path, "*")))
  end

  # Helper Methods...

  def self.epubs_path
    Rails.root.join('tmp', 'epubs')
  end

  def self.epub_path(epub_id)
    File.join(EPubService.epubs_path, epub_id)
  end

  def self.epub_entry_path(epub_id, file_entry)
    File.join(EPubService.epub_path(epub_id), file_entry)
  end

  def self.make_epub_entry_path(epub_id, file_entry)
    FileUtils.mkdir_p(EPubService.epubs_path) unless Dir.exist?(EPubService.epubs_path)
    epub_dir = EPubService.epub_path(epub_id)
    file_entry.split(File::SEPARATOR).each do |sub_dir|
      FileUtils.mkdir_p(epub_dir) unless Dir.exist?(epub_dir)
      epub_dir = File.join(epub_dir, sub_dir)
    end
  end
end