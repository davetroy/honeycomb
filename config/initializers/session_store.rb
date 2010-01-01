# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_honeycomb_session',
  :secret      => '5ebe2d18b8c6d0dd70098ed086a2e02e15eaa48c8e3e681ee9ded4214758768d44018f4ccfddf128851160a86ef4a42345a3f330d3eaa38bc0d6a80d203517e6'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
