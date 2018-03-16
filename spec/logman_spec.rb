require "spec_helper"
require "securerandom"

# rubocop:disable Metrics/LineLength
RSpec.describe Logman do
  around do |example|
    # make it easy to test time values in output
    Timecop.freeze(2017, 12, 11, 9, 47, 27) do
      example.run
    end
  end

  before do
    allow(Process).to receive(:pid).and_return(1234)
  end

  it "has a version number" do
    expect(Logman::VERSION).not_to be nil
  end

  it "behaves like standard ruby logger" do
    logger = Logger.new(STDOUT)
    Logman.new(:logger => logger)

    expect { logger.info("This is string log message") }.to output(/This is string log message/).to_stdout_from_any_process
  end

  describe ".process" do
    describe "when the exception occurs withing the passed block" do
      # rubocop:disable Lint/UnreachableCode
      def test_process
        Logman.process("user-registration", :username => "shiroyasha") do |logger|
          logger.info("User Record Created")

          logger.info("Sent signup email")

          raise "Exception"

          logger.info("Added user to a team", :team_id => 312)
        end
      end

      def silent_exceptions
        yield
      rescue StandardError
        nil
      end

      it "logs the lifecycle of a process" do
        message = [
          "INFO [09:47:27.000 #1234] -- user-registration-started -- username: 'shiroyasha'",
          "INFO [09:47:27.000 #1234] -- User Record Created -- username: 'shiroyasha'",
          "INFO [09:47:27.000 #1234] -- Sent signup email -- username: 'shiroyasha'",
          "ERROR [09:47:27.000 #1234] -- user-registration-failed -- username: 'shiroyasha', type: 'RuntimeError', msg: 'Exception'",
          ""
        ].join("\n")

        expect { silent_exceptions { test_process } }.to output(message).to_stdout_from_any_process
      end

      it "re-raises the exception" do
        expect { test_process }.to raise_exception(StandardError)
      end
    end

    describe "when the block is run without exceptions" do
      before do
        @block = proc do |logger|
          logger.info("User Record Created")

          logger.info("Sent signup email")

          logger.info("Added user to a team", :team_id => 312)

          :success
        end
      end

      it "logs the lifecycle of a process" do
        expect { Logman.process("user-registration", :username => "shiroyasha", &@block) }.to output(
          [
            "INFO [09:47:27.000 #1234] -- user-registration-started -- username: 'shiroyasha'",
            "INFO [09:47:27.000 #1234] -- User Record Created -- username: 'shiroyasha'",
            "INFO [09:47:27.000 #1234] -- Sent signup email -- username: 'shiroyasha'",
            "INFO [09:47:27.000 #1234] -- Added user to a team -- username: 'shiroyasha', team_id: '312'",
            "INFO [09:47:27.000 #1234] -- user-registration-finished -- username: 'shiroyasha'",
            ""
          ].join("\n")
        ).to_stdout_from_any_process
      end

      it "returns the block result" do
        expect(Logman.process("user-registration", &@block)).to eq(@block.call(Logman.new))
      end
    end
  end

  describe ".fatal" do
    it "displays a fatal message to STDOUT" do
      msg = [
        "FATAL [09:47:27.000 #1234] -- Hello World -- from: 'shiroyasha'",
        ""
      ].join("\n")

      expect { Logman.fatal("Hello World", :from => "shiroyasha") }.to output(msg).to_stdout_from_any_process
    end
  end

  describe ".error" do
    it "displays an error message to STDOUT" do
      msg = [
        "ERROR [09:47:27.000 #1234] -- Hello World -- from: 'shiroyasha'",
        ""
      ].join("\n")

      expect { Logman.error("Hello World", :from => "shiroyasha") }.to output(msg).to_stdout_from_any_process
    end
  end

  describe ".warn" do
    it "displays an warning message to STDOUT" do
      msg = [
        "WARN [09:47:27.000 #1234] -- Hello World -- from: 'shiroyasha'",
        ""
      ].join("\n")

      expect { Logman.warn("Hello World", :from => "shiroyasha") }.to output(msg).to_stdout_from_any_process
    end
  end

  describe ".info" do
    it "displays an info message to STDOUT" do
      msg = [
        "INFO [09:47:27.000 #1234] -- Hello World -- from: 'shiroyasha'",
        ""
      ].join("\n")

      expect { Logman.info("Hello World", :from => "shiroyasha") }.to output(msg).to_stdout_from_any_process
    end
  end

  describe ".debug" do
    it "displays a debug message to STDOUT" do
      msg = [
        "DEBUG [09:47:27.000 #1234] -- Hello World -- from: 'shiroyasha'",
        ""
      ].join("\n")

      expect { Logman.debug("Hello World", :from => "shiroyasha") }.to output(msg).to_stdout_from_any_process
    end
  end

  describe "Logman instance" do
    before do
      @logger = Logman.new

      @logger.add(:from => "Bender")
      @logger.add(:to => "Fry")
    end

    describe "#info" do
      it "displays an info message" do
        msg = [
          "INFO [09:47:27.000 #1234] -- Hello World -- from: 'Bender', to: 'Fry', what: 'present'",
          ""
        ].join("\n")

        expect { @logger.info("Hello World", :what => "present") }.to output(msg).to_stdout_from_any_process
      end
    end

    describe "#error" do
      it "displays an info message" do
        msg = [
          "ERROR [09:47:27.000 #1234] -- Hello World -- from: 'Bender', to: 'Fry', what: 'present'",
          ""
        ].join("\n")

        expect { @logger.error("Hello World", :what => "present") }.to output(msg).to_stdout_from_any_process
      end
    end

    describe "#debug" do
      it "displays a debug message" do
        msg = [
          "DEBUG [09:47:27.000 #1234] -- Hello World -- from: 'Bender', to: 'Fry', what: 'present'",
          ""
        ].join("\n")

        expect { @logger.debug("Hello World", :what => "present") }.to output(msg).to_stdout_from_any_process
      end
    end

    describe "#fatal" do
      it "displays a fatal message" do
        msg = [
          "FATAL [09:47:27.000 #1234] -- Hello World -- from: 'Bender', to: 'Fry', what: 'present'",
          ""
        ].join("\n")

        expect { @logger.fatal("Hello World", :what => "present") }.to output(msg).to_stdout_from_any_process
      end
    end

    describe "#warn" do
      it "displays a warn message" do
        msg = [
          "WARN [09:47:27.000 #1234] -- Hello World -- from: 'Bender', to: 'Fry', what: 'present'",
          ""
        ].join("\n")

        expect { @logger.warn("Hello World", :what => "present") }.to output(msg).to_stdout_from_any_process
      end
    end

    describe "#clear" do
      it "removes fields from the logger instance" do
        @logger.clear!

        msg = [
          "INFO [09:47:27.000 #1234] -- Hello World -- what: 'present'",
          ""
        ].join("\n")

        expect { @logger.info("Hello World", :what => "present") }.to output(msg).to_stdout_from_any_process
      end
    end

    # rubocop:disable RSpec/NestedGroups
    describe "passing logger via the constructor" do
      context "when the passed logger is an instance of Logman" do
        it "copies the fields from the other instance" do
          new_logger = Logman.new(:logger => @logger)

          msg = [
            "INFO [09:47:27.000 #1234] -- Hello World -- from: 'Bender', to: 'Fry', what: 'present'",
            ""
          ].join("\n")

          expect { new_logger.info("Hello World", :what => "present") }.to output(msg).to_stdout_from_any_process
        end
      end

      context "when the passed logger is not an instance of Logman" do
        it "uses the logger to print to file" do
          filename = "/tmp/#{SecureRandom.uuid}.txt"
          logger = ::Logger.new(filename)

          new_logger = Logman.new(:logger => logger)

          msg = [
            "INFO [09:47:27.000 #1234] -- Hello World -- what: 'present'",
            ""
          ].join("\n")

          expect { new_logger.info("Hello World", :what => "present") }.to_not output.to_stdout_from_any_process

          expect(File).to be_exists(filename)
          expect(File.read(filename)).to include(msg)
        end
      end
    end
  end
end
