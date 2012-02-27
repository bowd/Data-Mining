db['chunk_sets'].find({ processed: true }).forEach( function(doc) {
  db['chunk_sets'].update(doc, { $set : { processed: false } });
});
