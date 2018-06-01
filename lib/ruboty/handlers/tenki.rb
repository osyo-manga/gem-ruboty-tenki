require_relative "../tenki.rb"

module Ruboty module Handlers
	class Tenki < Base
		on(
			Ruboty::Tenki.query_matcher,
			name: "weather",
			description: "天気"
		)

		def weather message
			message.reply(Ruboty::Tenki.get message.body)
		end
	end
end end
