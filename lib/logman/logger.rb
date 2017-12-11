# :reek:PrimaDonnaMethod { exclude: [clear! ] }
module Logman
  class Logger

    SEVERITY_LEVELS = %i(fatal error warn info debug).freeze

    attr_reader :fields

    def initialize(options = {})
      @ruby_logger = options[:logger] || ::Logger.new(STDOUT)

      @fields = {}

      # if we got a copy of another Logman logger we can copy the fields
      @fields = @ruby_logger.fields.dup if @ruby_logger.instance_of?(Logman::Logger)

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
