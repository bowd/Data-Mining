import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.io.StringReader;
import java.util.Map;
import java.util.HashMap;

import edu.stanford.nlp.objectbank.TokenizerFactory;
import edu.stanford.nlp.process.CoreLabelTokenFactory;
import edu.stanford.nlp.process.DocumentPreprocessor;
import edu.stanford.nlp.process.PTBTokenizer;
import edu.stanford.nlp.ling.*;  
import edu.stanford.nlp.trees.*;
import edu.stanford.nlp.parser.lexparser.LexicalizedParser;

import com.rabbitmq.client.ConnectionFactory;
import com.rabbitmq.client.Connection;
import com.rabbitmq.client.Channel;
import com.rabbitmq.client.QueueingConsumer;

import org.yaml.snakeyaml.*;

class SentenceWorker {

  private final static String POP_QUEUE_NAME = "tweets";
  private final static String PUSH_QUEUE_NAME = "parsed_tweets";
  private final static String SENTENCE_DELIMITER = "<#EOS#>";
  private final static String EXCHANGE = "";

  public static void main(String[] args) throws java.io.IOException, java.lang.InterruptedException {
    LexicalizedParser lp = 
      new LexicalizedParser("/fs/linserver/data1/mbax9bd2/sources/stanford-parser-2012-02-03/grammar/englishPCFG.ser.gz");
    /* Connect to queue */
    ConnectionFactory factory = new ConnectionFactory();
    factory.setHost("localhost");
    Connection connection = factory.newConnection();
    Channel channel = connection.createChannel();
    //channel.exchangeDeclare(EXCHANGE, "direct", true);
    channel.queueDeclare(POP_QUEUE_NAME, false, false, false, null);

    QueueingConsumer consumer = new QueueingConsumer(channel);
    channel.basicConsume(POP_QUEUE_NAME, true, consumer);

    Yaml yaml = new Yaml();
    Map tweet;
    
    /* Main loop get message - process */
    while (true) {
      QueueingConsumer.Delivery delivery = consumer.nextDelivery();
      String message = new String(delivery.getBody());
      tweet = (Map) yaml.load(message);
      String parsedText = "";

      for (List<HasWord> sentence : new DocumentPreprocessor(new StringReader((String) tweet.get(":text")))) {
        Tree pTree = lp.apply(sentence);
        parsedText += pTree.toString() + SENTENCE_DELIMITER; 
      }
      Map<String, Object> msg = new HashMap<String, Object>();
      msg.put(":id", tweet.get(":id"));
      msg.put(":text", parsedText); 
      String msg_string = yaml.dump(msg);
      channel.basicPublish(EXCHANGE, "parsed_tweets", null, msg_string.getBytes());
    }
  }

  private SentenceWorker() {} // static methods only

}
