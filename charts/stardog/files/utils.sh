
function wait_for_start {
    (
    PORT=${1}
    # Wait for stardog to be running
    RC=1
    COUNT=0
    set +e
    while [[ ${RC} -ne 0 ]];
    do
      if [[ ${COUNT} -gt 90 ]]; then
          return 1;
      fi
      COUNT=$(expr 1 + ${COUNT} )
      sleep 1
      curl -v  http://localhost:${PORT}
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

    PORT=${1}
    NEW_PW=$(cat /etc/stardog-password/adminpw)

    /opt/stardog/bin/stardog-admin --server http://localhost:${PORT} user list -u admin -p ${NEW_PW}
    if [ $? -eq 0 ]; then
        echo "Password already changed"
        return 0
    fi
    /opt/stardog/bin/stardog-admin --server http://localhost:${PORT} user passwd -N ${NEW_PW}
    RC=$?
    return ${RC}
    )
}

function shutdown_stardog {
(
    PORT=${1}
    THIS_PW=$(cat /etc/stardog-password/adminpw)
    set -e
    /opt/stardog/bin/stardog-admin --server http://localhost:${PORT} server stop -p ${THIS_PW}
)
}
