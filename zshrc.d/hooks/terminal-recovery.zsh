_terminal_recovery() {
  # 128+n means the last command was killed by signal n. A TUI that dies this
  # way (OOM abort, SIGSEGV) never runs its own cleanup, so it leaves the pty
  # in raw mode and the terminal with its keyboard, mouse and screen modes
  # armed. The next prompt then reads stray escape bytes as commands.
  (( $? > 128 )) || return 0

  local tty=/dev/tty
  stty sane < "$tty"

  # Pop the kitty keyboard stack and turn off SGR mouse, bracketed paste and
  # focus reporting while the dead TUI's screen is still active, so the pops
  # hit the stack it pushed. Then return to the primary screen, where the
  # user's scrollback lives, restore autowrap and show the cursor.
  # The four pops are a bound, not a count: a TUI may push more than once, and
  # the pop that empties the stack resets the flags to 0, which is the state
  # we want.
  print -n '\e[<u\e[<u\e[<u\e[<u\e[?1000l\e[?1002l\e[?1003l\e[?1006l\e[?2004l\e[?1004l\e[?1049l\e[?7h\e[?25h' > "$tty"
}
add-zsh-hook -Uz precmd _terminal_recovery
