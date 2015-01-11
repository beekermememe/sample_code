class DestinationContent
  attr_reader :introductions, :place_name, :transport, :weather
  def initialize(params={})
    @introductions = params[:introductions]
    @weather = params[:weather]
    @place_name = params[:title_ascii]
    @transport = params[:transport][:local]
  end
end