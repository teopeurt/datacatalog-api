ENV['RACK_ENV'] = "test"
require 'app'
map("/")                { run DataCatalog::Root }
map("/broken_links")    { run DataCatalog::BrokenLinks }
map("/catalogs")        { run DataCatalog::Catalogs }
map("/categories")      { run DataCatalog::Categories }
map("/categorizations") { run DataCatalog::Categorizations }
map("/checkup")         { run DataCatalog::Checkup }
map("/comments")        { run DataCatalog::Comments }
map("/documents")       { run DataCatalog::Documents }
map("/downloads")       { run DataCatalog::Downloads }
map("/favorites")       { run DataCatalog::Favorites }
map("/importers")       { run DataCatalog::Importers }
map("/imports")         { run DataCatalog::Imports }
map("/notes")           { run DataCatalog::Notes }
map("/organizations")   { run DataCatalog::Organizations }
map("/ratings")         { run DataCatalog::Ratings }
map("/reports")         { run DataCatalog::Reports }
map("/resources")       { run DataCatalog::Resources }
map("/sources")         { run DataCatalog::Sources }
map("/source_groups")   { run DataCatalog::SourceGroups }
map("/taggings")        { run DataCatalog::Taggings }
map("/tags")            { run DataCatalog::Tags }
map("/users")           { run DataCatalog::Users }
