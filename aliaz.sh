## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
## You should have received a copy of the GNU General Public License
## along with this program. If not, see <https://www.gnu.org/licenses/>.

## Authors: pdolinic, GPT-4

#--------------------------------------------------------------------------------------------------------------------------------
# Usage: Copy the following Code at the end of your BASHRC or ZSHRC , then Source the BASH or ZSH
#--------------------------------------------------------------------------------------------------------------------------------
# Info: The code creates ~/.aliaz where you can find your aliaz history
#--------------------------------------------------------------------------------------------------------------------------------
# aliaz                # Creates an alias with the name of the current directory pointing to the current directory
# aliaz my_alias       # Creates an alias named "my_alias" pointing to the current directory
# aliaz my_alias ~/example_dir  # Creates an alias named "my_alias" pointing to the "~/example_dir" directory
#--------------------------------------------------------------------------------------------------------------------------------
# aliac my_alias             # Executes the command associated with the "my_alias" alias
# aliac my_alias = command [args] # Creates an alias named "my_alias" with the command "command" and optional arguments "args"
#--------------------------------------------------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------------------------------------------------
# Backup & Remove Duplicates - Keep your ~/.aliaz and ~/.command_aliac Files
#--------------------------------------------------------------------------------------------------------------------------------
# Cleanup ~/.command_aliac
# cp ~/.command_aliac ~/.command_aliac.backup && perl -ne '/^function (\w+)/; $func = $1; print unless $seen{$func}++' ~/.command_aliac > ~/.command_aliac.temp && mv ~/.command_aliac.temp ~/.command_aliac 
#--------------------------------------------------------------------------------------------------------------------------------
# Cleanup ~/.aliaz
# cp ~/.aliaz ~/.aliaz.backup && awk '!seen[$0]++' ~/.aliaz > ~/.aliaz.temp && mv ~/.aliaz.temp ~/.aliaz
#--------------------------------------------------------------------------------------------------------------------------------


#               
#  ▄▄▄       ██▓     ██▓ ▄▄▄      ▒███████▒
# ▒████▄    ▓██▒    ▓██▒▒████▄    ▒ ▒ ▒ ▄▀░
# ▒██  ▀█▄  ▒██░    ▒██▒▒██  ▀█▄  ░ ▒ ▄▀▒░
# ░██▄▄▄▄██ ▒██░    ░██░░██▄▄▄▄██   ▄▀▒   ░
#  ▓█   ▓██▒░██████▒░██░ ▓█   ▓██▒▒███████▒
#  ▒▒   ▓▒█░░ ▒░▓  ░░▓   ▒▒   ▓▒█░░▒▒ ▓░▒░▒
#   ▒   ▒▒ ░░ ░ ▒  ░ ▒ ░  ▒   ▒▒ ░░░▒ ▒ ░ ▒
#   ░   ▒     ░ ░    ▒ ░  ░   ▒   ░ ░ ░ ░ ░
#       ░  ░    ░  ░ ░        ░  ░  ░ ░
#                                 ░

#--------------------------------------------------------------------------------------------------------------------------------
ad() {
    if [ -z "$1" ]; then
        builtin cd
    elif [[ -v dir_aliases[$1] ]]; then
        builtin cd "${dir_aliases[$1]}"
    else
        builtin cd "$@"
    fi
}

aliaz() {
    if [ "$#" -eq 0 ]; then
        alias_name=$(basename "$(cd . && pwd)")
        dir_path=$(cd . && pwd)
    elif [ "$#" -eq 1 ]; then
        alias_name=$1
        dir_path=$(cd . && pwd)
    elif [ "$#" -eq 2 ]; then
        alias_name=$1
        dir_path=$(cd $2 && pwd)
    else
        echo "Usage: aliaz [alias] [path]"
        return
    fi
    dir_aliases[$alias_name]=$dir_path
    echo "dir_aliases[$alias_name]=\"$dir_path\"" >> ~/.aliaz
    echo "aliaz created: $alias_name -> $dir_path"
    hashsum_files
}

aliac() {
    if [ "$#" -eq 1 ]; then
        if declare -f "$1" >/dev/null; then
            eval "$1"
        else
            echo "Unknown parameter: $1"
        fi
    elif [ "$#" -gt 2 ]; then
        command_name=$1
        shift
        if [ "$1" = "=" ]; then
            shift
        fi
        command_value="$*"
        echo "function $command_name() { $command_value; }" >> ~/.command_aliac
        eval "function $command_name() { $command_value; }"
        echo "Command alias created: $command_name -> $command_value"
        hashsum_files
    else
        echo "Usage: aliac [alias] [=] [command] [args] or aliac [alias]"
    fi
}

alial () {
    echo "Directory Aliases:"
    for key in "${!dir_aliases[@]}"; do
        echo "$key -> ${dir_aliases[$key]}"
    done

    echo
    echo "Command Aliases:"
    for key in "${!command_aliases[@]}"; do
        echo "$key -> ${command_aliases[$key]}"
    done
}

if [ "$ZSH_VERSION" ]; then
    alial () {
        echo "Directory Aliases:"
        for key in "${(k)dir_aliases[@]}"; do
            echo "$key -> ${dir_aliases[$key]}"
        done

        echo
        echo "Command Aliases:"
        for key in "${(k)command_aliases[@]}"; do
            echo "$key -> ${command_aliases[$key]}"
        done
    }
fi

aliad () {
    if [ -z "$1" ]; then
        echo "Usage: delete_alias <alias>"
        return
    fi

    if [[ -v dir_aliases[$1] ]]; then
        unset "dir_aliases[$1]"
        sed -i "/dir_aliases\[$1\]/d" ~/.aliaz
        echo "Directory alias '$1' removed."
        hashsum_files
    elif declare -F "$1" >/dev/null; then
        sed -i "/function $1\(\)/,+1d" ~/.command_aliac
        unset -f "$1" 2>/dev/null
        unset "command_aliases[$1]"
        echo "Command alias '$1' removed."
        hashsum_files
    else
        echo "Alias '$1' not found."
    fi
}

hashsum_files() {
    sha256sum ~/.aliaz > ~/.aliaz.sha256
    sha256sum ~/.command_aliac > ~/.command_aliac.sha256
}

load_and_verify() {
    if [ -f ~/.aliaz.sha256 ] && sha256sum --status -c ~/.aliaz.sha256; then
        source ~/.aliaz
    else
        echo "Warning: ~/.aliaz file hash sum mismatch or hash file not found. Not loading aliases."
    fi

    if [ -f ~/.command_aliac.sha256 ] && sha256sum --status -c ~/.command_aliac.sha256; then
        source ~/.command_aliac
    else
        echo "Warning: ~/.command_aliac file hash sum mismatch or hash file not found. Not loading command aliases."
    fi
}

display_hashsums() {
    echo "Hash sum for ~/.aliaz:"
    [ -f ~/.aliaz.sha256 ] && cat ~/.aliaz.sha256 || echo "Hash file not found."

    echo "Hash sum for ~/.command_aliac:"
    [ -f ~/.command_aliac.sha256 ] && cat ~/.command_aliac.sha256 || echo "Hash file not found."
}


[ ! -f ~/.aliaz ] && { touch ~/.aliaz; chmod 600 ~/.aliaz; }
[ ! -f ~/.command_aliac ] && { touch ~/.command_aliac; chmod 600 ~/.command_aliac; }

declare -A dir_aliases command_aliases
load_and_verify

while IFS= read -r line; do
    eval "$line"
    if [[ $line =~ "function ([a-zA-Z0-9_]+)\(\) \{ (.+); \}" ]]; then
        alias_name="${BASH_REMATCH[1]}"
        alias_value="${BASH_REMATCH[2]}"
        command_aliases[$alias_name]="$alias_value"
    fi
done < ~/.command_aliac

display_hashsums
#typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet #add for ZSHRC
#--------------------------------------------------------------------------------------------------------------------------------
