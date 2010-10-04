class Tagging

  include MongoMapper::Document

  # == Attributes

  key :source_id, ObjectId
  key :tag_id,    ObjectId
  key :user_id,   ObjectId
  timestamps!

  # == Indices
  
  ensure_index :source_id
  ensure_index :tag_id
  ensure_index :user_id

  # == Associations

  belongs_to :source
  belongs_to :tag
  belongs_to :user

  # == Validations

  validates_presence_of :source_id
  validates_presence_of :tag_id
  validates_presence_of :user_id

  validate :general_validation
  def general_validation
    errors.add(:source_id, "must be valid") if source.nil?
    errors.add(:tag_id, "must be valid") if tag.nil?
    errors.add(:user_id, "must be valid") if user.nil?
  end

  # == Callbacks

  after_create :increment_source_count
  def increment_source_count
    adjust_source_count(self.tag, 1)
    true
  end

  after_destroy :decrement_source_count
  def decrement_source_count
    adjust_source_count(self.tag, -1)
    true
  end

  before_update :save_previous
  def save_previous
    @previous_tag_id = self.tag_id_change[0]
    true
  end

  after_update :restore_previous
  def restore_previous
    if @previous_tag_id
      previous_tag = Tag.find_by_id(@previous_tag_id)
      adjust_source_count(previous_tag, -1)
    end
    adjust_source_count(self.tag, 1)
    true
  end

  # == Class Methods

  # == Various Instance Methods
  
  public
  
  protected

  def adjust_source_count(tag, delta)
    if tag
      if tag.source_count
        tag.source_count += delta
      else
        tag.source_count = delta
      end
      tag.save!
    end
  end

end
