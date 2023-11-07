# Custom Docker file to build a Docker image and restore Nessus
FROM tenableofficial/nessus:latest

ENV NESSUS_BACKUP_GIT=""
ENV NESSUS_BACKUP_FILE=""

COPY docker_shell.sh /home/docker_shell.sh

RUN chmod a+x /home/docker_shell.sh
RUN mkdir /home/nessus

RUN dnf -y install git tar && dnf clean all
RUN tar cf /opt+nessus.tar /opt/nessus && rm -rf /opt/nessus && gzip -9 /opt+nessus.tar
    
CMD ["/home/docker_shell.sh"]