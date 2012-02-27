var search_terms = new Array();

db['chunk_sets'].find().forEach( function process(doc) { 
  var tweet_id = doc['tweet_id'];
  doc = db['tweets'].find({'tweet_id': tweet_id}, {'search_term': 1})[0];
  
  search_terms[ doc['search_term'] ] = (search_terms[ doc['search_term'] ] == undefined) ? 1 : (search_terms[ doc['search_term'] ] + 1);
});

for ( i in search_terms ) {
  print(i + "#"+ search_terms[i]);
}
