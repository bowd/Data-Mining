# www.igvita.com
#  - Jan. 06, 2008
#  - Ilya Grigorik

require 'rubygems'
require 'SVM'
require 'json'
include SVM

puts "Spam filtering test with LIBSVM"
puts "-------------------------------"

def cleanify(text)
  text.gsub(/[^[:alnum:]]/,' ').split(' ').map {|x| x.strip}.join(' ')
end

documents_with_labels = []
File.readlines('spam_train.json').each do |obj_str|
  begin
    doc = JSON.parse(obj_str) 
    documents_with_labels << [ doc['label'], cleanify(doc['text']) ]
  rescue Exception => e
    puts "JSON: #{obj_str}"
    raise e
  end
end

documents_with_labels.shuffle!
labels = documents_with_labels[0..(documents_with_labels.size-51)].map{|x| x[0]}
documents = documents_with_labels[0..(documents_with_labels.size-51)].map{|x| x[1]}

test_labels = documents_with_labels[(documents_with_labels.size-50)..(documents_with_labels.size-1)].map{|x| x[0]}
test_documents = documents_with_labels[(documents_with_labels.size-50)..(documents_with_labels.size-1)].map{|x| x[1]}
  
# Build a global dictionary of all possible words
dictionary = (documents+test_documents).flatten.uniq
puts "Global dictionary: \n\t #{dictionary.inspect}\n\n"

# Build binary feature vectors for each document 
#  - If a word is present in document, it is marked as '1', otherwise '0'
#  - Each word has a unique ID as defined by 'dictionary' 
feature_vectors = documents.map { |doc| dictionary.map{|x| doc.include?(x) ? 1 : 0} }
test_vectors = test_documents.map { |doc| dictionary.map{|x| doc.include?(x) ? 1 : 0} }

puts "First training vector: #{feature_vectors.first.inspect}\n"
puts "First test vector: #{test_vectors.first.inspect}\n"       

# Define kernel parameters -- we'll stick with the defaults
pa = Parameter.new
pa.C = 100
pa.svm_type = NU_SVC
pa.degree = 1
pa.coef0 = 0
pa.eps= 0.001

sp = Problem.new

# Add documents to the training set
labels.each_index { |i| sp.addExample(labels[i], feature_vectors[i]) }

# We're not sure which Kernel will perform best, so let's give each a try
kernels = [ LINEAR, POLY, RBF, SIGMOID ]
kernel_names = [ 'Linear', 'Polynomial', 'Radial basis function', 'Sigmoid' ]
m = nil

kernels.each_index { |j|
  # Iterate and over each kernel type
  pa.kernel_type = kernels[j]
  m = Model.new(sp, pa)
  ec = 0

  # Test kernel performance on the training set
  labels.each_index { |i|
    pred, probs = m.predict_probability(feature_vectors[i])
    #puts "Prediction: #{pred}, True label: #{labels[i]}, Kernel: #{kernel_names[j]}"
    ec += 1 if labels[i] != pred
  }
  puts "Kernel #{kernel_names[j]} made #{ec} errors on the training set"

  # Test kernel performance on the test set
  ec = 0
  test_labels.each_index { |i|
    pred, probs = m.predict_probability(test_vectors[i])
    puts "\t Prediction: #{pred}, True label: #{test_labels[i]}"
    ec += 1 if test_labels[i] != pred
  }

  puts "Kernel #{kernel_names[j]} made #{ec} errors on the test set \n\n"
}
