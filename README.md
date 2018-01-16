# Logman

[![Build Status](https://semaphoreci.com/api/v1/renderedtext/logman/branches/master/badge.svg)](https://semaphoreci.com/renderedtext/logman)

Logman introduces a unified logging format in your project. Every log line is an
*event* that is logged to the STDOUT or to file.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "rt-logman"
```

## Basic Usage

To log an informative message to STDOUT, use the following code snippet:

``` ruby
Logman.info("Hello World")

# Output:
# {"level":"INFO","time":"2017-12-12 09:33:00 +0000","pid":10950,"message":"Hello World"}
```

Every log event can be extended with metadata — a hash with key value pairs:

``` ruby
Logman.info("Hello World", :from => "renderedtext", :to => "The World")

# Output:
# {"level":"INFO","time":"2017-12-12 09:33:21 +0000","pid":10950,"message":"Hello World","from":"renderedtext","to":"The World"}
```

Every log event has a severity. In the previous examples we have used `info`. To
log an `error` use the following snippet:

``` ruby
Logman.error("Team does not exists", :owner => "renderedtext", :team_name => "z-fightes")

# Output:
# {"level":"ERROR","time":"2017-12-12 09:33:47 +0000","pid":10950,"message":"Team does not exists","owner":"renderedtext","team_name":"z-fightes"}
```

Logman supports multiple severity levels:

``` ruby
Logman.fatal("Hello")
Logman.error("Hello")
Logman.warn("Hello")
Logman.info("Hello")
Logman.debug("Hello")
```

Where the following hierarchy stands:

``` txt
FATAL > ERROR > WARN > INFO > DEBUG
```

## Instantiated Loggers

Logs in a class or system component usually share common metadata fields. For
this purpose, a new instance of Logman can be created and pre-populated with
metadata.

In the following example, we will add logs to a video processor:

``` ruby
class VideoProcessor

  def initialize(video)
    @logger = Logman.new

    # these fields will appear in every log event
    @logger.add(:compoent => "video_processor")
    @logger.add(:id => @video.id)
    @logger.add(:title => "Keyboard Cat")
  end

  def process
    @logger.info("started")

    content = load_from_disk(@video.location)
    @logger.info("loaded into memory", :size => content.length)

    compressed_content = compress(@video)
    @logger.info("compressed", :size => compressed_content.length)

    s3_path = upload_to_s3(@video)
    @logger.info("uploaded to S3", :s3_path => s3_path

    @video.update(:s3_path => s3_path)

    @logger.info("finished")
  rescue => exception
    @logger.error("failed", :exception => exception.message)

    raise
  end

end
```

In case of a successful processing of a video, we would see the following:

``` txt
{"level":"INFO","time":"2017-12-12 09:35:19 +0000","pid":10950,"message":"started","compoent":"video_processor","id":9312,"title":"Keyboard Cat"}
{"level":"INFO","time":"2017-12-12 09:35:34 +0000","pid":10950,"message":"loaded into memory","compoent":"video_processor","id":9312,"title":"Keyboard Cat","size":41241241}
{"level":"INFO","time":"2017-12-12 09:35:44 +0000","pid":10950,"message":"compressed","compoent":"video_processor","id":9312,"title":"Keyboard Cat","size":1312312}
{"level":"INFO","time":"2017-12-12 09:36:08 +0000","pid":10950,"message":"uploaded to S3","compoent":"video_processor","id":9312,"title":"Keyboard Cat","s3_path":"s3://hehe/a.mpeg"}
{"level":"INFO","time":"2017-12-12 09:36:27 +0000","pid":10950,"message":"finished","compoent":"video_processor","id":9312,"title":"Keyboard Cat"}
```

In case of an error, we would see the following:

``` txt
{"level":"INFO","time":"2017-12-12 09:35:19 +0000","pid":10950,"message":"started","compoent":"video_processor","id":9312,"title":"Keyboard Cat"}
{"level":"ERROR","time":"2017-12-12 09:35:34 +0000","pid":10950,"message":"failed","compoent":"video_processor","id":9312,"title":"Keyboard Cat","size":41241241,"exception": "Out of memory"}
```

Logman can receive a [Ruby Logger](http://ruby-doc.org/stdlib-2.2.0/libdoc/logger/rdoc/Logger.html)
instance to handle output. This is useful if you want to log to a file.

``` ruby
@logger = Logman.new(:logger => Logger.new("/tmp/out.txt"))

@logger.info("Hello World")

# => output goes to /tmp/out.txt
```

You can also pass an instance of Rails logger:

``` ruby
@logger = Logman.new(:logger => Rails.logger)

@logger.info("Hello World")
```

Or, you can pass an instance of another Logman. This is useful if you want to
create a new Logman instance with the same fields as the previous instance:

``` ruby
@api_logger = Logman.new
@api_logger.add(:version => "v2")

@team_api_logger = Logman.new(:logger => @api_logger)
# team logger copied the `version` field

@team_api_logger.info("Hello")

# {"level":"INFO","time":"2017-12-12 09:39:07 +0000","pid":10950,"message":"Hello","version":"v2"}
```

With Logman, you can instrument data processing with a logger block. For
example, if you want to log the steps in a user sign-up progress:

``` ruby
Logman.process("user-registration", :username => "shiroyasha") do |logger|
  user = User.create(params)
  logger.info("User Record Created")

  SigupEmail.send(user)
  logger.info("Sent signup email")

  team.add(user)
  logger.info("Added user to a team", :team_id => team.id)
end
```

The above will log the following information:

``` txt
{"level":"INFO","time":"2017-12-12 09:40:39 +0000","pid":10950,"message":"user-registration-started","username":"shiroyasha"}
{"level":"INFO","time":"2017-12-12 09:40:39 +0000","pid":10950,"message":"User Record Created","username":"shiroyasha"}
{"level":"INFO","time":"2017-12-12 09:40:39 +0000","pid":10950,"message":"Sent signup email","username":"shiroyasha"}
{"level":"INFO","time":"2017-12-12 09:40:39 +0000","pid":10950,"message":"Added user to a team","username":"shiroyasha","team_id":21}
{"level":"INFO","time":"2017-12-12 09:40:39 +0000","pid":10950,"message":"user-registration-finished","username":"shiroyasha"}
```

In case of an exception, the error will be logged and re-thrown:

``` ruby
Logman.process("user-registration", :username => "shiroyasha") do |logger|
  user = User.create(params)
  logger.info("User Record Created")

  SigupEmail.send(user)
  logger.info("Sent signup email")

  raise "Exception"

  team.add(user)
  logger.info("Added user to a team", :team_id => team)
end
```

``` ruby
{"level":"INFO","time":"2017-12-12 09:41:27 +0000","pid":10950,"message":"user-registration-started","username":"shiroyasha"}
{"level":"INFO","time":"2017-12-12 09:41:27 +0000","pid":10950,"message":"User Record Created","username":"shiroyasha"}
{"level":"INFO","time":"2017-12-12 09:41:27 +0000","pid":10950,"message":"Sent signup email","username":"shiroyasha"}
{"level":"ERROR","time":"2017-12-12 09:41:27 +0000","pid":10950,"message":"Exception","username":"shiroyasha","type":"RuntimeError"}
```

## Development

After checking out the repo:

- run `bundle install` to install dependencies
- run `bundle exec rspec` to run unit specs
- run `bundle exec rubocop` to check code style
- run `bundle exec reek` to check code smells

To release a new version:

- bump the version in `lib/logman/version.rb`
- run `bundle exec rake release` to release a new version on RubyGems

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/renderedtext/logman. This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Logman project’s codebases, issue trackers, chat
rooms and mailing lists is expected to follow the
[code of conduct](https://github.com/renderedtext/logman/blob/master/CODE_OF_CONDUCT.md).
