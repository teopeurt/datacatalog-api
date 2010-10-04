module DataCatalog

  class Tags < Base
    include Resource

    model Tag

    # == Permissions

    roles Roles
    permission :list   => :basic
    permission :read   => :basic
    permission :create => :basic
    permission :update => :owner
    permission :delete => :owner

    # == Properties

    property :name
    property :slug
    property :source_count

  end

  Tags.build

end
