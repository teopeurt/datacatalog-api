module DataCatalog

  class Categories < Base
    include Resource

    model Category

    # == Permissions

    roles Roles
    permission :list   => :basic
    permission :read   => :basic
    permission :create => :curator
    permission :update => :curator
    permission :delete => :curator

    # == Properties

    property :name

    property :sources do |category|
      category.sources.map do |source|
        {
          "href" => "/sources/#{source.id}"
        }
      end
    end

  end

  Categories.build

end
