#
# This will try to detect whether the PermGen command line arguments can be used.
# On an IBM JVM, the default permgen arguments are not valid
#


#
# Darwin (apple) specific test that will guess a JAVA_HOME
#
if [ -z "$JAVA_HOME" -a -z "$JRE_HOME" ]; then
  if $darwin && [ -d "/System/Library/Frameworks/JavaVM.framework/Versions/1.5/Home" ]; then
    JAVA_HOME="/System/Library/Frameworks/JavaVM.framework/Versions/1.5/Home"
  fi
fi

#
# Catalina looks in 2 places  - JAVA_HOME and JRE_HOME
#
JAVA_PERMGEN_SUPPORTED=false
JAVA_LOCATION=${JAVA_HOME}
if [ -z "$JAVA_HOME" ]; then
    JAVA_LOCATION=${JRE_HOME}
fi


#
# Determine which JVM is being used
#
if [ -n "${JAVA_LOCATION}" ]; then
    if [ -x ${JAVA_LOCATION}/bin/java ]; then
        ${JAVA_LOCATION}/bin/java -version 2>&1 | grep IBM
        RT_CODE=$?
        if [ ${RT_CODE} -ne 0 ]; then
            JAVA_PERMGEN_SUPPORTED=true
        fi
    fi
fi
export JAVA_PERMGEN_SUPPORTED

