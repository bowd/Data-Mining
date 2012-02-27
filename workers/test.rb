require '~/Data-Mining/lib/setup.rb'

parsed_tree = TreeParser.new("(ROOT (S (NP (NNP Vyvanse)) (VP (VBZ is) (NP (NP (CD one) (NN hell)) (PP (IN of) (NP (DT a) (NN drug))))) (. .)))")
puts parsed_tree.chunks
