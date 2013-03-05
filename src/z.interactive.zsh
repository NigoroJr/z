# -*- mode: sh; sh-shell: zsh; sh-basic-offset: 1 -*-
[ "$_Z_NO_PROMPT_COMMAND" ] || {
 if [ "$_Z_NO_RESOLVE_SYMLINKS" ]; then
  _z_precmd () {
   _z_cmd --add "${PWD:a}"
  }
 else
  _z_precmd () {
   _z_cmd --add "${PWD:A}"
  }
 fi
 precmd_functions+=(_z_precmd)
}

_z_stack () {
 emulate -L zsh
 setopt extended_glob
 local pat nohome score dir
 local -a qlist
 if (( CURRENT == 2 )); then
  pat=${words[$CURRENT]}
  if [[ $pat == //* ]]; then
   pat="/${pat##/#}"
  else
   nohome=t
   pat="*$pat"
  fi
  if [[ $pat == *// ]]; then
   pat="${pat%%/#}/"
  else
   pat="$pat*"
  fi
  pat="(#l)$pat"
  _z_cmd -lr | while read -r score dir; do
   x="$dir/"
   [[ -n "$nohome" && "$x" == "$HOME/"* ]] && x="${x#"$HOME"}"
   if [[ "$x" == ${~pat} ]]; then
    hash -d x= dir=
    qlist+=(${(D)dir})
   fi
  done
  compadd -d qlist -U -Q "$@" -- "${qlist[@]}"
  compstate[insert]=menu
 fi
}

__z_cmd () {
 _alternative \
  'z:z stack:_z_stack -l' \
  'd:directory:_path_files -/'
}

compdef __z_cmd _z_cmd

typeset -g _cd_z_super="${_comps[cd]:-_cd}"

_cd_z () {
 local expl
 $_cd_z_super
 _wanted z expl 'z stack' _z_stack
}

compdef _cd_z cd
