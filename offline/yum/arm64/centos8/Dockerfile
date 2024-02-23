FROM centos:8 as build0
#########################################################################################
ENV DOCKER_REPO=https://download.docker.com/linux/centos/docker-ce.repo
COPY pkg.list /
#COPY kubernetes.repo /etc/yum.repos.d/
RUN rm -rf /etc/yum.repos.d/*
COPY  CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo
RUN yum clean all
RUN mkdir /rpms \
    && yum install -y  yum-utils epel-release \
    && yum-config-manager --add-repo $DOCKER_REPO \
    && yum install -y --skip-broken --downloadonly --downloaddir=/rpms $(cat /pkg.list)

#########################################################################################


#########################################################################################
FROM centos:8 as build1
RUN rm -rf /etc/yum.repos.d/*
WORKDIR /app
COPY  CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo
RUN yum install -y createrepo python3-devel python3 gcc python3-createrepo_c libmodulemd git  
RUN dnf install python3-gobject -y
RUN git clone --branch modulemd-tools-0.11-1 https://github.com/rpm-software-management/modulemd-tools.git  \
    && cd modulemd-tools/repo2module/ \
    && python3 setup.py install --user 

COPY --from=build0 /rpms/* /rpms/
RUN cd /rpms && createrepo_c . && /root/.local/bin/repo2module  -s stable  . modules.yaml \
    && modifyrepo_c --mdtype=modules modules.yaml repodata/ && ls -al /rpms
#########################################################################################
FROM nginx:alpine
RUN mkdir /usr/share/nginx/html/rpms
COPY --from=build1 /rpms/* /usr/share/nginx/html/rpms/
COPY nginx.conf /etc/nginx/conf.d/default.conf
RUN mkdir /usr/share/nginx/html/rpms/repodata && \
    cd /usr/share/nginx/html/rpms && \
    mv  repomd.xml  repodata && \
    mv *.bz2 repodata && \
    mv *.gz repodata 
RUN ls -al /usr/share/nginx/html/rpms/