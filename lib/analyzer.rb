require 'sentimentalizer'

# Setup the sentimentalizer library control access to it
class Analyzer
  # Initialize the library ONLY once to speed up response time
  def initialize
    @@setup ||= false # rubocop:disable Style/ClassVars
    return if @@setup
    Sentimentalizer.setup
    @@setup = true # rubocop:disable Style/ClassVars
  end

  # Analyze the given phrase, and return the resulting ClassificationResult
  # object.
  #
  # ==== Attributes
  #
  # * +phrase+ -  The string to analyze
  def process(phrase)
    Sentimentalizer.analyze phrase
  rescue
    nil
  end
end
