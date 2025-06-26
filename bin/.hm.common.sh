_include @tm/lib.script.sh

HM_TOOLS_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"
HM_TOOLS_BIN="$HM_TOOLS_HOME/bin"

_cfg_load

# which dir the home git repo is checked out to
HM_TOOLS_GIT_DIR="${HM_TOOLS_GIT_DIR:-$HOME/.home.git}"
HM_TOOLS_GIT_SSH_KEY="${HM_TOOLS_GIT_SSH_KEY:-$HOME/.ssh/id_github}"
HM_TOOLS_BKP_DIR="${HM_TOOLS_BKP_DIR:-$HOME/bkp}"
# preferred editor
HM_TOOLS_EDITOR="${HM_TOOLS_EDITOR:-code}"


# all the dirs which are to be auto tracked by git. That is, anything put in here will automatically be comitted
# no need to call 'home add path/to/file'
HM_TOOLS_AUTO_TRACK_DIRS=("$HOME/bin")
