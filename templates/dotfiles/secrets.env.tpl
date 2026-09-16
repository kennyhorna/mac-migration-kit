# Template rendered into a real env file at setup time. Safe to commit: references only, no values.
#
# With a password manager CLI:
#   op inject -i secrets.env.tpl -o ~/.dotfiles-custom/secrets.env && chmod 600 ~/.dotfiles-custom/secrets.env
# Without one: copy this file, fill in the values by hand, and keep it out of git.
EXAMPLE_API_KEY={{ op://Private/example-service/credential }}
