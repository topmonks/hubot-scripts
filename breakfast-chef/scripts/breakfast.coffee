# Description:
#   Who is the current company chef
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot chef - View the current chef
#   hubot chef set - Appoint randomly a new chef
#
# Author:
#   jiri.fabian@topmonks.com

datejs        = require 'datejs'
redis         = require "redis"


module.exports = (robot) ->

  robot.respond /chef( set)?/i, (msg) ->
    force = msg.match[1]
    client = redis.createClient()
    key = "company:cook"

    ttl = () -> Math.round((1).week().fromNow().getTime()/1000)

    isAcceptable = (user) ->
      user['id'] != '1' && user['email_address'] != 'robot@topmonks.com'

    assignCook = (callback) ->
      client.exists key, (error, exists) ->
        if !exists || force
          users = robot.brain.users()
          loop
            user = users[Object.keys(users)[Math.floor(Math.random() * Object.keys(users).length)]]
            break if isAcceptable(user)
          if user
            client.set key, JSON.stringify(user)
            client.expireat user, ttl()
            console.log "New cook set #{user.name}"
            callback(user)
        else
          client.get key, (err, value) ->
            user = JSON.parse(value)
            console.log "Cook already set: #{user.name}"
            callback(user)


    sendResponse = (user) ->
      response = "Current TopMonks (chef) is @#{user.mention_name}"

      msg.send response

    assignCook(sendResponse)
