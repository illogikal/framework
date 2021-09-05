const cookie = require 'fastify-cookie'

module.exports = def hasCookies fastify, config
	fastify.register(cookie, {
		secret: config.get('app.key')
		parseOptions: {
			domain: config.get('session.domain')
			httpOnly: config.get('session.http_only')
			maxAge: config.get('session.lifetime')
			path: config.get('session.path')
			sameSite: config.get('session.same_site')
			secure: config.get('session.secure')
			signed: config.get('session.encrypt')
		}
	})
