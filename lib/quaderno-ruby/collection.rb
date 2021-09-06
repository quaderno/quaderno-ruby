class Quaderno::Collection < Array
  include Quaderno::Helpers::RateLimit

  def request_options=(options)
    @request_options = options
  end

  def collection_type=(collection_type)
    @collection_type = collection_type
  end

  def has_more=(has_more_response)
    @has_more = has_more_response
  end

  def next_page_url=(next_page_url)
    @next_page_url = next_page_url
  end

  def has_more?
    @has_more == 'true'
  end

  def next_page_cursor
    return unless @next_page_url

    @next_page_url.to_s.match(/created_before=(\d+)/)&.[](1)
  end

  def next_page
    return Quaderno::Collection.new unless has_more?
    @collection_type.all_from_url(@next_page_url, @request_options)
  end
end
