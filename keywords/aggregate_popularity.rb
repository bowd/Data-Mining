require '~/Data-Mining/lib/setup.rb'

@db = DB.new('test')

max_kp = {:k1=>2610000000, :k2=>3800000000, :k3=>495000000, :k4=>215000000}
count = 0

def get_score(scores, max_kp)
  scaled_scores = {}
  [:k1, :k2, :k3, :k4].each do |key|
    scaled_scores[key] = scores[key.to_s].to_f * 93 / max_kp[key]
  end
  (scaled_scores[:k3] + scaled_scores[:k4])/2
end

@db['drugs'].find().each do |row|
  next if !row.has_key?('partial_scores')
  score = []
  score << get_score(row['partial_scores'], max_kp)
  if row['partial_scores'].has_key?('tradename')
    row['partial_scores']['tradename'].each do |k, v|
      score << get_score(v, max_kp)
    end
  end
#puts row['partial_scores']
# puts score
  fscore = score.inject(0.0) {|r, e| r + e} / score.size
  fscore = (fscore * 10**2).round.to_f / 10**2
  fscore += 7 if row.has_key?('popular')
#  puts fscore
  @db['drugs'].update(row, { "$set" => { "score" => fscore } })
  count += 1
  puts "Done #{count}" if (count % 50 == 0) 
end

puts max_kp
