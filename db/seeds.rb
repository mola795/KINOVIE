require 'httparty'
require 'faker'

puts "Cleaning the DB..."
# Destroy all records for seeded objects
# Object.destroy_all

class WatchModeApi
  include HTTParty
  base_uri 'https://api.watchmode.com/v1'

  def get_sources(regions)
    # Where regions is a comma separated string of 2 character country codes
    # available from the watchmode /regions endpoint
    api_key = 'Wa0xNagkzZLawLxWCcarWIGDwFW6bILgqpJrokZf'
    self.class.get("/sources/?apiKey=#{api_key}&regions=#{regions}")
  end

  # def get_source_details(source_id)
  #   api_key = 'Wa0xNagkzZLawLxWCcarWIGDwFW6bILgqpJrokZf'
  #   sources = self.class.get("/sources/?apiKey=#{api_key}&regions=#{regions}")
  # end

  def get_title_details(title_id, regions)
    # Where regions is a comma separated string of 2 character country codes
    # available from the watchmode /regions endpoint
    api_key = 'Wa0xNagkzZLawLxWCcarWIGDwFW6bILgqpJrokZf'
    self.class.get("/title/#{title_id}/sources/?apiKey=#{api_key}&regions=#{regions}")
  end
end

watchmode_api = WatchModeApi.new

# Seed all available sources
services = watchmode_api.get_sources('')
services.each do |service|
  Service.create(
    name: service.name,
    watchmode_id: service.id
  )
end

# For each title seeded, seed the streaming service Ids & URL
# Where title_id = current title looping through (from TMDB/OMDB seeding)
streaming_sources = watchmode_api.get_title_details(imdb_id, '')
streaming_sources.select{|streaming_src| streaming_src["format"] == 'HD'}.each do |streaming_src|
  service = Service.where(name: streaming_src['name']).first
  title = Title.where(imdb_id: imdb_id).first
  streaming = Streaming.new(
    url: streaming_src['web_url'],
    # service_id: service.id
  )
  streaming.service = service
  streaming.title = title
  streaming.save
end

sources = watchmode_api.get_title_details('tt3416742', 'CA,US')

puts "Starting to seed books..."




user = User.create!(
  email: Faker::Internet.email,
  first_name: Faker::Name.first_name,
  last_name: Faker::Name.last_name,
  password: "123456"
)
