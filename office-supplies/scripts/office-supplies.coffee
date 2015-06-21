# Description:
#   What we need in office
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot office add <item_name> - Will add item to the list
#   hubot office remove <item_name> - Will remove item from list
#   hubot office list - Print list of all things we need
#   hubot office clear - Delete list
#
# Author:
#   jan.juna@topmonks.com

datejs        = require 'datejs'
redis         = require 'redis'
listKey       = 'office-supplies-praha'

module.exports = (robot) ->

  robot.respond /office ?(\w+)?( .*)?/i, (msg) ->
    command = msg.match[1]
    item    = if msg.match[2] then msg.match[2].trim() else null
    client  = redis.createClient()

    isFilledItem = (item) ->
      if(!item)
        msg.send 'Tell me more .. second parameter is needed'
        return false

      return true

    sendRedisError = (err) ->
      msg.send 'There was some error when using redis: '+ err.toString()

    add = (name) ->
      client.lpush listKey, name, (err, res) ->
        return sendRedisError(err) if err

        msg.send '>> '+name+' was added to list'

    remove = (name) ->
      client.lrem listKey, 9999, name, (err, res) ->
        return sendRedisError(err) if err

        msg.send '<< '+name+' was removed from list'

    list = () ->
      client.lrange listKey,  0, -1, (err, res) ->
        return sendRedisError(err) if err

        msg.send 'Office list contains:\n '+ res.join('\n ') if res.length
        msg.send 'Office list is empty' if !res.length

    clear = () ->
      client.del listKey, (err) ->
        return sendRedisError(err) if err

        msg.send 'List was deleted'

    switch command
      when 'add' then add item if isFilledItem(item)
      when 'remove' then remove item if isFilledItem(item)
      when 'clear' then clear()
      when 'list' then list()
      else msg.send 'Unknown command .. (badass)'
