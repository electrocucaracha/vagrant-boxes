#!/bin/bash -eux

PROFILE_ROOT_HOME=${PROFILE_ROOT_HOME:-/root}
PROFILE_VAGRANT_HOME=${PROFILE_VAGRANT_HOME:-/home/vagrant}

profile2604_main() {
	cd "${PROFILE_ROOT_HOME}" && patch -p1 <<-EOF
		diff --git a/.bashrc b/.bashrc
		index f6939ee..545eaea 100644
		--- a/.bashrc
		+++ b/.bashrc
		@@ -7,14 +7,14 @@

		 # don't put duplicate lines in the history. See bash(1) for more options
		 # ... or force ignoredups and ignorespace
		-HISTCONTROL=ignoredups:ignorespace
		+HISTCONTROL=ignoredups

		 # append to the history file, don't overwrite it
		 shopt -s histappend

		 # for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
		-HISTSIZE=1000
		-HISTFILESIZE=2000
		+HISTSIZE=100000
		+HISTFILESIZE=100000

		 # check the window size after each command and, if necessary,
		 # update the values of LINES and COLUMNS.
		@@ -30,7 +30,7 @@ fi

		 # set a fancy prompt (non-color, unless we know we "want" color)
		 case "\$TERM" in
		-    xterm-color) color_prompt=yes;;
		+    xterm-color|*-256color) color_prompt=yes;;
		 esac

		 # uncomment for a colored prompt, if the terminal has the capability; turned
		@@ -94,6 +94,6 @@ fi
		 # enable programmable completion features (you don't need to enable
		 # this, if it's already enabled in /etc/bash.bashrc and /etc/profile
		 # sources /etc/bash.bashrc).
		-#if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
		-#    . /etc/bash_completion
		-#fi
		+if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
		+    . /etc/bash_completion
		+fi
	EOF

	cat <<-EOF >"${PROFILE_ROOT_HOME}/.vimrc"
		set mouse-=a
	EOF

	if [ -d "${PROFILE_VAGRANT_HOME}/" ] && [ -f "${PROFILE_VAGRANT_HOME}/.bashrc" ]; then
		cd "${PROFILE_VAGRANT_HOME}/" && patch -p1 <<-EOF
			diff --git a/.bashrc b/.bashrc
			index b488fcc..559370c 100644
			--- a/.bashrc
			+++ b/.bashrc
			@@ -10,14 +10,14 @@ esac

			 # don't put duplicate lines or lines starting with space in the history.
			 # See bash(1) for more options
			-HISTCONTROL=ignoreboth
			+HISTCONTROL=ignoredups

			 # append to the history file, don't overwrite it
			 shopt -s histappend

			 # for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
			-HISTSIZE=1000
			-HISTFILESIZE=2000
			+HISTSIZE=100000
			+HISTFILESIZE=100000

			 # check the window size after each command and, if necessary,
			 # update the values of LINES and COLUMNS.
		EOF
		chown vagrant:vagrant "${PROFILE_VAGRANT_HOME}/.bashrc"
	fi

	if [ -d "${PROFILE_VAGRANT_HOME}/" ]; then
		cat <<-EOF >"${PROFILE_VAGRANT_HOME}/.vimrc"
			set mouse-=a
		EOF
		chown vagrant:vagrant "${PROFILE_VAGRANT_HOME}/.vimrc"
	fi
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
	profile2604_main "$@"
fi
