rex_bin_dir="/Applications/Rex Beta.app/Contents/Helpers/Rex Server.rex/Contents/MacOS"

if [[ -x "$rex_bin_dir/rex" ]] && ! command -v rex >/dev/null 2>&1; then
  path+=("$rex_bin_dir")
fi

unset rex_bin_dir
