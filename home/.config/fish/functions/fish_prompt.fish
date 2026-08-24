function fish_prompt
    set_color E6E6E6
    echo -n "$USER"

    set_color 909090
    echo -n "@archlinux "

    set_color C0C0C0
    echo -n "~> "

    set_color normal
end
