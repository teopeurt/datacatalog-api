# A note by a particular user about a data source.
#
#   source_id points to the associated source.
#   user_id points to the most recent editor.
class Note

  include MongoMapper::Document

  # == Attributes

  key :text,      String
  key :source_id, ObjectId
  key :user_id,   ObjectId
  timestamps!

  # == Indices

  # == Associations

  belongs_to :source
  belongs_to :user

  protected

  # == Validations

  validates_presence_of :text
  validates_presence_of :source_id
  validates_presence_of :user_id

  validate :general_validation
  def general_validation
    errors.add(:user_id, "must be valid") if user.nil?
    errors.add(:source_id, "must be valid") if source.nil?
  end

  # == Class Methods

  # == Various Instance Methods

end
