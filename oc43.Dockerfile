FROM widerin/openshift-cli
RUN mkdir /ocp43
WORKDIR /ocp43
RUN curl -O https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux-4.3.0.tar.gz
RUN tar -xzf openshift-client-linux-4.3.0.tar.gz
RUN alias oc=/ocp43/oc