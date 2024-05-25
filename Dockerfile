FROM --platform=linux/amd64 node:lts
ADD ./packages/service1 /service1
ADD ./packages/service2 /service2
RUN cd /service1 && npm install
RUN cd /service2 && npm install
ENTRYPOINT ["node"]
