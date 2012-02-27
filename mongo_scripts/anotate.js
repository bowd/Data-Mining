db['chunk_sets'].find().forEach( function process(doc) {
  var search_term = db['tweets'].find({'tweet_id': doc['tweet_id']})[0]['search_term'];
  db['chunk_sets'].update(doc, { $set: {'st': search_term} });
});
