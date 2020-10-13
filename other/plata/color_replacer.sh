#!/bin/sh
DIR="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"

path=${1:-$DIR}

replace_colors() {
  find "$path" -type f -exec sed -i -- 's/'"$1"'/'"$2"'/g' {} +
}

# selection
replace_colors '#1565c0' '#1565c0'

#accent
replace_colors '#2196f3' '#2196f3'

# suggestion
replace_colors '#01579b' '#01579b'

# destruction
#replace_colors '#f44336' '#f44336'
