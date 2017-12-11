# :reek:PrimaDonnaMethod { exclude: [clear! ] }
module Logman
  class Logger

    SEVERITY_LEVELS = %i(fatal error warn info debug).freeze

    def initialize
      @ruby_logger = ::Logger.new(STDOUT)

      @ruby_logger.formatter = proc do |severity, datetime, _progname, msg|
        event = {
          :level => severity[0].upcase,
          :time => datetime,
          :pid => Process.pid
        }.merge(msg)

        "#{format(event)}\n"
      end

      @fields = {}
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

    def format(event_hash)
      event_hash.map { |key, value| "#{key}='#{value}'" }.join(" ")
    end
  end
end
