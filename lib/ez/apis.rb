require 'json'
require 'open-uri'

module JSON

  def self.from_api(uri_string)
    uri = URI.parse(URI.escape(uri_string))
    data = open(uri).read
    JSON.parse(data)
  end

end

