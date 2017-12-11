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

  describe ".fatal" do
    it "displays a fatal message to STDOUT" do
      msg = "level='F' time='2017-12-11 09:47:27 +0000' pid='1234' event='Hello World' from='shiroyasha'\n"

      expect { Logman.fatal("Hello World", :from => "shiroyasha") }.to output(msg).to_stdout_from_any_process
    end
  end

  describe ".error" do
    it "displays an error message to STDOUT" do
      msg = "level='E' time='2017-12-11 09:47:27 +0000' pid='1234' event='Hello World' from='shiroyasha'\n"

      expect { Logman.error("Hello World", :from => "shiroyasha") }.to output(msg).to_stdout_from_any_process
    end
  end

  describe ".warn" do
    it "displays an warning message to STDOUT" do
      msg = "level='W' time='2017-12-11 09:47:27 +0000' pid='1234' event='Hello World' from='shiroyasha'\n"

      expect { Logman.warn("Hello World", :from => "shiroyasha") }.to output(msg).to_stdout_from_any_process
    end
  end

  describe ".info" do
    it "displays an info message to STDOUT" do
      msg = "level='I' time='2017-12-11 09:47:27 +0000' pid='1234' event='Hello World' from='shiroyasha'\n"

      expect { Logman.info("Hello World", :from => "shiroyasha") }.to output(msg).to_stdout_from_any_process
    end
  end

  describe ".debug" do
    it "displays a debug message to STDOUT" do
      msg = "level='D' time='2017-12-11 09:47:27 +0000' pid='1234' event='Hello World' from='shiroyasha'\n"

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
        msg = "level='I' time='2017-12-11 09:47:27 +0000' pid='1234' event='Hello World' from='Bender' to='Fry' what='present'\n"

        expect { @logger.info("Hello World", :what => "present") }.to output(msg).to_stdout_from_any_process
      end
    end

    describe "#error" do
      it "displays an info message" do
        msg = "level='E' time='2017-12-11 09:47:27 +0000' pid='1234' event='Hello World' from='Bender' to='Fry' what='present'\n"

        expect { @logger.error("Hello World", :what => "present") }.to output(msg).to_stdout_from_any_process
      end
    end

    describe "#debug" do
      it "displays a debug message" do
        msg = "level='D' time='2017-12-11 09:47:27 +0000' pid='1234' event='Hello World' from='Bender' to='Fry' what='present'\n"

        expect { @logger.debug("Hello World", :what => "present") }.to output(msg).to_stdout_from_any_process
      end
    end

    describe "#fatal" do
      it "displays a fatal message" do
        msg = "level='F' time='2017-12-11 09:47:27 +0000' pid='1234' event='Hello World' from='Bender' to='Fry' what='present'\n"

        expect { @logger.fatal("Hello World", :what => "present") }.to output(msg).to_stdout_from_any_process
      end
    end

    describe "#warn" do
      it "displays a warn message" do
        msg = "level='W' time='2017-12-11 09:47:27 +0000' pid='1234' event='Hello World' from='Bender' to='Fry' what='present'\n"

        expect { @logger.warn("Hello World", :what => "present") }.to output(msg).to_stdout_from_any_process
      end
    end

    describe "#clear" do
      it "removes fields from the logger instance" do
        @logger.clear!

        msg = "level='I' time='2017-12-11 09:47:27 +0000' pid='1234' event='Hello World' what='present'\n"

        expect { @logger.info("Hello World", :what => "present") }.to output(msg).to_stdout_from_any_process
      end
    end

    # rubocop:disable RSpec/NestedGroups
    describe "passing logger via the constructor" do
      context "when the passed logger is an instance of Logman" do
        it "copies the fields from the other instance" do
          new_logger = Logman.new(:logger => @logger)

          msg = "level='I' time='2017-12-11 09:47:27 +0000' pid='1234' event='Hello World' from='Bender' to='Fry' what='present'\n"

          expect { new_logger.info("Hello World", :what => "present") }.to output(msg).to_stdout_from_any_process
        end
      end

      context "when the passed logger is not an instance of Logman" do
        it "uses the logger to print to file" do
          filename = "/tmp/#{SecureRandom.uuid}.txt"
          logger = ::Logger.new(filename)

          new_logger = Logman.new(:logger => logger)

          msg = "level='I' time='2017-12-11 09:47:27 +0000' pid='1234' event='Hello World' what='present'\n"

          expect { new_logger.info("Hello World", :what => "present") }.to_not output.to_stdout_from_any_process

          expect(File).to be_exists(filename)
          expect(File.read(filename)).to include(msg)
        end
      end
    end
  end
end
