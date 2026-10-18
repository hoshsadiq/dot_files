_terminal_recovery() {
  # 128+n means the last command was killed by signal n. A TUI that dies this
  # way (OOM abort, SIGSEGV) never runs its own cleanup, so it leaves the pty
  # in raw mode and the terminal with its keyboard/mouse protocols armed. The
  # next prompt then reads stray escape bytes as commands.
  (( $? > 128 )) || return 0

  local tty=/dev/tty
  stty sane < $tty

  # Each \e[<u pops one entry off the kitty keyboard stack (extra pops on an
  # empty stack are ignored). Then turn off SGR mouse, bracketed paste and
  # focus reporting, matching what the dead TUI had pushed.
  print -n '\e[<u\e[<u\e[<u\e[<u\e[?1000l\e[?1002l\e[?1003l\e[?1006l\e[?2004l\e[?1004l' > $tty
}
add-zsh-hook -Uz precmd _terminal_recovery
