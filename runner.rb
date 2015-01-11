# 1 read in the data
require "destination_taxonomy_ingestor"
require "destination_meta_data_ingestor"
require "destination_doc_builder"


# Call this with the first argument as the taxonomy file (full path), the second argument and the destinations file (full path)
# and the third argument with the output directory location (full path))
# If one of these are incorrectly entered, it will use a preset default - demo purpose only

taxonomy_file = ARGV[0]
destinations_file = ARGV[1]
output_directory = ARGV[2]


taxonomy_file ||= "#{Dir.pwd}/input/taxonomy.xml"
destinations_file ||= "#{Dir.pwd}/input/destinations.xml"
output_directory ||= "#{Dir.pwd}/output"

# Check file types
if !File.exists?(taxonomy_file)
  puts "Taxonomy file does not exist - #{taxonomy_file}"
  exit
elsif !File.exists?(destinations_file)
  puts "Taxonomy file does not exist - #{destinations_file}"
  exit
elsif !Dir.exists?(output_directory)
  puts "Output Directory does not exist - #{output_directory}"
  exit
end

puts "FYI - processing parameters :\n Taxonomy file -> #{taxonomy_file}\n Destinations file -> #{destinations_file}\n Output location -> #{output_directory}"

# ingest the taxonomy and destinations data
taxonomy_ingestor = DestinationTaxonomyIngestor.new({
  taxonomy_file: taxonomy_file,
})

metadata_ingestor = DestinationMetaDataIngestor.new({
  destinations_file: destinations_file,
})

destinations = taxonomy_ingestor.ingest
destination_data = metadata_ingestor.ingest

# Update data objects with content
destinations.each do |atlas_id,destination_object|
  destination_object.update_destination_content(destination_data[atlas_id])
end

# 3 open up the template and populate it using the model
doc_builder = DestinationDocBuilder.new(destinations,"#{output_directory}")
doc_builder.populate_html_files

