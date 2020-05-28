FROM stardog-eps-docker.jfrog.io/stardog:7.3.0

# fix perms
RUN chmod -R 666 /var/opt/stardog

