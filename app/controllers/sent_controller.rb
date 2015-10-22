require 'sentimentalizer'

class Analyzer
  def initialize
    @@setup ||= false
    if !@@setup
      Sentimentalizer.setup
      @@setup = true
    end
  end

  def process(phrase)
    begin
      Sentimentalizer.analyze phrase
    rescue
      nil
    end
  end
end

class SentController < ApplicationController
  def check # display the form
  end

  def sent # handle the POST, display the result
    # do stuff
    analyzer = Analyzer.new
    tweet = params["tweet"]
    puts "TWEET: " + tweet
    @result = analyzer.process(tweet)
    render 'check'
  end

  private
    def sent_params
      params.require(:tweet)
    end
end
