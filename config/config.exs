# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :extwitter, :oauth, [
   consumer_key: System.get_env("TWIT_FILT_CONS_KEY"),
   consumer_secret: System.get_env("TWIT_FILT_CONS_SEC"),
   access_token: System.get_env("TWIT_FILT_ACCS_KEY"),
   access_token_secret: System.get_env("TWIT_FILT_ACCS_SEC"),
]


# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :twit_filt, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:twit_filt, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"