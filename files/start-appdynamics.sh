#!bin/bash
export APPDYNAMICS_START_AGENT=true #set to false to disable agent hooking

echo "Start-appdynamics.sh initiated" >> appdynamics.log
echo "Found APPDYNAMICS_START_AGENT set to:${APPDYNAMICS_START_AGENT}" >> appdynamics.log
if [ "$APPDYNAMICS_START_AGENT" = "true" ]; then

    echo "Found APPDYNAMICS_START_DELAY set to:${APPDYNAMICS_START_DELAY}: waiting that long to hook JVM" >> appdynamics.log

    pid=
    while [ -z "$pid" ]
    do
    pid="$(pgrep java)"
    sleep ${APPDYNAMICS_START_DELAY}
    done

    echo "Found PID:${pid}:" >> appdynamics.log

    # Determine tier name from hostname
    #a=cadet-vehicle-7d9484c675-jmklb
    a=$HOSTNAME
    #b=Development
    b=$ENVIRONMENT

    echo "Found HOSTNAME:${a}:" >> appdynamics.log
    echo "Found ENVIRONMENT:${b}:" >> appdynamics.log

    appd_app_name="$(cut -d'-' -f1 <<<"$a")"-$b
    echo "Set appd_app_name to:${appd_app_name}:" >> appdynamics.log

    appd_tier_name="$(cut -d'-' -f2 <<<"$a")"
    echo "Set appd_tier_name to:${appd_tier_name}:" >> appdynamics.log

    export UNIQUE_HOST_ID=$(sed -rn '1s#.*/##; 1s/(.{12}).*/\1/p' /proc/self/cgroup)
    echo "Unique Host ID is:${UNIQUE_HOST_ID}:" >> appdynamics.log

    echo "Hooking AppD agent into pid:${pid}, with app name:${appd_app_name}, tier name:${appd_tier_name}, and node name prefix:${appd_tier_name}, node name reuse is set to 'true'" >> appdynamics.log
    java -Xbootclasspath/a:/usr/lib/jvm/java-1.8.0-openjdk-amd64/lib/tools.jar -jar /opt/appdynamics/agent/javaagent.jar ${pid} appdynamics.agent.applicationName=${appd_app_name},appdynamics.agent.tierName=${appd_tier_name},appdynamics.agent.reuse.nodeName.prefix=${appd_tier_name},appdynamics.agent.reuse.nodeName=true,appdynamics.agent.uniqueHostId=${UNIQUE_HOST_ID},appdynamics.analytics.agent.url=http://169.60.159.85:9090/v2/sinks/bt &
    echo "AppD agent has been hooked!" >> appdynamics.log
else 
    echo "APPDYNAMICS_START_AGENT is 'false', exiting without hooking agent" >> appdynamics.log
fi
echo "Done Logging" >> appdynamics.log
