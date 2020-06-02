
function wait_for_start {
    (
    HOST=${1}
    PORT=${2}
    # Wait for stardog to be running
    RC=1
    COUNT=0
    set +e
    while [[ ${RC} -ne 0 ]];
    do
      if [[ ${COUNT} -gt 300 ]]; then
          return 1;
      fi
      COUNT=$(expr 1 + ${COUNT} )
      sleep 1
      curl -v  http://${HOST}:${PORT}/admin/healthcheck
      RC=$?
    done
    # Give it a second to finish starting up
    sleep 5

    return 0
    )
}

function change_pw {
    (
    set +e
    HOST=${1}
    PORT=${2}
    NEW_PW=$(cat /etc/stardog-password/adminpw)
    /opt/stardog/bin/stardog-admin --server http://${HOST}:${PORT} user passwd -N ${NEW_PW}
    RC=$?
    return ${RC}
    )
}
