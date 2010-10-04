class Tag

  include MongoMapper::Document

  # == Attributes

  key :name,         String
  key :slug,         String
  key :source_count, Integer, :default => 0
  timestamps!

  # == Indices

  # == Indices

  ensure_index :name
  ensure_index :slug

  # == Associations

  many :taggings

  def sources
    taggings.map(&:source)
  end

  # == Validations

  validates_presence_of :name
  validates_uniqueness_of :slug
  validates_format_of :slug,
    :with      => /\A[a-zA-z0-9\-]+\z/,
    :message   => "can only contain alphanumeric characters and dashes",
    :allow_nil => true

  before_validation :handle_blank_slug
  def handle_blank_slug
    self.slug = nil if self.slug.blank?
  end

  # == Callbacks

  before_create :generate_slug
  def generate_slug
    return unless slug.blank?
    return if name.blank?
    self.slug = Slug.make(name, self)
  end

  # == Class Methods

  # == Various Instance Methods

end
