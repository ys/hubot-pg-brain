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
#     key TEXT,
#     type TEXT,
#     value JSON default '{}'::json,
#     CONSTRAINT brain_pkey PRIMARY KEY (key, type)
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

  query = client.query "SELECT key, type, value FROM brain", (err, result) =>
    if(err)
      return robot.logger.error('error running query', err)
    data = {}
    for row in result.rows
      data[row.type] ||= {}
      data[row.type][row.key] = row.value
    robot.brain.mergeData data
    robot.logger.debug "pg-brain loaded."

  robot.brain.on 'save', (data) ->
    for type, keyValue of data
      for key, value of keyValue
        query = client.query("INSERT INTO brain(key, type, value)  VALUES ($1, $2, $3)", [key, type, value])
        query.on "error", (err) ->
          console.log err
            query = client.query("UPDATE brain SET value = $3 WHERE key = $1 AND type = $2", [key, type, value])
    robot.logger.debug "pg-brain saved. #{key}"

  robot.brain.on 'close', ->
    client.end()
