# :reek:PrimaDonnaMethod { exclude: [clear! ] }
module Logman
  class Logger

    SEVERITY_LEVELS = %i(fatal error warn info debug).freeze

    attr_reader :fields
    attr_reader :ruby_logger

    def initialize(options = {})
      if options[:logger].instance_of?(Logman::Logger)
        # copy constructor

        @fields = options[:logger].fields.dup
        @ruby_logger = options[:logger].ruby_logger
      else
        @fields = {}
        @ruby_logger = options[:logger] || ::Logger.new(STDOUT)
      end

      @ruby_logger.formatter = formatter
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
      @ruby_logger.public_send(level, { :event => message }.merge(@fields).merge(metadata))
    end

    def formatter
      Proc.new do |severity, datetime, _progname, msg|
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
end
