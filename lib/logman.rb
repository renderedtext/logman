require "logman/version"
require "logger"

# :reek:PrimaDonnaMethod { exclude: [clear! ] }
# :reek:TooManyStatements{ exclude: [process ] }
class Logman
  SEVERITY_LEVELS = %i(fatal error warn info debug).freeze

  class << self
    def default_logger
      @default_logger ||= Logman.new
    end

    def process(name, metadata = {}, &block)
      default_logger.process(name, metadata, &block)
    end

    SEVERITY_LEVELS.each do |severity|
      define_method(severity) do |message, *args|
        default_logger.public_send(severity, message, args.first || {})
      end
    end
  end

  attr_reader :fields
  attr_reader :logger

  def initialize(options = {})
    @logger = options[:logger] || ::Logger.new(STDOUT)

    if @logger.instance_of?(Logman)
      # copy constructor

      @fields = @logger.fields.dup
      @logger = @logger.logger
    else
      @fields = {}
    end

    @logger.formatter = formatter
  end

  def add(metadata = {})
    @fields.merge!(metadata)
  end

  def clear!
    @fields = {}
  end

  SEVERITY_LEVELS.each do |severity|
    define_method(severity) do |message, *args|
      log(severity, message, args.first || {})
    end
  end

  def process(name, metadata = {})
    logger = Logman.new(:logger => self)
    logger.add(metadata)

    logger.info("#{name}-started")

    yield(logger)

    logger.info("#{name}-finished")
  rescue StandardError => exception
    logger.error("#{name}-failed", :type => exception.class.name, :message => exception.message)
    raise
  end

  private

  def log(level, message, metadata = {})
    @logger.public_send(level, { :message => message }.merge(@fields).merge(metadata))
  end

  def formatter
    proc do |severity, datetime, _progname, msg|
      event = {
        :level => severity.upcase,
        :time => datetime,
        :pid => Process.pid
      }.merge(msg)

      "#{format(event)}\n"
    end
  end

  def format(event_hash)
    event_hash.to_json
  end
end
