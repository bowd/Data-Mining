require 'stanfordparser'

preproc = StanfordParser::DocumentPreprocessor.new
parser = StanfordParser::LexicalizedParser.new

puts parser.apply("I like penis.")

