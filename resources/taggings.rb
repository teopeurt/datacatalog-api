module DataCatalog

  class Taggings < Base
    include Resource

    model Tagging

    # == Permissions

    roles Roles
    permission :list   => :basic
    permission :read   => :basic
    permission :create => :basic
    permission :update => :owner
    permission :delete => :owner

    # == Properties

    property :source_id
    property :tag_id
    property :user_id,   :w => :nobody

    property :source do |tagging|
      if tagging.source_id
        if source = tagging.source
          {
            "title" => source.title,
            "href"  => "/sources/#{source.id}",
          }
        end
      end
    end

    property :tag do |tagging|
      if tagging.tag_id
        if tag = tagging.tag
          {
            "name" => tag.name,
            "slug" => tag.slug,
            "href" => "/tags/#{tag.id}"
          }
        end
      end
    end

    # == Callbacks

    callback :before_create do |action|
      raise "expecting current_user" unless action.current_user
      action.params["user_id"] = action.current_user.id
    end

  end

  Taggings.build

end
