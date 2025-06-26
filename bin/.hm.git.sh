
__hm_git_ssh_agent(){
    # Check if ssh-agent is running, start it and add key if not.
    if ! ssh-add -l >/dev/null 2>&1; then
        SSH_AGENT_PID_FILE=$(mktemp)  # Create temp file for PID
        eval "$(ssh-agent -s)" >/dev/null
        SSH_AGENT_PID=${!:-}
        echo "$SSH_AGENT_PID" > "$SSH_AGENT_PID_FILE" # Save PID

        if [[ ! -f "$HM_TOOLS_GIT_SSH_KEY" ]]; then
            echo "WARN: Git ssh key '$HM_TOOLS_GIT_SSH_KEY' not found."
        else
            ssh-add "$HM_TOOLS_GIT_SSH_KEY" >/dev/null 2>/dev/null || echo "Error adding ssh key '$HM_TOOLS_GIT_SSH_KEY'."
        fi
        #echo "ssh-agent started and key added (or already present)."

        # Cleanup on exit (robust)
        trap 'if [[ -f "$SSH_AGENT_PID_FILE" ]]; then kill "$SSH_AGENT_PID" 2>/dev/null; rm "$SSH_AGENT_PID_FILE"; fi; exit' INT TERM EXIT

    else
        #ssh-agent already running."
        :
    fi

    #echo "SSH_AUTH_SOCK: $SSH_AUTH_SOCK"
}


#
# For each of the valid git repos found, invoke a command within that repo
#
# $1... - optional commands to run withint he git repo. Falls back to a default command to provide some stats
#
__hm_git_repos_each() {
    while read -r repo_path; do
        _pushd "$repo_path"
        if [[ -n "${1:-}" ]]; then # invoke the commands passed through within the git repo
            bash -c "$@"
        else # fallback to a sensible default command
            echo "$PWD"
            echo -n '     '; git remote -v | grep push
        fi
        _popd
    done < <(__hm_git_find_all_repos)
}

__hm_git_find_all_repos() {
    # filter out non git repos (maybe just a '.git' folder)
    __hm_git_find_possible_repos | while read -r repo_path; do
        _pushd "$repo_path"
        if git rev-parse --git-dir > /dev/null 2>&1; then
        ##if git rev-parse --is-inside-work-tree 2>&1 >/dev/null; then
            echo "$repo_path"
        fi
        _popd
    done
}

# Function to find all git repositories in $HOME
# Excludes common large/cache directories and limits depth.
__hm_git_find_possible_repos() {
  #_debug "Searching for Git repositories in $HOME (max depth 10, excluding common cache/build/vendor dirs)..."
  # -maxdepth 10: Limit recursion depth to prevent excessive search times.
  # \( ... \): Groups conditions for directories to prune.
  # -name "node_modules" -o -name ".cache" ... : Specifies directory names to exclude.
  #   These are common directories that can be very large and are unlikely to contain user-managed git repos
  #   or are repos that are part of a build/dependency system.
  # -path "$HOME/Library/*" ... : Excludes common system/application data folders.
  # -prune: If any of the preceding -name or -path conditions match, do not descend into that directory.
  # -o: OR operator. If -prune was not executed, proceed to the next part.
  # -type d -name ".git": Find directories that are named ".git".
  # -print: Print the path of the found ".git" directory.
  # sed 's|/\.git$||': Removes the trailing "/.git" from each found path to give the actual repository root.
  # sort -u: Sorts the list of repository paths and removes duplicates.
  find "$HOME" -maxdepth 10 \
    \( \
      -name "node_modules" \
      -o -name ".cache" \
      -o -name ".config" \
      -o -name "target" \
      -o -name "build" \
      -o -name ".gradle" \
      -o -name ".m2" \
      -o -name "vendor" \
      -o -name "dist" \
      -o -name "out" \
      -o -name "__pycache__" \
      -o -name ".DS_Store" \
      -o -name ".idea" \
      -o -name ".vscode" \
      -o -name ".svn" \
      -o -name "CVS" \
      -o -path "$HOME/Library/*" \
      -o -path "$HOME/Pictures/*" \
      -o -path "$HOME/Music/*" \
      -o -path "$HOME/Videos/*" \
      -o -path "$HOME/Downloads/*" \
      -o -path "$HOME/.local/share/*" \
      -o -path "$HOME/.var/app/*" \
      -o -path "$HOME/snap/*" \
      -o -path "$HOME/.Trash/*" \
      -o -path "$HOME/.bundle/*" \
      -o -path "$HOME/.gem/*" \
      -o -path "$HOME/.npm/*" \
      -o -path "$HOME/.nvm/*" \
      -o -path "$HOME/.pyenv/*" \
      -o -path "$HOME/.rbenv/*" \
      -o -path "$HOME/.sdkman/*" \
      -o -path "$HOME/go/pkg/*" \
      -o -path "$HOME/go/src/*" \
      -o -path "$HOME/.cargo/registry/*" \
      -o -path "$HOME/.rustup/*" \
    \) -prune \
    -o -type d -name ".git" -print \
    | sed 's|/\.git$||' | sort -u 
  #_debug "Repository search complete."
}
