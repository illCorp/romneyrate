module ApplicationHelper
  
  def bitly_url(long_url)
    bitly = Bitly.new(::BITLY_USERNAME,::BITLY_API_KEY)
    begin
      url = bitly.shorten(long_url).shorten 
    rescue
      url = long_url
    end
  end
end
