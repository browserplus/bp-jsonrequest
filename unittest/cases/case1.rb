#!/usr/bin/env ruby
require 'webrick'
include WEBrick

class SH < HTTPServlet::AbstractServlet
  def do_GET(req, res)
    cur = File.expand_path(__FILE__)
    cur[".rb"] = ""
    cur = File.join(cur, "doGET.json")
    res.body = File.read(cur)
  end 

  def do_POST(req, res)
    cur = File.expand_path(__FILE__)
    cur[".rb"] = ""
    cur = File.join(cur, "doPOST.json")
    res.body = File.read(cur)
  end
end

class OnlyGET < HTTPServlet::AbstractServlet
  def do_GET(req, res)
    cur = File.expand_path(__FILE__)
    cur[".rb"] = ""
    cur = File.join(cur, "doGET.json")
    res.body = File.read(cur)
  end 
end

class OnlyPOST < HTTPServlet::AbstractServlet
  def do_POST(req, res)
    cur = File.expand_path(__FILE__)
    cur[".rb"] = ""
    cur = File.join(cur, "doPOST.json")
    res.body = File.read(cur)
  end
end
