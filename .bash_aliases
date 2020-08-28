alias eecs='cd /home/sudacode/projects/eecs370/project4/'
alias lca='colorls -A --sd -X'
alias lc='colorls --sd -X'
alias lcl='colorls --sd -Xl'
alias lcla='colorls -lA --sd -X'
alias lcal='colorls -lA --sd -X'
alias scripts='cd /home/sudacode/scripts'
alias freud='cd /home/sudacode/'
alias expl='explorer.exe .'
alias spu='sudo pacman -Syu'
alias suda='sudo'

# This is specific to WSL 2. If the WSL 2 VM goes rogue and decides not to free
# up memory, this command will free your memory after about 20-30 seconds.
#   Details: https://github.com/microsoft/WSL/issues/4166#issuecomment-628493643
alias drop_cache="sudo sh -c \"echo 3 >'/proc/sys/vm/drop_caches' && swapoff -a && swapon -a && printf '\n%s\n' 'Ram-cache and Swap Cleared'\""
