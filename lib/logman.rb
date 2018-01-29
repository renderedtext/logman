require "logman/version"
require "logger"
require "json"

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
      define_method(severity) do |event, *args|
        default_logger.public_send(severity, event, args.first || {})
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
    define_method(severity) do |event, *args|
      log(severity, event, args.first || {})
    end
  end

  def process(name, metadata = {})
    logger = Logman.new(:logger => self)
    logger.add(metadata)

    logger.info("#{name}-started")

    result = yield(logger)

    logger.info("#{name}-finished")

    result
  rescue StandardError => exception
    logger.error("#{name}-failed", :type => exception.class.name, :exception_message => exception.message)
    raise
  end

  private

  def log(level, event, metadata = {})
    @logger.public_send(level, { :event => event }.merge(@fields).merge(metadata))
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
    event_hash.map { |k, v| "#{k}: #{v}" }.join(", ")
  end
end
