require "ruboty/tenki/version"
require "ruboty/handlers/tenki"
require "faraday"
require "ostruct"
require "json"
require "date"

using Module.new {
	refine Hash do
		def to_struct
			Struct.new(*keys).new(*values)
		end
	end
}

module Ruboty module Tenki
	module_function
	def http_get_json url, query
		res = Faraday.get url, query
		JSON[res.body, symbolize_names: true]
	end

	def query_matcher
		dates_regexp = "今日|きょう|明日|あした|明後日|あさって|今|いま|3日後|３日後|4日後|４日後"
		@query_matcher ||= /
			(
				(?<city>.*)の(?<day>#{dates_regexp})の(天気|てんき).*
			)|(
				(?<day>#{dates_regexp})の(?<city>.*)の(天気|てんき)
			)
		/ux
	end

	def query_match? str
		str =~ Tenki.query_matcher
	end

	def query_parse str
		if str =~ Tenki.query_matcher
			data = Regexp.last_match
			day = data[:day]
			case day
			when /今日|きょう/u
				day = :today
			when /明日|あした/u
				day = :tomorrow
			when /明後日|あさって/u
				day = :day_after_tomorrow
			when /3日後|３日後/
				day = 3
			when /4日後|４日後/
				day = 4
			when /今|いま/
				day = :current
			end

			OpenStruct.new(city: data[:city], day: day)
		else
			nil
		end
	end

	def get_geocode address
		url = "https://maps.googleapis.com/maps/api/geocode/json"
		request = { address: address, key: ENV["RUBOTY_TENKI_GOOGLE_MAP_APIKEY"], language: :ja }

		res = http_get_json url, request
		if res[:status] != "OK"
			return
		end

		res[:results].first.yield_self { |it|
			{
				address: it[:formatted_address],
				location: it.dig(:geometry, :location)
			}
		}
	end

	def weather query
		return unless option = Tenki.query_parse(query)
		return unless geocode = Tenki.get_geocode(option.city)

		request = {
			lat: geocode.dig(:location, :lat),
			lon: geocode.dig(:location, :lng),
			units: "metric",
			APPID: ENV["RUBOTY_TENKI_OPEN_WEATHER_MAP_APPID"],
			lang: "ja"
		}

		forecast = proc { |date|
			http_get_json("http://api.openweathermap.org/data/2.5/forecast", request).yield_self { |res|
				res[:list].select! { |it|
					date_ = DateTime.parse(it[:dt_txt])
					date_.day == date.day
				}
				res.merge(date: date)
			}
		}

		case option.day
		when :current
			http_get_json "http://api.openweathermap.org/data/2.5/weather", request
		when :today
			forecast.call Date.today
		when :tomorrow
			forecast.call (Date.today + 1)
		when :day_after_tomorrow
			forecast.call (Date.today + 2)
		end.merge(day: option.day, request: request, geocode: geocode)
	end
	
	using Module.new {
		refine Hash do
			def to_str_weather
				<<~EOS
					天候：#{self[:weather][0][:description]}
					気温：#{dig(:main, :temp)}℃
					湿度：#{dig(:main, :humidity)}％
					気圧：#{dig(:main, :pressure)}hPa
				EOS
			end

			def to_str_weather_line
				main = self[:main]
				data = {
					time: DateTime.parse(self[:dt_txt]).strftime("%H:%M"),
					weather: "%10s" % self[:weather][0][:description],
					temp:     "%3d" % main[:temp].round,
					humidity: "%3d" % main[:humidity],
					pressure: "%4d" % main[:pressure],
				}
				"#{data[:time]}  #{data[:weather]}  #{data[:temp]}℃  #{data[:humidity]}%  #{data[:pressure]}hPa"
			end
		end
	}

	def get query
		res = Tenki.weather(query)
		
		if res.nil? || res[:cod].to_i != 200
			return "見つかりませんでした"
		end
		if res[:day] == :current
			<<~EOS
				#{res.dig(:geocode, :address)}の天気
				#{res.to_str_weather}
			EOS
		else
			<<~EOS
				#{res.dig(:geocode, :address)}
				#{res[:date].strftime("%Y/%m/%d")} の天気
				#{res[:list].map(&:to_str_weather_line).join("\n")}
			EOS
		end.chomp
	end
end end
