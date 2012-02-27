db['chunk_sets'].find().limit(2000).forEach( function(doc) {
  db['chunk_sets_ss'].insert(doc);  
});
