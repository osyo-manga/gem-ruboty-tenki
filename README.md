# Ruboty::Tenki

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/ruboty/tenki`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruboty-tenki'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ruboty-tenki

## Usage

```shell
> ruboty 今日の東京の天気は
日本、東京都東京
2018/02/01 の天気
00:00           雲    3℃   75%  1038hPa
03:00           雲    7℃   91%  1038hPa
06:00        曇りがち    6℃   82%  1037hPa
09:00          小雨    3℃   87%  1038hPa
12:00          小雨    2℃   92%  1039hPa
15:00          小雨    1℃   94%  1040hPa
18:00          小雨    0℃   96%  1039hPa
21:00           雪    0℃   92%  1039hPa
```


## ENV

```
RUBOTY_LINE_CHANNEL_SECRET - YOUR LINE BOT Channel Secret.
RUBOTY_LINE_CHANNEL_TOKE   - YOUR LINE BOT Channel token.
RUBOTY_LINE_ENDPOINT       - LINE bot endpoint(Callback URL). (e.g. '/message/reply'
LOG_LEVEL                  - Use Ruboty logger. If LOG_LEVEL=0, output debug log.
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ruboty-tenki.
