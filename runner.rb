# 1 read in the data
require "destination_taxonomy_ingestor"
require "destination_meta_data_ingestor"
require "destination_doc_builder"
require "pry"

taxonomy_ingestor = DestinationTaxonomyIngestor.new({
  taxonomy_file: "#{Dir.pwd}/input/taxonomy.xml",
})

metadata_ingestor = DestinationMetaDataIngestor.new({
  destinations_file: "#{Dir.pwd}/input/destinations.xml",
})

destinations = taxonomy_ingestor.ingest
destination_data = metadata_ingestor.ingest

# Update data objects with content
destinations.each do |atlas_id,destination_object|
  destination_object.update_destination_content(destination_data[atlas_id])
end

doc_builder = DestinationDocBuilder.new(destinations,"output")

doc_builder.populate_html_files
# 3 open up the template and populate it using the model

# for each object populate the template and write the file