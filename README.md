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
# level='I' time='2017-12-11 09:47:27 +0000' pid='1234' event='Hello World'
```

Every log event can be extended with metadata — a hash with key value pairs:

``` ruby
Logman.info("Hello World", :from => "renderedtext", :to => "The World")

# Output:
# level='I' time='2017-12-11 09:47:27 +0000' pid='1234' event='Hello World' from='renderedtext' to='The World'
```

Every log event has a severity. In the previous examples we have used `info`. To
log an `error` use the following snippet:

``` ruby
Logman.error("Team does not exists", :owner => "renderedtext", :team_name => "z-fightes")

# Output:
# level='E' time='2017-12-11 09:47:27 +0000' pid='1234' event='Team does not exists' owner='renderedtext' team_name='z-fighters'
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
this purpose, an new instance of Logman can be created and pre-populated with
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
    @logger.error("failed", :message => exception.message)

    raise
  end

end
```

In case of a successful processing of a video, we would see the following:

``` txt
level='I' time='2017-12-11 09:47:27 +0000' pid='1234' event='started' id='31312' title='Keyboard Cat' component='video_processor'
level='I' time='2017-12-11 09:47:27 +0000' pid='1234' event='loaded into memory' component='video_processor' id='31312' title='Keyboard Cat' size='3123131312'
level='I' time='2017-12-11 09:47:27 +0000' pid='1234' event='compressed' component='video_processor' id='31312' title='Keyboard Cat' size='12312312'
level='I' time='2017-12-11 09:47:27 +0000' pid='1234' event='upload_to_s3' component='video_processor' id='31312' title='Keyboard Cat' s3_path='s3://random'
level='I' time='2017-12-11 09:47:27 +0000' pid='1234' event='finished' component='video_processor' id='31312' title='Keyboard Cat'
```

In case of an error, we would see the following:

``` txt
level='I' time='2017-12-11 09:47:27 +0000' pid='1234' event='started' id='31312' title='Keyboard Cat' component='video_processor'
level='E' time='2017-12-11 09:47:27 +0000' pid='1234' event='failed' component='video_processor' id='31312' title='Keyboard Cat' message='Out of memory'
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

# level='I' time='2017-12-11 09:47:27 +0000' pid='1234' event='Hello' version='v2'
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
  logger.info("Added user to a team", :team_id => team)
end
```

The above will log the following information:

``` txt
level='I' time='2017-12-11 09:47:27 +0000' pid='1234' event='user-registration-started' username='shiroyasha'
level='I' time='2017-12-11 09:47:27 +0000' pid='1234' event='User Record Created' username='shiroyasha'
level='I' time='2017-12-11 09:47:27 +0000' pid='1234' event='Sent signup email' username='shiroyasha'
level='I' time='2017-12-11 09:47:27 +0000' pid='1234' event='Added user to a team' username='shiroyasha' team_id='312'
level='I' time='2017-12-11 09:47:27 +0000' pid='1234' event='user-registration-finished' username='shiroyasha'
```

In case of an exception, the error will be logger and re-thrown:

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
level='I' time='2017-12-11 09:47:27 +0000' pid='1234' event='user-registration-started' username='shiroyasha'
level='I' time='2017-12-11 09:47:27 +0000' pid='1234' event='User Record Created' username='shiroyasha'
level='I' time='2017-12-11 09:47:27 +0000' pid='1234' event='Sent signup email' username='shiroyasha'
level='E' time='2017-12-11 09:47:27 +0000' pid='1234' event='user-registration-failed' username='shiroyasha' type='RuntimeError' message='Exception'
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
