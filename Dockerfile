FROM eclipsecbi/ubuntu-gtk3-metacity:18.04-gtk3.22

# Back to root for install
USER root

RUN apt -y update && \
	apt -y install build-essential
	# apt -y install openjdk-8-jdk maven

ENV LANG=en_US.UTF-8

#Back to named user
USER 10001
#USER 1000