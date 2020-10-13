FROM swipl:stable


WORKDIR /app/lib

RUN apt-get update && apt-get install -y git build-essential make time
RUN git clone https://github.com/khueue/prolog-bson && git clone https://github.com/khueue/prolongo

COPY . /app
WORKDIR /app
CMD ["swipl", "main.pl"]