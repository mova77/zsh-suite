# Legacy monolithic entrypoint — prefer loader.zsh
# Kept for compatibility if something sources suite.zsh directly.
_SUITE_DIR="${0:A:h}"
source "$_SUITE_DIR/loader.zsh"
unset _SUITE_DIR
