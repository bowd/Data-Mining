import java.io.PrintStream;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.File;
import java.util.List;
import java.util.Collection;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Arrays;
import java.util.Iterator;
import java.util.Comparator;
import java.util.Set;
import java.util.TreeSet;
import java.util.TreeMap;
import org.apache.commons.collections.ListUtils;
import se.sics.prologbeans.PrologSession;
import gov.nih.nlm.nls.metamap.*;

import com.mongodb.Mongo;
import com.mongodb.DB;
import com.mongodb.DBCollection;
import com.mongodb.BasicDBObject;
import com.mongodb.DBObject;
import com.mongodb.DBCursor;
import com.mongodb.Bytes;
import org.bson.types.ObjectId;
import java.text.Normalizer;

/**
 * TestMM: Playing around with metamap.
 *
 * @author Bogdan Dumitru
 * @version 0.1a
 */

class Pair<A, B> {
 
  public A fst;
  public B snd;
 
  public Pair(A fst, B snd) {
    this.fst = fst;
    this.snd = snd;
  }
 
  public A getFirst() { return fst; }
  public B getSecond() { return snd; }
 
  public void setFirst(A v) { fst = v; }
  public void setSecond(B v) { snd = v; }
 
  public String toString() {
    return "Pair[" + fst + "," + snd + "]";
  }
 
  private static boolean equals(Object x, Object y) {
    return (x == null && y == null) || (x != null && x.equals(y));
  }
 
  public boolean equals(Object other) {
     return
      other instanceof Pair &&
      equals(fst, ((Pair)other).fst) &&
      equals(snd, ((Pair)other).snd);
  }
 
  public int hashCode() {
    if (fst == null) return (snd == null) ? 0 : snd.hashCode() + 1;
    else if (snd == null) return fst.hashCode() + 2;
    else return fst.hashCode() * 17 + snd.hashCode();
  }
 
  public static <A,B> Pair<A,B> of(A a, B b) {
    return new Pair<A,B>(a,b);
  }
}


public class MetaTag {
  /** MetaMap api instance */
  MetaMapApi api;
  public MetaTag() {
    this.api = new MetaMapApiImpl();
  }

  public MetaTag(String host, int port) {
    this.api = new MetaMapApiImpl();
    this.api.setHost(host);
    this.api.setPort(port);  
  }
  
  public static int getLevenshteinDistance (String s, String t) {
    if (s == null || t == null) {
      throw new IllegalArgumentException("Strings must not be null");
    }
    
    int n = s.length(); // length of s
    int m = t.length(); // length of t
    
    if (n == 0) {
      return m;
    } else if (m == 0) {
      return n;
    }

    int p[] = new int[n+1]; //'previous' cost array, horizontally
    int d[] = new int[n+1]; // cost array, horizontally
    int _d[]; //placeholder to assist in swapping p and d

    // indexes into strings s and t
    int i; // iterates through s
    int j; // iterates through t

    char t_j; // jth character of t

    int cost; // cost

    for (i = 0; i<=n; i++) {
       p[i] = i;
    }
    
    for (j = 1; j<=m; j++) {
      t_j = t.charAt(j-1);
      d[0] = j;
    
      for (i=1; i<=n; i++) {
        cost = s.charAt(i-1)==t_j ? 0 : 1;
        d[i] = Math.min(Math.min(d[i-1]+1, p[i]+1),  p[i-1]+cost);  
      }

      _d = p;
      p = d;
      d = _d;
    } 
  return p[n];
  }

  public static String join(List s, String delimiter) {
    StringBuffer buffer = new StringBuffer();
    Iterator iter = s.iterator();
    while (iter.hasNext()) {
      buffer.append(iter.next());
      if (iter.hasNext()) {
        buffer.append(delimiter);
      }
    }
    return buffer.toString();
  }

  public static List merge_unique(List A, List B) {
    return ListUtils.subtract(ListUtils.union(A, B), ListUtils.intersection(A, B));
  }

  public static void main(String[] args) throws Exception {
    String serverHost = MetaMapApi.DEFAULT_SERVER_HOST;
    int serverPort = MetaMapApi.DEFAULT_SERVER_PORT;
    TestMM frontEnd = new TestMM(serverHost, serverPort);
    
    Mongo m = new Mongo();
    DB db = m.getDB("test");
    DBCollection collection = db.getCollection( "chunk_sets" );
    ArrayList query_or = new ArrayList();
    query_or.add(new BasicDBObject().append("processed", new BasicDBObject().append("$exists", false)));
    query_or.add(new BasicDBObject().append("processed", false));
    BasicDBObject find_query = new BasicDBObject()//.append("_id", new ObjectId("4f42e2f106be6d4cab000080"));
                                                  .append("$or", query_or.toArray());
                                                  //.append("st", "ibuprofen");
    DBCursor cursor = collection.find(find_query).addOption(Bytes.QUERYOPTION_NOTIMEOUT);
    while( cursor.hasNext() ) {
      DBObject obj = cursor.next();
      System.out.println(obj.get("tweet_id"));

      ArrayList chunks = (ArrayList) obj.get("chunks");
      ArrayList setops = new ArrayList();
      TreeMap matches = new TreeMap();

      String text = (String) ((DBObject) chunks.get(0)).get("text");
      text = text.replaceAll("(?x) (?<= \\pL ) (?= \\pN ) | (?<= \\pN ) (?= \\pL )", " ");
      List<Result> resultList = frontEnd.api.processCitationsFromString((String) text);
      //System.out.println( text );
      //System.out.println( resultList.size() );
      for (Result result: resultList) {
        for (Utterance utterance: result.getUtteranceList()) {
          //System.out.println("Utterance: "+utterance.getString());
          for (PCM pcm: utterance.getPCMList()) {
            //System.out.println(" +Phrase: "+pcm.getPhrase().getPhraseText());
            for (Ev cEv: pcm.getCandidateList()) {
              if (cEv.getScore() > -600) continue;
              String key = MetaTag.join(cEv.getMatchedWords(), " ");
              ArrayList value = (ArrayList) matches.get(key);
              if (value != null) {
                value = (ArrayList) MetaTag.merge_unique((List) value, cEv.getSemanticTypes());
              } else value = (ArrayList) cEv.getSemanticTypes();
              matches.put(key, value); 
            }
            for (Mapping map: pcm.getMappingList()) {
              for (Ev mapEv: map.getEvList()) {
                String key = MetaTag.join(mapEv.getMatchedWords(), " ");
                ArrayList value = (ArrayList) matches.get(key);
                if (value != null) {
                  value = (ArrayList) MetaTag.merge_unique((List) value, mapEv.getSemanticTypes());
                } else value = (ArrayList) mapEv.getSemanticTypes();
                matches.put(key, value); 
                //System.out.println("  +Match: {"+key+"} "+value);
              }
            }
          }
        }
      }
      ArrayList semtypes = new ArrayList();
      for (Object mkey: matches.keySet()) {
        //System.out.println("Considering match: ("+(String) mkey+") "+matches.get(mkey) );
        String matched_text = (String) mkey;
        ArrayList scored_chunks = new ArrayList();
        Pair<DBObject, Integer> bestChunk = null;
        for (Object cit: chunks) {
          DBObject chunk = (DBObject) cit;
          Pair<DBObject, Integer> item = new Pair<DBObject, Integer>(chunk, (Integer) MetaTag.getLevenshteinDistance(((String) chunk.get("text")).toLowerCase(), matched_text));
          if (bestChunk == null || ((int) bestChunk.getSecond()) > ((int) item.getSecond())) bestChunk = item;
        }
        if ((int) bestChunk.getSecond() < 4) {
          semtypes.add( new BasicDBObject().append("id", ((DBObject) bestChunk.getFirst()).get("id"))
                                           .append("semtypes", matches.get(mkey)) );
        }
      }
      BasicDBObject update = new BasicDBObject().append("$set", new BasicDBObject().append("semtypes", semtypes).append("processed", true));
      BasicDBObject query = new BasicDBObject().append("tweet_id", obj.get("tweet_id"));
      collection.update(query, update);
    }
  }
}
