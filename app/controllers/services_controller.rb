class ServicesController < ApplicationController
  def index
    @services = Service.all
  end

  def show
    @service = Service.find(params[:id])
  end

  def new
    @lists = List.all
  end

  def create
    @list = List.find(params[:list_id])
    watchmode_api = WatchModeApi.new(ENV['WATCHMODE_API_KEY'])
    add_streaming_info_to_titles(@list.titles, watchmode_api)
    redirect_to services_path, notice: 'Streaming information added successfully'
  end

  private

  def add_streaming_info_to_titles(titles, watchmode_api)
    titles.each do |title|
      title_id = "#{title.media_type}-#{title.tmdb_id}"
      streaming_sources = watchmode_api.get_title_details(title_id, 'US')

      streaming_sources.select { |source| source['format'] == 'HD' }.each do |source|
        service = Service.find_or_create_by(name: source['name']) do |s|
          s.watchmode_id = source['id']
          s.logo_url = source['logo_100px']
        end

        Streaming.create!(
          url: source['web_url'],
          service: service,
          title: title,
          streaming_type: source['type']
        )
      end
    end
  end
end
