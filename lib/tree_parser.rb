class TreeParser 
  attr_accessor :chunks, :tree, :parent_of

  def parse_node(tokens, index, dest)
    if tokens[index] != "("
      dest[:type] = "Text"
      dest[:text] = tokens[index]
      return index + 1
    end
    index += 1
    dest[:type] = tokens[index]
    index += 1
    dest[:children] = []
    dest[:text] = []
    dest[:id] = @current_max_node_id
    @current_max_node_id += 1
    if tokens[index] == "("
      while (tokens[index] == "(")
        child = {}
        index = parse_node(tokens, index, child)
        dest[:children] << child
        dest[:text] << child[:text]
      end
      dest[:text] = dest[:text].join(' ')
    else
      child = {}
      index = parse_node(tokens, index, child)
      dest[:children] << child
      dest[:text] = child[:text]
    end
    return index + 1
  end

  def parse_chunks(node)
    if node.has_key?(:id) 
      @chunks << { :id => node[:id], :text => node[:text] }
    end
    node[:children].each do |child|
      @parent_of[child[:id]] = node[:id]
      parse_chunks(child)
    end if node.has_key? :children
  end

  def initialize(text)
    @current_max_node_id = 1
    @chunks = []
    @parent_of = {}
    @tree = { :type => "BROOT", :children => [], :text => [], :id => 0 }
    text.split("<#EOS#>").each_with_index do |sent, idx|
      sent = sent.gsub("(", " ( ").gsub(")", " ) ")
      tokens = sent.split(" ")
      child = {}
      parse_node(tokens, 0, child)
      tree[:children] << child
      tree[:text] << child[:text]
    end
    tree[:text] = tree[:text].join(" ")
    parse_chunks(tree)
  end
end


