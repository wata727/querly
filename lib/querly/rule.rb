module Querly
  class Rule
    attr_reader :id
    attr_reader :patterns
    attr_reader :messages

    attr_reader :sources
    attr_reader :justifications
    attr_reader :before_examples
    attr_reader :after_examples
    attr_reader :tags

    def initialize(id:, messages:, patterns:, sources:, tags:, before_examples:, after_examples:, justifications:)
      @id = id
      @patterns = patterns
      @sources = sources
      @messages = messages
      @justifications = justifications
      @before_examples = before_examples
      @after_examples = after_examples
      @tags = tags
    end

    def match?(identifier: nil, tags: nil)
      if identifier
        unless id == identifier || id.start_with?(identifier + ".")
          return false
        end
      end

      if tags
        unless tags.subset?(self.tags)
          return false
        end
      end

      true
    end

    class InvalidRuleHashError < StandardError; end
    class PatternSyntaxError < StandardError; end

    def self.load(hash)
      id = hash["id"]
      raise InvalidRuleHashError, "id is missing" unless id

      srcs = Array(hash["pattern"])
      raise InvalidRuleHashError, "pattern is missing" if srcs.empty?
      patterns = srcs.map.with_index do |src, index|
        begin
          Pattern::Parser.parse(src)
        rescue Racc::ParseError => exn
          raise PatternSyntaxError, "Pattern syntax error: rule=#{hash["id"]}, index=#{index}, pattern=#{Rainbow(src.split("\n").first).blue}: #{exn}"
        end
      end

      messages = Array(hash["message"])
      raise InvalidRuleHashError, "message is missing" if messages.empty?

      tags = Set.new(Array(hash["tags"]))
      before_examples = Array(hash["before"])
      after_examples = Array(hash["after"])
      justifications = Array(hash["justification"])

      Rule.new(id: id,
               messages: messages,
               patterns: patterns,
               sources: srcs,
               tags: tags,
               before_examples: before_examples,
               after_examples: after_examples,
               justifications: justifications)
    end
  end
end
