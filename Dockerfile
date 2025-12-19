FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update -y && apt install --no-install-recommends -y xfce4 xfce4-goodies tigervnc-standalone-server novnc websockify sudo xterm vim net-tools curl wget git tzdata openssh-server tmate

# Setup SSH & Password
RUN mkdir /var/run/sshd
RUN echo 'root:rootadmin' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

RUN touch /root/.Xauthority
EXPOSE 5901
EXPOSE 6080

CMD bash -c "vncserver -localhost no -SecurityTypes None -geometry 1024x768 --I-KNOW-THIS-IS-INSECURE && \
    openssl req -new -subj '/C=JP' -x509 -days 365 -nodes -out self.pem -keyout self.pem && \
    websockify -D --web=/usr/share/novnc/ --cert=self.pem 6080 localhost:5901 && \
    tmate -S /tmp/tmate.sock new-session -d && \
    sleep 5 && \
    tmate -S /tmp/tmate.sock display -p '#{tmate_ssh}' > /root/ssh_address.txt && \
    tail -f /dev/null"
    
