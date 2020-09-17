# frozen_string_literal: true

class ShareEbookPolicy < ApplicationPolicy
  alias_attribute :ebook, :target

  def allowed?
    press = Sighrax.press(ebook)
    ebook_policy.show? && press.allow_share_links?
  end

  def initialize(actor, target, ebook_policy:)
    super(actor, target)
    @ebook_policy = ebook_policy
  end

  private

    attr_reader :ebook_policy
end
