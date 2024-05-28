require 'httparty'

class WatchModeApi
  include HTTParty
  base_uri 'https://api.watchmode.com/v1'

  def initialize(watchmode_api_key)
    @watchmode_api_key = watchmode_api_key
  end

  def get_sources(regions)
    self.class.get("/sources/?apiKey=#{@watchmode_api_key}&regions=#{regions}").parsed_response
  end

  def get_title_details(title_id, regions)
    self.class.get("/title/#{title_id}/sources/?apiKey=#{@watchmode_api_key}&regions=#{regions}").parsed_response
  end
end
