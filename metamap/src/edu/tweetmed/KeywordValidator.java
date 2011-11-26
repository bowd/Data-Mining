package edu.tweetmed;

import java.io.PrintStream;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.util.List;
import java.util.ArrayList;
import se.sics.prologbeans.PrologSession;
import gov.nih.nlm.nls.metamap.*;

/**
 * KeywordValidator: Validate keywords selected for the
 * TweetMed research project by crosschecking meaning
 * in MetaMap using the api.
 *
 * <p>
 * Created: Mon November 14 19:54:33 2011
 *
 * @author <a href="mailto:dumitrb9@cs.man.ac.uk">Bogdan Dumitru</a>
 * @version 0.1a 
 */

public class KeywordValidator throws Exception{
  /** MetaMap api instance */
  MetaMapApi mmapi;

  /** Input file with keywords */
  BufferedReader input;
  

  /** 
   * Creates a new <code>KeywordValidator</code> instance. 
   */
  public KetwordValidator(File file) {
    input = BufferedReader.new(FileReader.new(file));
  
  }
}
