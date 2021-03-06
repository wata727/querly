$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'querly'
require "querly/cli"
require "querly/cli/test"

require 'minitest/autorun'
require "tmpdir"
require "unification_assertion"

Rainbow.enabled = false

module TestHelper
  E = Querly::Pattern::Expr
  A = Querly::Pattern::Argument
  K = Querly::Pattern::Kind

  def parse_expr(src, where: {})
    Querly::Pattern::Parser.parse(src, where: where).expr
  end

  def parse_kinded(src)
    Querly::Pattern::Parser.parse(src, where: {})
  end

  def query_pattern(pattern, src)
    pat = parse_kinded(pattern)

    analyzer = Querly::Analyzer.new(config: nil)
    analyzer.scripts << Querly::Script.new(path: Pathname("(input)"),
                                           node: Parser::CurrentRuby.parse(src, "(input)"))

    [].tap do |result|
      analyzer.find(pat) do |script, pair|
        result << pair.node
      end
    end
  end

  def ruby(src)
    Parser::CurrentRuby.parse(src)
  end

  def with_config(hash)
    Dir.mktmpdir do |dir|
      path = Pathname(dir) + "querly.yml"
      path.write(YAML.dump(hash))
      yield path
    end
  end

  def stdout
    @stdout ||= StringIO.new
  end

  def mktmpdir
    Dir.mktmpdir do |dir|
      yield Pathname(dir)
    end
  end
end
