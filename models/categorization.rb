class Categorization

  include MongoMapper::Document
  include Renderable

  # == Attributes

  key :source_id,   String
  key :category_id, String
  timestamps!

  # == Indices

  # == Associations

  belongs_to :source
  belongs_to :category

  # == Derived Fields

  # == Validations

  # == Class Methods

  # == Derived Fields

  # == JSON Output

  # == Various Instance Methods

end