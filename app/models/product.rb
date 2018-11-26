# frozen_string_literal: true

class Product < ApplicationRecord
  include Filterable

  scope :identifier_like, ->(like) { where("identifier like ?", "%#{like}%") }
  scope :name_like, ->(like) { where("name like ?", "%#{like}%") }
  scope :entity_id_like, ->(like) { where("entity_id like ?", "%#{like}%") }

  has_many :components_products
  has_many :components, through: :components_products
  has_many :lessees_products
  has_many :lessees, through: :lessees_products

  validates :identifier, presence: true, allow_blank: false, uniqueness: true
  validates :name, presence: true, allow_blank: false
  # validates :purchase, presence: true, allow_blank: false

  before_destroy do
    if components.present?
      errors.add(:base, "product has #{components.count} associated components!")
      throw(:abort)
    end
    if lessees.present?
      errors.add(:base, "product has #{lessees.count} associated lessees!")
      throw(:abort)
    end
    if grants.present?
      errors.add(:base, "product has #{grants.count} associated grants!")
      throw(:abort)
    end
  end

  def update?
    true
  end

  def destroy?
    components.blank? && lessees.blank? && grants.blank?
  end

  def not_components
    Component.where.not(id: components.map(&:id))
  end

  def individuals
    Individual.where(identifier: lessees.map(&:identifier))
  end

  def institutions
    Institution.where(identifier: lessees.map(&:identifier))
  end

  def not_lessees
    Lessee.where.not(id: lessees.map(&:id))
  end

  def grants
    Grant.resource_grants(self)
  end

  def resource_type
    :Product
  end

  def resource_id
    id
  end
end
