JFLAGS = -g
RM = rm
JC = javac
BASEDIR=/fs/linserver/data1/mbax9bd2/sources/public_mm
PBJAR=$(BASEDIR)/src/javaapi/dist/prologbeans.jar
MMAJAR=$(BASEDIR)/src/javaapi/dist/MetaMapApi.jar
MONGOJAR=/fs/linserver/data1/mbax9bd2/Data-Mining/jars/mongo-2.7.3.jar
AOCJAR=/fs/linserver/data1/mbax9bd2/Data-Mining/jars/commons-collections-3.2.1/commons-collections-3.2.1.jar
JCP = -cp ":$(PBJAR):$(MMAJAR):$(MONGOJAR):$(AOCJAR)"
JAVA = java
.SUFFIXES: .java .class
.java.class:
		$(JC) $(JFLAGS) $(JCP) $*.java

CLASSES = TestMM.java MetaTag.java

default: classes
classes: $(CLASSES:.java=.class)

clean:
	$(RM) *.class

run:
		$(JAVA) $(JCP) MetaTag

test:
		$(JAVA) $(JCP) TestMM
