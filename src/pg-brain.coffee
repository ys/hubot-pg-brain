# Description:
#   Stores the brain in Postgres
#
# Configuration:
#   DATABASE_URL
#
# Notes:
#   Run the following SQL to setup the table and column for storage.
#
#   CREATE TABLE brain (
#     key TEXT unique,
#     value JSON default '{}'::json,
#     CONSTRAINT brain_pkey PRIMARY KEY (key)
#   )
#
# Author:
#   Yannick Schutz

Postgres = require 'pg'

# sets up hooks to persist the brain into postgres.
module.exports = (robot) ->

  database_url = process.env.DATABASE_URL

  if !database_url?
    throw new Error('pg-brain requires a DATABASE_URL to be set.')

  client = new Postgres.Client(database_url)
  client.connect()
  robot.logger.debug "pg-brain connected to #{database_url}."

  query = client.query("SELECT key, value FROM brain")
  query.on 'row', (row) ->
    data = {}
    data[row.key] = value
    robot.brain.mergeData data
    robot.logger.debug "pg-brain loaded. #{row.key}"

  client.on "error", (err) ->
    robot.logger.error err

  robot.brain.on 'save', (data) ->
    for key, value of data
      query = client.query("INSERT INTO brain(key, value)  VALUES ($1, $2)", [key, value])
      query.on "error", (err) ->
        console.log err
          query = client.query("UPDATE brain SET value = $2 WHERE key = $1", [key, value])
      robot.logger.debug "pg-brain saved. #{key}"

  robot.brain.on 'close', ->
    client.end()
