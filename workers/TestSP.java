import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Set;
import java.util.Iterator;
import java.io.StringReader;
import java.util.Map;
import java.util.HashSet;

import edu.stanford.nlp.objectbank.TokenizerFactory;
import edu.stanford.nlp.process.CoreLabelTokenFactory;
import edu.stanford.nlp.process.DocumentPreprocessor;
import edu.stanford.nlp.process.PTBTokenizer;
import edu.stanford.nlp.ling.CoreLabel;  
import edu.stanford.nlp.ling.HasWord;
import edu.stanford.nlp.ling.Label;
import edu.stanford.nlp.trees.*;
import edu.stanford.nlp.parser.lexparser.LexicalizedParser;

class TestSP {

  private final static String QUEUE_NAME = "tweets";

  public static void main(String[] args) throws java.io.IOException, java.lang.InterruptedException {
    LexicalizedParser lp = 
      new LexicalizedParser("/fs/linserver/data1/mbax9bd2/sources/stanford-parser-2012-02-03/grammar/englishPCFG.ser.gz");
    TreebankLanguagePack tlp = new PennTreebankLanguagePack();
    GrammaticalStructureFactory gsf = tlp.grammaticalStructureFactory();
    /* Connect to queue */
    String tweet = "Vyvanse is one hell of a drug.";


    for (List<HasWord> sentence : new DocumentPreprocessor(new StringReader(tweet))) {
      Tree pTree = lp.apply(sentence);
      GrammaticalStructure gs = gsf.newGrammaticalStructure( pTree );
      HashSet<TypedDependency> m_deps = new HashSet<TypedDependency>();
      Iterator iter = gs.typedDependencies().iterator();
      while( iter.hasNext() ){
        m_deps.add( (TypedDependency)iter.next() );
      }
      System.out.println(m_deps.toString());
      System.out.println(pTree.toString());
    }
    

    /*TreebankLanguagePack tlp = new PennTreebankLanguagePack();
    GrammaticalStructureFactory gsf = tlp.grammaticalStructureFactory();
    GrammaticalStructure gs = gsf.newGrammaticalStructure(parse);
    List<TypedDependency> tdl = gs.typedDependenciesCCprocessed();
    */
  }

  private TestSP() {} // static methods only

}
