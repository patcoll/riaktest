name "base"
description "base role"

run_list %w(
recipe[ubuntu]
recipe[timezone]
recipe[date]
recipe[vim]
recipe[emacs]
)

