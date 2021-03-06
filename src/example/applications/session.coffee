lib = require('../')
carcass = require('carcass')
express = require('express')
session = require('express-session')
RedisStore = require('connect-redis')(session)
cookieParser = require('cookie-parser')
validValue = carcass.object.validValue

###*
 * Session and cookie.
 *
 * Just an example.
###
module.exports = (options) ->
    validValue(options.name)
    validValue(options.secret)

    ###*
     * App.
    ###
    app = express()

    ###*
     * Cookie parser.
     *
     * Usually useful but not required.
    ###
    # app.use(cookieParser(options.secret))

    ###*
     * HTTP bearer can be used to override session id from cookie. API requests
     * will not have cookies so they need to provide session id in a different
     * way.
    ###
    app.use(lib.middlewares.cookieBearer(options))

    app.use(session({
        name: options.name
        store: new RedisStore(options.redis ? {}),
        secret: options.secret
        cookie: {
            path: '/'
            httpOnly: false # Required for client side JS to access.
            maxAge: null
        }
    }))

    ###*
     * A shortcut to the encoded session id.
    ###
    app.use(lib.middlewares.encodeSID(options))

    ###*
     * API requests will not have cookies so they need to retrieve session id in
     * a different way.
    ###
    app.get('/session', lib.middlewares.sendSession(options))

    return app
