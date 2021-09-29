
function wait_for_start {
    (
    HOST=${1}
    PORT=${2}
    DELAY=${3}
    # Wait for stardog to be running
    RC=1
    COUNT=0
    set +e
    while [[ ${RC} -ne 0 ]];
    do
      if [[ ${COUNT} -gt ${DELAY} ]]; then
          return 1;
      fi
      COUNT=$(expr 1 + ${COUNT} )
      sleep 1
      curl -v  http://${HOST}:${PORT}/admin/healthcheck
      RC=$?
    done

    return 0
    )
}

function change_pw {
    (
    set +ex
    HOST=${1}
    PORT=${2}

    echo "/opt/stardog/bin/stardog-admin --server http://${HOST}:${PORT} user passwd -N xxxxxxxxxxxxxx"
    NEW_PW=$(cat /etc/stardog-password/adminpw)
    /opt/stardog/bin/stardog-admin --server http://${HOST}:${PORT} user passwd -N ${NEW_PW}
    if [[ $? -eq 0 ]];
    then
	    echo "Password successfully changed"
	    return 0
    else
    	curl --fail -u admin:${NEW_PW} http://${HOST}:${PORT}/admin/status
    	RC=$?
    	if [[ $RC -eq 0 ]];
      then
        echo "Default password was already changed"
        return 0
      elif [[ $RC -eq 22 ]]
      then
        echo "HTTP 4xx error"
        return $RC
      else
        echo "Something else went wrong"
        return $RC
      fi
    fi
    )
}

function make_temp {
    (
    set +e
    TEMP_PATH=${1}

    if [ ! -d "$TEMP_PATH" ]; then
      mkdir -p $TEMP_PATH
      if [ $? -ne 0 ]; then
        echo "Could not create stardog tmp directory ${TEMP_PATH}" >&2
        return 1
      fi
    fi
    )
}