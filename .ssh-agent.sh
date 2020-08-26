#!/bin/bash

#######################################
#
# Author: Ryan Huang (huang@cs.jhu.edu)
#
#######################################

function reap_links()
{
  if [[ ! -d $HOME/.ssh/sessions ]]; then
    return 0
  fi
  sock_links=$(for i in `find $HOME/.ssh/sessions -name "*.sock"`; do basename -s .sock $i; done)
  alive_links=$(pgrep -u $USER bash)
  stale_links=$(comm -23 <(printf "%s\n" "${sock_links[@]}" | sort) <(printf "%s\n" "${alive_links[@]}" | sort) | sort -n)
  if [[ "$stale_links" != "" ]]; then 
    echo "Reaping stale links: $stale_links"
  fi
  for stale_link in $stale_links
  do
    rm -f $HOME/.ssh/sessions/$stale_link.sock
  done
}

function end_agent()
{
  reap_links
  # if we are the last holder of a hardlink, then kill the agent
  if [[ "$CUR_AUTH_SOCK" != "" ]] && [[ -e $CUR_AUTH_SOCK ]]; then
    nhard=`ls -l $CUR_AUTH_SOCK | awk '{print $2}'`
    if [[ $nhard -le 2 ]]; then
      rm -f ~/.ssh/.agent_env
      ssh-agent -k
      rm -f ~/.ssh/ssh_auth_sock
      rm -rf ~/.ssh/sessions
    fi
    rm -f $CUR_AUTH_SOCK
    echo "Bye."
  fi
}

if [ ! -S ~/.ssh/ssh_auth_sock ]; then
  eval `ssh-agent -s`
  ln -sf "$SSH_AUTH_SOCK" ~/.ssh/ssh_auth_sock
  rm -f ~/.ssh/.agent_env
  echo 'export SSH_AUTH_SOCK'=~/.ssh/ssh_auth_sock >> ~/.ssh/.agent_env
  echo 'export SSH_AGENT_PID'=$SSH_AGENT_PID >> ~/.ssh/.agent_env
  mkdir -p ~/.ssh/sessions
fi
source ~/.ssh/.agent_env
alias ssh-tap='ssh-add -l > /dev/null || ssh-add -t 3h'
alias ssh-add='ssh-add -t 3h'
export CUR_AUTH_SOCK=$HOME/.ssh/sessions/$$.sock

if [ ! -f $CUR_AUTH_SOCK ]; then
  ln -T $HOME/.ssh/ssh_auth_sock $CUR_AUTH_SOCK
fi

trap end_agent EXIT
set +x
