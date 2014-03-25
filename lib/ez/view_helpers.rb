module EZ
  module ViewHelpers

    def map(location, options = {})
      defaults = { :zoom => 12, :scale => 1, :size => '400x400', :type => 'hybrid', :sensor => false}
      parameters = defaults.merge(options)
      parameters[:center] = location
      qstring = parameters.keys.map { |key| "#{key}=#{parameters[key]}" }.join('&')
      url = "http://maps.googleapis.com/maps/api/staticmap?#{qstring}"
      image_tag URI.escape(url)
    end

  end
end
