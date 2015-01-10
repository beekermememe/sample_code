# 1 read in the data
require "destination_data_ingestor"
require "pry"

ingestor = DestinationDataIngestor.new({
  taxonomy_file: "#{Dir.pwd}/input/taxonomy.xml",
  destinations_file: "#{Dir.pwd}/input/destinations.xml"
})
destinations = ingestor.ingest
binding.pry
# 2 break data into an object or hash

# 3 open up the template

# for each object populate the template and write the file