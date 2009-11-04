module DataCatalog

  class Sources < Base
    include Resource
  
    model Source
    
    # == Permissions

    roles Roles
    permission :list   => :basic
    permission :read   => :basic
    permission :create => :curator
    permission :update => :curator
    permission :delete => :curator

    # == Properties

    property :title
    property :slug
    property :description
    property :source_type
    property :license
    property :catalog_name
    property :url
    property :documentation_url
    property :license_url
    property :catalog_url
    property :released
    property :period_start
    property :period_end
    property :frequency
    property :organization_id
    property :custom
    property :raw,              :w => :admin
    property :rating_stats,     :w => :nobody

    property :updates_per_year do |source|
      Frequency.new(source.frequency).per_year
    end
    
    property :categories do |source|
      source.categorizations.map do |categorization|
        {
          "href" => "/categories/#{categorization.category.id}",
          "name" => categorization.category.name,
        }
      end
    end

    property :comments do |source|
      source.comments.map do |comment|
        nested_comment(comment)
      end
    end
    
    property :documents do |source|
      source.documents.map do |document|
        {
          "href" => "/documents/#{document.id}",
          "text" => document.text,
          "user" => {
            "name" => document.user.name,
            "href" => "/users/#{document.user.id}",
          }
        }
      end
    end

    property :notes do |source|
      source.notes.map do |note|
        {
          "href" => "/notes/#{note.id}",
          "text" => note.text,
          "user" => {
            "name" => note.user.name,
            "href" => "/users/#{note.user.id}",
          }
        }
      end
    end
    
    property :organization do |source|
      nested_organization(source)
    end
    
    property :ratings do |source|
      source.ratings.map do |rating|
        {
          "href"  => "/ratings/#{rating.id}",
          "text"  => rating.text,
          "value" => rating.value,
          "user"  => {
            "name" => rating.user.name,
            "href" => "/users/#{rating.user.id}",
          }
        }
      end
    end

    # == Callbacks

    callback :before_create do |action|
      action.validate_custom_before_create(action.params["custom"])
    end
    
    callback :before_update do |action, source|
      custom = action.params["custom"]
      action.validate_custom_before_update(custom)
      action.params["custom"] = action.class.merge_custom_fields(source.custom, custom)
    end

    CUSTOM_ATTRIBUTES = %w(label description type value)
    
    def validate_custom_before_create(custom)
      return if custom.nil?
      custom.length.times do |i|
        unless custom.include?(i.to_s)
          error 400, { "errors" => "malformed custom field" }.to_json
        end
      end
      errors = []
      custom.each do |field, attrs|
        self.class.missing_custom_attrs(attrs).each do |attr|
          errors << "custom[#{field}] is missing attribute: #{attr}"
        end
        self.class.invalid_custom_attrs(attrs).each do |attr|
          errors << "custom[#{field}] has invalid attribute: #{attr}"
        end
      end
      unless errors == []
        error 400, { "errors" => errors }.to_json 
      end
    end

    def validate_custom_before_update(custom)
      return if custom.nil?
      errors = []
      custom.each do |field, attrs|
        return if attrs.nil?
        self.class.invalid_custom_attrs(attrs).each do |attr|
          errors << "custom[#{field}] has invalid attribute: #{attr}"
        end
      end
      unless errors == []
        error 400, { "errors" => errors }.to_json
      end
    end

    def self.merge_custom_fields(old_custom, new_custom)
      return if new_custom.nil?
      return new_custom if old_custom.nil?
      old_custom.to_hash.merge(new_custom) do |key, left, right|
        right.nil? ? nil : left.merge(right)
      end
    end
    
    def self.missing_custom_attrs(hash)
      CUSTOM_ATTRIBUTES - hash.keys
    end
    
    def self.invalid_custom_attrs(hash)
      hash.keys - CUSTOM_ATTRIBUTES
    end
    
    def self.nested_comment(comment)
      parent = if comment.parent_id
        {
          "href" => "/comments/#{comment.parent_id}",
          "id"   => comment.parent_id,
        }
      else
        nil
      end
      {
        "href" => "/comments/#{comment.id}",
        "text" => comment.text,
        "user" => {
          "name" => comment.user.name,
          "href" => "/users/#{comment.user.id}",
        },
        "rating_stats" => comment.rating_stats,
        "parent" => parent
      }
    end

    def self.nested_organization(source)
      if source.organization_id
        {
          "href" => "/organizations/#{source.organization_id}",
          "name" => source.organization.name,
          "slug" => source.organization.slug,
        }
      else
        nil
      end
    end

  end
  
  Sources.build

end
