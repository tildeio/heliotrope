# frozen_string_literal: true

module EPub
  class Publication
    private_class_method :new
    attr_reader :id, :container, :content_file, :content_dir, :content, :epub_path, :toc

    # Class Methods

    def self.from(epub, options = {})
      id = if epub.is_a?(Hash) && epub.key?(:id) && epub[:id].present?
             epub[:id]
           else
             epub
           end
      return Publication.null_object unless ::EPub.noid?(id&.to_s)
      new(id.to_s)
    rescue StandardError => e
      ::EPub.logger.info("### INFO publication from #{epub} with options #{options} raised #{e} ###")
      Publication.null_object
    end

    def self.null_object
      PublicationNullObject.send(:new)
    end

    # Instance Methods

    def container
      @container ||= Nokogiri::XML(File.open(EPubsService.epub_entry_path(id, "META-INF/container.xml")))
      @container.remove_namespaces!
    end

    def content_file
      @content_file ||= container.xpath("//rootfile/@full-path").text
    end

    def content_dir
      @content_dir ||= File.dirname(content_file)
    end

    def content
      @content ||= Nokogiri::XML(File.open(File.join(epub_path, content_file)))
      @content.remove_namespaces!
    end

    def epub_path
      @epub_path ||= EPubsService.epub_path(id)
    end

    def toc
      # EPUB3 *must* have an item with properties="nav" in their manifest
      @toc ||= Nokogiri::XML(File.open(File.join(epub_path,
                                                 content_dir,
                                                 content.xpath("//manifest/item[@properties='nav']").first.attributes["href"].value)))
      @toc.remove_namespaces!
    end

    def chapter_title_from_toc(chapter_href)
      # Navigation can be way more complicated than this, so this is a WIP
      toc.xpath("//nav/ol/li/a[@href='#{chapter_href}']").text || ""
    end

    def chapters
      chapters = []
      i = 0
      content.xpath("//spine/itemref/@idref").each do |idref|
        i += 1
        content.xpath("//manifest/item").each do |item|
          next unless item.attributes['id'].text == idref.text

          doc = Nokogiri::XML(File.open(File.join(epub_path, content_dir, item.attributes['href'].text)))
          doc.remove_namespaces!

          chapters.push(Chapter.send(:new,
                                     item.attributes['id'].text,
                                     item.attributes['href'].text,
                                     chapter_title_from_toc(item.attributes['href'].text),
                                     "/6/#{i * 2}[#{item.attributes['id'].text}]!",
                                     doc))
        end
      end

      chapters
    end

    def read(file_entry = "META-INF/container.xml")
      return Publication.null_object.read(file_entry) unless Cache.cached?(id)
      EPubsService.read(id, file_entry)
    rescue StandardError => e
      ::EPub.logger.info("### INFO read #{file_entry} not found in publication #{id} raised #{e} ###")
      Publication.null_object.read(file_entry)
    end

    def presenter
      PublicationPresenter.send(:new, self)
    end

    def search(query)
      return Publication.null_object.search(query) unless Cache.cached?(id)
      EPubsSearchService.new(id).search(query)
    rescue StandardError => e
      ::EPub.logger.info("### INFO query #{query} in publication #{id} raised #{e} at: e.backtrace[0] ###")
      Publication.null_object.search(query)
    end

    private

      def initialize(id)
        @id = id
        EPubsService.open(@id) # cache publication
      end
  end
end
