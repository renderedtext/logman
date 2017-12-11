module Logman
  class Logger

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

    def fatal(message, metadata = {})
      log(:fatal, message, metadata)
    end

    def error(message, metadata = {})
      log(:error, message, metadata)
    end

    def warn(message, metadata = {})
      log(:warn, message, metadata)
    end

    def info(message, metadata = {})
      log(:info, message, metadata)
    end

    def debug(message, metadata = {})
      log(:debug, message, metadata)
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
