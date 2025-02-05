#!/bin/sh

# **************************************************
# ** Libraries used by Kettle:                    **
# **************************************************


BASEDIR=`dirname $0`
cd $BASEDIR
DIR=`pwd`
cd - > /dev/null

. "$DIR/set-pentaho-env.sh"

setPentahoEnv

CLASSPATH=$BASEDIR
CLASSPATH=$CLASSPATH:$BASEDIR/lib/kettle-core-5.1.0.0-752.jar
CLASSPATH=$CLASSPATH:$BASEDIR/lib/kettle-engine-5.1.0.0-752.jar

# **************************************************
# ** JDBC & other libraries used by Kettle:       **
# **************************************************

for f in `find $BASEDIR/lib -type f -name "*.jar"` `find $BASEDIR/lib -type f -name "*.zip"`
do
  CLASSPATH=$CLASSPATH:$f
done


# **************************************************
# ** Platform specific libraries ...              **
# **************************************************

# circumvention for the IBM JVM behavior (seems to be a problem with the IBM JVM native compiler)
if [ `uname -s` = "OS400" ]
then
  CLASSPATH=${CLASSPATH}:$BASEDIR/libswt/aix/swt.jar
fi


# ******************************************************************
# ** Set java runtime options                                     **
# ** Change 512m to higher values in case you run out of memory   **
# ** or set the PENTAHO_DI_JAVA_OPTIONS environment variable      **
# ** (JAVAMAXMEM is there for compatibility reasons)              **
# ******************************************************************

if [ -z "$JAVAMAXMEM" ]; then
  JAVAMAXMEM="512"
fi

if [ -z "$PENTAHO_DI_JAVA_OPTIONS" ]; then
    PENTAHO_DI_JAVA_OPTIONS="-Xmx${JAVAMAXMEM}m"
fi

OPT="$PENTAHO_DI_JAVA_OPTIONS -cp $CLASSPATH -DDI_HOME=$DIR -DKETTLE_HOME=$KETTLE_HOME -DKETTLE_REPOSITORY=$KETTLE_REPOSITORY -DKETTLE_USER=$KETTLE_USER -DKETTLE_PASSWORD=$KETTLE_PASSWORD -DKETTLE_PLUGIN_PACKAGES=$KETTLE_PLUGIN_PACKAGES -DKETTLE_LOG_SIZE_LIMIT=$KETTLE_LOG_SIZE_LIMIT -DKETTLE_JNDI_ROOT=$KETTLE_JNDI_ROOT"

if [ "$1" = "-x" ]; then
  set LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BASEDIR/lib
  export LD_LIBRARY_PATH
  OPT="-Xruntracer $OPT"
  shift
fi

# ***************
# ** Run...    **
# ***************

"$_PENTAHO_JAVA" $OPT org.pentaho.di.kitchen.Kitchen "${1+$@}"

