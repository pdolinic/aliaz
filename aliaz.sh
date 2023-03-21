##This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program. If not, see <https://www.gnu.org/licenses/>.
##
## Authors: pdolinic, GPT-4
##

# Usage: Copy the following Code at the end of your BASHRC or ZSHRC , then Source the BASH or ZSHRC
# Info: This creates a  ~/.aliaz

# Aliaz -start

# Custom 'cd' function to support directory aliases
cd() {
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

# Function to create a directory alias
aliaz() {
    # If no arguments are provided, display usage information
    if [ "$#" -lt 1 ]; then
        echo "Usage: aliaz <alias> [path]"
    else
        # Set the alias name to the first argument
        alias_name=$1
        # If a path is provided as the second argument, set 'dir_path' to the provided path
        if [ "$#" -eq 2 ]; then
            dir_path=$(realpath -e $2)
        # If no path is provided, set 'dir_path' to the current directory
        else
            dir_path=$(realpath -e .)
        fi
        # Add the alias and its associated path to the 'dir_aliases' associative array
        dir_aliases[$alias_name]=$dir_path
        # Save the alias to the '.aliaz' file for persistence
        echo "dir_aliases[$alias_name]=\"$dir_path\"" >> ~/.aliaz
        # Display a confirmation message with the created alias and its associated path
        echo "Alias created: $alias_name -> $dir_path"
    fi
}

# Save aliases between sessions
# If the '.aliaz' file does not exist, create an empty file
if [ ! -f ~/.aliaz ]; then
    touch ~/.aliaz
fi
# Load the aliases from the '.aliaz' file into the current session
declare -A dir_aliases
source ~/.aliaz

## Aliaz -end
