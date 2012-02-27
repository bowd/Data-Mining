JFLAGS = -g
RM = rm
JCP = -cp ":/fs/linserver/data1/mbax9bd2/sources/stanford-parser-2012-02-03/stanford-parser.jar:/fs/linserver/data1/mbax9bd2/sources/rabbitmq-java-client-bin-2.7.1/rabbitmq-client.jar:/fs/linserver/data1/mbax9bd2/sources/commons-io-2.1/commons-io-2.1.jar:/fs/linserver/data1/mbax9bd2/sources/snakeyaml-1.9.jar"
JC = javac
JAVA = java
.SUFFIXES: .java .class
.java.class:
		$(JC) $(JFLAGS) $(JCP) $*.java

CLASSES = SentenceWorker.java TestSP.java SentenceWorkerTest.java

default: classes
classes: $(CLASSES:.java=.class)

clean:
	$(RM) *.class

run:
		$(JAVA) $(JCP) SentenceWorker

test:
		$(JAVA) $(JCP) TestSP
