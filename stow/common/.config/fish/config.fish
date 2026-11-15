# Adapted from ad1822/hyprdots (MIT), trimmed: no plugin manager, no personal tooling.
function fish_greeting
    fastfetch
end
if status is-interactive
    fish_vi_key_bindings
    starship init fish | source
    zoxide init fish --cmd cd | source
    abbr -a ga 'git add'
    abbr -a gc 'git commit'
    abbr -a gs 'git status'
    abbr -a gl 'git log --oneline'
    abbr -a v nvim
end
