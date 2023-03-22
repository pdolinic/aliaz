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
    # Custom 'ad' (aliazchange directory) function to support directory aliases
    # If no argument is provided, use the default 'cd' behavior to navigate to the home directory
    if [ -z "$1" ]; then
        builtin cd
    # If the provided argument is a directory alias, navigate to the aliased directory
    elif [[ -v dir_aliases[$1] ]]; then
        builtin cd "${dir_aliases[$1]}"
    # Otherwise, use the default 'cd' behavior with the provided argument
    else
        builtin cd "$@"
    fi
}

aliaz() {
    # If no arguments are provided, set the alias name to the name of the current directory
    if [ "$#" -eq 0 ]; then
        alias_name=$(basename "$(realpath -e .)")
        dir_path=$(realpath -e .)
    # If one argument is provided, set the alias name to the provided argument and the path to the current directory
    elif [ "$#" -eq 1 ]; then
        alias_name=$1
        dir_path=$(realpath -e .)
    # If two arguments are provided, set the alias name to the first argument and the path to the second argument
    elif [ "$#" -eq 2 ]; then
        alias_name=$1
        dir_path=$(realpath -e $2)
    else
        echo "Usage: aliaz [alias] [path]"
        return
    fi
    # Add the alias and its associated path to the 'dir_aliases' associative array
    dir_aliases[$alias_name]=$dir_path
    # Save the alias to the '.aliaz' file for persistence
    echo "dir_aliases[$alias_name]=\"$dir_path\"" >> ~/.aliaz
    # Display a confirmation message with the created alias and its associated path
    echo "aliaz created: $alias_name -> $dir_path"
}

aliac() {
    # If only one argument is provided, attempt to execute the aliac with the given name
    if [ "$#" -eq 1 ]; then
        if declare -f "$1" >/dev/null; then
            # Execute the aliac if it exists
            eval "$1"
        else
            echo "Unknown parameter: $1"
        fi
    # If more than two arguments are provided, create a new aliac with the given name and command
    elif [ "$#" -gt 2 ]; then
        # Set the command_name variable to the first argument
        command_name=$1
        # Shift the arguments to remove the command_name from the arguments list
        shift
        # Check for the equal sign and remove it from the arguments
        if [ "$1" = "=" ]; then
            shift
        fi
        # Combine the remaining arguments into the command_value variable
        command_value="$*"
        # Add the new aliac to the .command_aliac file for persistence
        echo "function $command_name() { $command_value; }" >> ~/.command_aliac
        # Create the new aliac in the current session
        eval "function $command_name() { $command_value; }"
        echo "Command alias created: $command_name -> $command_value"
    else
        echo "Usage: aliac [alias] [=] [command] [args] or aliac [alias]"
    fi
}

# Create ~/.aliaz || ~/.command_aliac if they do not exist
[ ! -f ~/.aliaz ] && { touch ~/.aliaz; chmod 600 ~/.aliaz; }
[ ! -f ~/.command_aliac ] && { touch ~/.command_aliac; chmod 600 ~/.command_aliac; }

# Load the directory and command aliases into the current session
declare -A dir_aliases command_aliases
source ~/.aliaz
source ~/.command_aliac

# Load the command aliases from the '.command_aliac' file into the current session
while IFS= read -r line; do
    eval "$line"
done < ~/.command_aliac
#--------------------------------------------------------------------------------------------------------------------------------

