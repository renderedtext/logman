RSpec.describe Logman do
  it "has a version number" do
    expect(Logman::VERSION).not_to be nil
  end

  describe ".fatal" do
    it "displays a fatal message to STDOUT" do
      msg = "level='F' time='2017-12-11 09:47:27 +0000' event='Hello World'"

      expect { Logman.fatal("Hello World") }.to output(msg).to_stdout_from_any_process
    end
  end

  describe ".error" do
    it "displays an error message to STDOUT" do
      msg = "level='E' time='2017-12-11 09:47:27 +0000' event='Hello World'"

      expect { Logman.fatal("Hello World") }.to output(msg).to_stdout_from_any_process
    end
  end

  describe ".warn" do
    it "displays an warning message to STDOUT" do
      msg = "level='W' time='2017-12-11 09:47:27 +0000' event='Hello World'"

      expect { Logman.fatal("Hello World") }.to output(msg).to_stdout_from_any_process
    end
  end

  describe ".info" do
    it "displays an info message to STDOUT" do
      msg = "level='I' time='2017-12-11 09:47:27 +0000' event='Hello World'"

      expect { Logman.fatal("Hello World") }.to output(msg).to_stdout_from_any_process
    end
  end

  describe ".debug" do
    it "displays a debug message to STDOUT" do
      msg = "level='D' time='2017-12-11 09:47:27 +0000' event='Hello World'"

      expect { Logman.fatal("Hello World") }.to output(msg).to_stdout_from_any_process
    end
  end
end
