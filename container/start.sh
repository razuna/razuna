#!/bin/bash

/etc/init.d/memcached start
/etc/init.d/ssh start
service tomcat start
tail -F /opt/tomcat/logs/catalina.out
