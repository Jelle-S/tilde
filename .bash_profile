if [ -f ~/.bashrc ]; then
	source ~/.bashrc
fi

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

# Added by `rbenv init` on vr 07 jun 2024 15:10:08 CEST
eval "$(rbenv init -)"
