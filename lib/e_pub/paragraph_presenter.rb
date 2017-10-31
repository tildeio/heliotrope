# frozen_string_literal: true

module EPub
  class ParagraphPresenter < Presenter
    private_class_method :new

    def text
      @paragraph.text.html_safe # rubocop:disable Rails/OutputSafety
    end

    private

      def initialize(paragraph = Paragraph.null_object)
        @paragraph = paragraph
      end
  end
end