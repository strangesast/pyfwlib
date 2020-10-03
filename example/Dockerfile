from python:3-slim-buster

workdir /usr/src/app

run dpkg --add-architecture i386 && apt-get update -y && apt-get install -y build-essential

copy . .

run python3 setup.py install

cmd ["python3", "example/example.py"]
