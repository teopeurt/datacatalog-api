class Organization

  include MongoMapper::Document
  
  # == Attributes

  key :name,              String
  key :names,             Array
  key :acronym,           String
  key :org_type,          String
  key :description,       String
  key :slug,              String
  key :slug_suffix,       String
  key :url,               String
  key :home_url,          String
  key :catalog_name,      String
  key :catalog_url,       String
  key :user_id,           ObjectId
  key :parent_id,         ObjectId
  key :interest,          Integer
  key :top_level,         Boolean, :default => false
  key :custom,            Hash
  key :raw,               Hash
  key :_keywords,         Array
  key :source_count,      Integer, :default => 0

  timestamps!

  # == Indices

  # == Associations

  belongs_to :parent, :class_name => 'Organization'
  
  many :sources
  many :children, :class_name => 'Organization', :foreign_key => :parent_id

  protected
  
  # == Validations

  include UrlValidator

  validates_presence_of :name
  validate :validate_url
  validate :validate_org_type
  validates_uniqueness_of :slug
  validates_format_of :slug,
    :with      => /\A[a-zA-z0-9\-]+\z/,
    :message   => "can only contain alphanumeric characters and dashes",
    :allow_nil => true

  ORG_TYPES = %w(
    commercial
    governmental
    not-for-profit
  )

  def validate_org_type
    unless ORG_TYPES.include?(org_type)
      errors.add(:org_type, "must be one of: #{ORG_TYPES.join(', ')}")
    end
  end

  # == Callbacks

  before_validation :handle_blank_slug
  def handle_blank_slug
    self.slug = nil if self.slug.blank?
  end
  
  before_create :generate_slug
  def generate_slug
    return unless slug.blank?
    return if name.blank?
    to_slug = acronym.blank? ? name : acronym
    if parent
      suffix = parent.slug_suffix
      to_slug << "-#{suffix}" unless suffix.blank?
    end
    self.slug = Slug.make(to_slug, self)
  end

  before_save :update_keywords
  def update_keywords
    self._keywords = DataCatalog::Search.process(
      names + [name, acronym, description])
  end

  # == Class Methods

  # == Various Instance Methods

end
