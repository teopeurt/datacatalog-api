class Categorization

  include MongoMapper::Document

  # == Attributes

  key :source_id,   ObjectId
  key :category_id, ObjectId
  timestamps!

  # == Indices
  
  ensure_index :source_id
  ensure_index :category_id

  # == Associations

  belongs_to :source
  belongs_to :category

  # == Validations

  validates_presence_of :source_id
  validates_presence_of :category_id

  validate :general_validation
  def general_validation
    errors.add(:source_id, "must be valid") if source.nil?
    errors.add(:category_id, "must be valid") if category.nil?
  end

  # == Callbacks

  after_create :increment_source_count
  def increment_source_count
    adjust_source_count(self.category, 1)
    true
  end

  after_destroy :decrement_source_count
  def decrement_source_count
    adjust_source_count(self.category, -1)
    true
  end

  before_update :save_previous
  def save_previous
    @previous_category_id = self.category_id_change[0]
    true
  end

  after_update :restore_previous
  def restore_previous
    if @previous_category_id
      previous_category = Category.find_by_id(@previous_category_id)
      adjust_source_count(previous_category, -1)
    end
    adjust_source_count(self.category, 1)
    true
  end

  # == Class Methods

  # == Various Instance Methods
  
  public
  
  protected

  def adjust_source_count(category, delta)
    if category
      if category.source_count
        category.source_count += delta
      else
        category.source_count = delta
      end
      category.save!
    end
  end

end
