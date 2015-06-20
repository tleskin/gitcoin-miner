require 'hurley'
require "digest"
require "securerandom"

class Coin

  def initialize
    @client = Hurley::Client.new "https://git-coin.herokuapp.com"
  end

  def iteration
    @iteration ||= 1
  end

  def target
    @target || @client.get("/target").body.hex
  end

  def mine
    if iteration > 1_000_000
      puts "completed 1mil hashes; refreshing target"
      @target = nil
      @iteration = 1
    end
    input = SecureRandom.hex
    if Digest::SHA1.hexdigest(input).hex < target
      resp = @client.post("/hash", {:owner => "Tom", :message => input})
      puts "got a coin #{input}, resp: #{resp.body}"
      @target = nil
    elsif
      puts "#{Digest::SHA1.hexdigest(input).hex} is not a match."
    end
    @iteration = @iteration + 1
  end
end

def run
  (1..10).to_a.map do |i|
    Thread.new do
      miner = Coin.new
      while true do
        miner.mine
      end
    end
  end.map(&:join)
end

run
