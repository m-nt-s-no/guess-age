require "sinatra"
require "sinatra/reloader"
require "http"
require "json"

get("/") do
  erb(:form)
end

get("/test") do
  @title = params.fetch("article_title")
  @guess_age = params.fetch("guess_age").to_i
  formatted_title = @title.gsub(" ", "%20")
  url = "https://en.wikipedia.org/w/api.php?action=parse&page=#{formatted_title}&format=json"
  http_response = HTTP.get(url)
  parsed_response = JSON.parse(http_response)
  if parsed_response.include?("error")
    erb(:error_invalid_response)
  else
    parse = parsed_response.fetch("parse")
    text = parse.fetch("text")
    star_text = text.fetch("*")
    if star_text.include?("<span class=\"noprint ForceAgeToShow\">") == false
      erb(:error_no_bday)
    else
      age = star_text[/<span class=\"noprint ForceAgeToShow\">(.*)<\/span>/]
      formatted_age = age.gsub("&#160;", " ")
      @age_num = formatted_age[/(\d+)/].to_i
      diff = (@guess_age - @age_num).abs
      if diff == 0
        @right_or_wrong = "correct!"
        @end_text = "Way to go!"
      else
        @right_or_wrong = "wrong :("
      end
      if (diff > 0) && (diff < 5)
        @end_text = "You were close though!"
      elsif diff > 5
        @end_text = "Not even close lol"
      end
      erb(:test)
    end
  end
end
