module DataCatalog

  module UriHelpers
    def full_uri(path)
      base_uri = Config.environment_config["base_uri"]
      URI.join(base_uri, path).to_s
    end
  end

  class Base
    helpers UriHelpers
  end

end