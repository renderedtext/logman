require "logman/version"
require "logger"

# :reek:PrimaDonnaMethod { exclude: [clear! ] }
class Logman
  SEVERITY_LEVELS = %i(fatal error warn info debug).freeze

  class << self
    def default_logger
      @default_logger ||= Logman.new
    end

    SEVERITY_LEVELS.each do |severity|
      define_method(severity) { |message, metadata| default_logger.public_send(severity, message, metadata) }
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
    define_method(severity) { |message, metadata| log(severity, message, metadata) }
  end

  private

  def log(level, message, metadata = {})
    @logger.public_send(level, { :event => message }.merge(@fields).merge(metadata))
  end

  def formatter
    proc do |severity, datetime, _progname, msg|
      event = {
        :level => severity[0].upcase,
        :time => datetime,
        :pid => Process.pid
      }.merge(msg)

      "#{format(event)}\n"
    end
  end

  def format(event_hash)
    event_hash.map { |key, value| "#{key}='#{value}'" }.join(" ")
  end
end
