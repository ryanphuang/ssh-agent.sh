# ssh-agent.sh

Simple Bash wrapper of `ssh-agent` for managing password-protected SSH key sessions.
The goal is to avoid typing password for SSH key and automatically reap SSH agent 
upon last disconnection for security.

## Usage

Put [.ssh-agent.sh](.ssh-agent.sh) in the home directory and add the following to 
the end of `.bashrc`.

```bash

[[ -s "$HOME/.ssh-agent.sh" ]] && source $HOME/.ssh-agent.sh

```

Then you can type `ssh-tap` at the beginning, which will create an SSH agent 
session if it does not exist and set the session expiration time to be 3 hours. 
Within the 3 hours, subsequent logins do not require typing passwords any more, 
until the last login exits or gets disconnected, in which case the SSH-agent 
will be killed.

## References

1. http://rabexc.org/posts/pitfalls-of-ssh-agents
2. http://blog.joncairns.com/2013/12/understanding-ssh-agent-and-ssh-add
