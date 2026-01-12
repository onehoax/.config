alias ll='ls -ltrhAF --color=auto'
alias grep='grep --color=auto'

alias docker-prune='docker system prune -af --volumes'
alias docker-projects='docker ps -a --format "table {{.Label \"com.docker.compose.project\"}}\t{{.Names}}\t{{.Status}}"'

alias ip-private='ip addr show'
alias ip-public='curl https://ipinfo.io/ip'
