#!/usr/bin/env ruby

require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))),
                  'external/dist/share/service_testing/bp_service_runner.rb')
require 'uri'
require 'test/unit'
require 'open-uri'
require 'rbconfig'
include Config
require 'webrick'
include WEBrick

class TestJSONRequest < Test::Unit::TestCase
  def setup
    subdir = 'build/JSONRequest'
    if ENV.key?('BP_OUTPUT_DIR')
      subdir = ENV['BP_OUTPUT_DIR']
    end
    @cwd = File.dirname(File.expand_path(__FILE__))
    @service = File.join(@cwd, "../#{subdir}")
    @providerDir = File.expand_path(File.join(@cwd, "providerDir"))
    nulldevice = "/dev/null"
    if CONFIG['arch'] =~ /mswin|mingw/
      nulldevice = "NUL"
    end
    @server = HTTPServer.new(:Port => 0,
                             :Logger => WEBrick::Log.new(nulldevice),
                             :AccessLog => [nil],
                             :BindAddress => "127.0.0.1")
    @urlLocal = "http://localhost:#{@server[:Port]}/"
  end
  
  def teardown
  end

  def private_setup(s)
    @i = s.allocate(@urlLocal)
    # Testcase 1.
    f = "./cases/case1.rb"
    require f

    @temp = f
    @temp[".rb"] = ".json"
    @json = JSON.parse(File.read(@temp))

    if @json["url"] == ""
      @url = @urlLocal
    else
      @url = json["url"]
    end

    # Need to test send object ALSO.
    @path1 = File.join(@cwd, "test_files", @json["send"])

    @server.mount("/", SH)
    t = Thread.new() { @server.start }

    @wantfile = @temp
    @wantfile[".json"] = ""
    @wantjson = JSON.parse(File.read(File.join(@wantfile, "doGET.json")))
  end

  def test_load_service
    BrowserPlus.run(@service, @providerDir) { |s|
    }
  end

  # Require whatever server you want to, mount it,
  # and then verify that it has the same keys and
  # values as in your doGET.json and doPOST.json.
  def test_serverSH_1
    BrowserPlus::Service.new(@service, @providerDir) { |s|
      private_setup(s)
      r = @i.get({ "url" => @url })
      want = @wantjson['graham']
      got = r['graham']
      assert_equal(want, got)
      want = @wantjson['nutella']
      got = r['nutella']
      assert_equal(want, got)
      s.shutdown()
    }
  end

  def test_serverSH_2
    BrowserPlus::Service.new(@service, @providerDir) { |s|
      private_setup(s)
      r = @i.get({ "url" => @url, 'timeout' => @json["timeout"] })
      want = @wantjson['graham']
      got = r['graham']
      assert_equal(want, got)
      want = @wantjson['nutella']
      got = r['nutella']
      assert_equal(want, got)
      s.shutdown()
    }
  end

  def test_serverSH_3
    BrowserPlus::Service.new(@service, @providerDir) { |s|
      private_setup(s)
      r = @i.post({ "url" => @url, 'send' => @path1 })
      want = JSON.parse(File.read(File.join(@wantfile, "doPOST.json")))['post']
      got = r['post']
      assert_equal(want, got)
      s.shutdown()
    }
  end

  def test_serverSH_4
    BrowserPlus::Service.new(@service, @providerDir) { |s|
      private_setup(s)
      r = @i.post({ "url" => @url, 'send' => @path1, 'timeout' => @json["timeout"] })
      want = JSON.parse(File.read(File.join(@wantfile, "doPOST.json")))['post']
      got = r['post']
      assert_equal(want, got)
      s.shutdown()
    }
  end

  def test_serverSH_5
    BrowserPlus::Service.new(@service, @providerDir) { |s|
      private_setup(s)
      # Negative test cases.
      @server.mount("/", OnlyPOST)
      assert_raise(RuntimError) { r = @i.get({ "url" => @url }) }
      s.shutdown()
    }
  end

  def test_serverSH_6
    BrowserPlus::Service.new(@service, @providerDir) { |s|
      private_setup(s)
      # Negative test cases.
      @server.mount("/", OnlyGET)
      assert_raise(RuntimeError) { r = @i.post({ "url" => @url }) }
      s.shutdown()
    }
  end
end
