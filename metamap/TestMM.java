import java.io.PrintStream;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.File;
import java.util.List;
import java.util.ArrayList;
import se.sics.prologbeans.PrologSession;
import gov.nih.nlm.nls.metamap.*;

/**
 * TestMM: Playing around with metamap.
 *
 * @author Bogdan Dumitru
 * @version 0.1a
 */

public class TestMM {
  /** MetaMap api instance */
  MetaMapApi api;

  public TestMM() {
    this.api = new MetaMapApiImpl();
  }

  public TestMM(String host, int port) {
    this.api = new MetaMapApiImpl();
    this.api.setHost(host);
    this.api.setPort(port);  
  }
  
  void process(String term) throws Exception {
    List<Result> resultList = api.processCitationsFromString(term);
    for (Result result: resultList) {
      System.out.println("input text: "+result.getInputText());
      for (Utterance utterance: result.getUtteranceList()) {
        System.out.println("Utterance: "+utterance.getString());
        for (PCM pcm: utterance.getPCMList()) {
          System.out.println("Phrase: " + pcm.getPhrase().getPhraseText());
          for (Ev ev: pcm.getCandidateList()) {
	          System.out.println(" Candidate:");
	          System.out.println("  Score: " + ev.getScore());
	          System.out.println("  Concept Id: " + ev.getConceptId());
	          System.out.println("  Concept Name: " + ev.getConceptName());
	          System.out.println("  Preferred Name: " + ev.getPreferredName());
	          System.out.println("  Matched Words: " + ev.getMatchedWords());
	          System.out.println("  Semantic Types: " + ev.getSemanticTypes());
	          System.out.println("  MatchMap: " + ev.getMatchMap());
	          System.out.println("  MatchMap alt. repr.: " + ev.getMatchMapList());
	          System.out.println("  is Head?: " + ev.isHead());
	          System.out.println("  is Overmatch?: " + ev.isOvermatch());
	          System.out.println("  Sources: " + ev.getSources());
	          System.out.println("  Positional Info: " + ev.getPositionalInfo());
	        }

          for (Mapping map: pcm.getMappingList()) {
            System.out.println("Map Score: " + map.getScore());
            for (Ev mapEv: map.getEvList()) {
              System.out.println(" + Score: "+mapEv.getScore());
              System.out.println(" + Concept Id: "+mapEv.getConceptId());
              System.out.println(" + Concept Name: "+mapEv.getConceptName());
              System.out.println(" + Preferred Name: "+mapEv.getPreferredName());
              System.out.println(" + Matched Words: "+mapEv.getMatchedWords());
              System.out.println(" + Semantic Types: "+mapEv.getSemanticTypes());
              System.out.println(" + MatchMap: "+mapEv.getMatchMap());
              System.out.println(" + MatchMap alt. repr.: "+mapEv.getMatchMapList());
              System.out.println(" + is Head?: " + mapEv.isHead());
              System.out.println(" + is Overmatch?: "+mapEv.isOvermatch());
              System.out.println(" + Sources: "+mapEv.getSources());
              System.out.println(" + Positional Info: "+mapEv.getPositionalInfo());
            }
          }
        } 
      } 
    }
  }

  public static void main(String[] args) throws Exception {
    String serverHost = MetaMapApi.DEFAULT_SERVER_HOST;
    int serverPort = MetaMapApi.DEFAULT_SERVER_PORT;

    TestMM frontEnd = new TestMM(serverHost, serverPort);
    frontEnd.process("Friday , Nov. 7");
  }

}
