require "logman/version"
require "logger"

module Logman
  DEFAULT_LOGGER = Logger.new(STDOUT)
  DEFAULT_LOGGER.formatter = proc do |severity, datetime, _progname, msg|
    event = {
      :level => severity[0].upcase,
      :time => datetime,
      :pid => Process.pid
    }.merge(msg)

    "#{Logman.format(event)}\n"
  end

  def self.fatal(message, metadata = {})
    DEFAULT_LOGGER.fatal({ :event => message }.merge(metadata))
  end

  def self.error(message, metadata = {})
    DEFAULT_LOGGER.error({ :event => message }.merge(metadata))
  end

  def self.warn(message, metadata = {})
    DEFAULT_LOGGER.warn({ :event => message }.merge(metadata))
  end

  def self.info(message, metadata = {})
    DEFAULT_LOGGER.info({ :event => message }.merge(metadata))
  end

  def self.debug(message, metadata = {})
    DEFAULT_LOGGER.debug({ :event => message }.merge(metadata))
  end

  def self.format(event_hash)
    event_hash.map { |key, value| "#{key}='#{value}'" }.join(" ")
  end
end
