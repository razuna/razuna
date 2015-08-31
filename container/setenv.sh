LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CATALINA_HOME/lib
export LD_LIBRARY_PATH

CATALINA_OPTS="$CATALINA_OPTS -Djava.library.path=/usr/local/apr/lib/"

CATALINA_OPTS="$CATALINA_OPTS -server -Xss1M -Xms3G -Xmx3G -XX:+UseConcMarkSweepGC -XX:+CMSIncrementalMode -Djava.awt.headless=true -Dorg.apache.jasper.runtime.BodyContentImpl.LIMIT_BUFFER=true -Dmail.mime.decodeparameters=true -XX:+PrintGCDateStamps -XX:-OmitStackTraceInFastThrow -Djava.security.egd=file:/dev/./urandom"

#-XX:+UseConcMarkSweepGC -XX:NewSize=1G -XX:+UseParNewGC

#-server -Xss1M -Xms8G -Xmx10G $CATALINA_OPTS -Djava.awt.headless=true -Dorg.apache.jasper.runtime.BodyContentImpl.LIMIT_BUFFER=true -XX:SurvivorRatio=4 -XX:MaxPermSize=1024m -XX:NewRatio=2

# Perm Gen size needs to be increased if encountering OutOfMemoryError: PermGen problems. Specifying PermGen size is not valid on IBM JDKs

PRGDIR=`dirname $0`
RAZUNA_MAX_PERM_SIZE=1024m
if [ -f "${PRGDIR}/permgen.sh" ]; then
    echo "Detecting JVM PermGen support..."
    . ${PRGDIR}/permgen.sh
    if [ $JAVA_PERMGEN_SUPPORTED = "true" ]; then
        echo "PermGen switch is supported. Setting to ${RAZUNA_MAX_PERM_SIZE}"
        CATALINA_OPTS="-XX:MaxPermSize=${RAZUNA_MAX_PERM_SIZE} ${CATALINA_OPTS}"
    else
        echo "PermGen switch is NOT supported and will NOT be set automatically."
    fi
fi

#export JAVA_OPTS="$JAVA_OPTS -javaagent:/opt/tomcat/webapps/razuna/WEB-INF/lib/newrelic.jar"
export CATALINA_OPTS

