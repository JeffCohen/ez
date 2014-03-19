require 'json'
require 'open-uri'

module EZ

  def self.weather(location = 'Evanston, IL')
    # Only cache up to 30 locations to avoid abuse
    @wx = {} unless @wx && @wx.keys.count < 30

    # Cache based on location
    @wx[location] ||= begin
      puts "Getting the current weather from openweathermap.org..."
      wx = from_api("http://api.openweathermap.org/data/2.5/weather?q=#{location}&units=imperial")
      @wx[location] = wx[:main]
    end

  end

  def self.from_api(uri_string)
    uri = URI.parse(URI.escape(uri_string))
    string = open(uri).read
    JSON.parse(string, symbolize_names: true)
  end

end

