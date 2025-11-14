#BASE IMAGE 
FROM kalilinux/kali-rolling

#NON-INTERACTIVE APT DURING INSTALLING PROCESS
ENV DEBIAN_FRONTEND=noninteractive

#UPDATE + INSTALL APT TOOLS. YOU CAN ADD DIFFERENT TOOLS HERE
RUN apt update && apt install -y \
    git               \  
    curl wget unzip   \
    python3 python3-pip \
    nmap              \
    amass             \
    wfuzz             \
    whatweb           && apt clean

#INSTALL GO 
RUN curl -LO https://go.dev/dl/go1.21.1.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.21.1.linux-amd64.tar.gz && \
    rm go1.21.1.linux-amd64.tar.gz

ENV PATH="/usr/local/go/bin:$PATH"

#INSTALL GO-BASED PENTEST TOOLS. YOU CAN ADD DIFFERENT TOOLS HERE
RUN go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest \
    && mv $HOME/go/bin/subfinder /usr/local/bin/ \
    && go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest \
    && mv $HOME/go/bin/httpx /usr/local/bin/ \
    && go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest \
    && mv $HOME/go/bin/nuclei /usr/local/bin/ \
    && go install -v github.com/OJ/gobuster/v3@latest \
    && mv $HOME/go/bin/gobuster /usr/local/bin/

#USER ALIASES & SHELL SETUP 
RUN echo 'alias ll="ls -la"' >> /root/.bashrc
