import appVersion from '../../Support/Helpers/version'
import asObject from '../../Support/Helpers/asObject'
import AuthorizationException from '../../Auth/Exceptions/AuthorizationException'
import dot from '../../Support/Helpers/dotNotation'
import FileCollection from './FileCollection'
import isEmpty from '../../Support/Helpers/isEmpty'
import querystring from 'querystring'
import Validator from '../../Validator/Validator'
import wildcard from '../../Support/Helpers/wildcard'
import type { FastifyReply, FastifyRequest } from 'fastify'
import type Repository from '../../Config/Repository'

export default class FormRequest

	prop req\FastifyRequest
	prop request\FastifyRequest
	prop reply\FastifyReply
	prop route = {}
	prop config\Repository
	prop _rules = null

	def constructor request\FastifyRequest, route\Object = {}, reply\FastifyReply, config\Repository
		self.req = request
		self.request = request
		self.reply = reply
		self.route = route
		self.config = config

	get version
		appVersion!

	def passesAuthorization
		if typeof this.authorize === 'function' then return this.authorize!

		false

	def failedAuthorization
		throw new AuthorizationException 'This action is unauthorized.'

	def rules
		{
			#
		}

	def messages
		{
			#
		}

	/**
	 * Get request locale.
	 */
	def locale
		self.request.language.locale

	/**
	 * Get request default locale.
	 */
	def defaultLocale
		self.request.language.fallbackLocale

	/**
	 * Set locale.
	 */
	def setLocale locale\String
		self.request.language.setLocale(locale)

	/**
	 * Set fallback locale.
	 */
	def setFallbackLocale locale\String
		self.request.language.setFallbackLocale(locale)

	/**
	 * Translate text.
	 */
	def translate path\String, default\String
		self.request.language.get(path, default)

	/**
	 * Translate text.
	 */
	def t path\String, default\String
		self.translate(path, default)

	/**
	 * Translate text.
	 */
	def __ path\String, default\String
		self.translate(path, default)

	/**
	 * Get url signature.
	 */
	def signature
		let urlSignature = self.query('signature', null)

		if urlSignature == null || urlSignature == undefined || urlSignature == ''
			urlSignature = self.param('signature') ?? null

		urlSignature

	/**
	 * Get request url.
	 */
	def url
		this.request.url

	/**
	 * Get request url without query.
	 */
	def urlWithoutQuery
		self.url!.includes('?') ? self.url!.split('?')[0] : self.url!

	/**
	 * Get request url without signature.
	 */
	def urlWithoutSignature
		self.signature! ? querystring.unescape(self.url!.split('signature')[0].slice(0, -1)) : self.url!

	/**
	 * Get full request url.
	 */
	def fullUrl
		this.header('host') + this.url!

	/**
	 * Get request method.
	 */
	def method
		this.request.method

	/**
	 * Check if path matches current request path.
	 */
	def isUrl path
		this.url! === '/' + (path.replace /^\s*\/*\s*|\s*\/*\s*$/gm, '')

	/**
	 * Check if path matches current request path.
	 */
	def isFullUrl path
		this.fullUrl! === path.replace /^\s*\/*\s*|\s*\/*\s*$/gm, ''

	/**
	 * Check if method matches current request method.
	 */
	def isMethod method\string
		this.method!.toLowerCase! == method.toLowerCase!

	/**
	 * Get request headers.
	 */
	def headers
		this.request.headers

	/**
	 * Check if header is present.
	 */
	def hasHeader header\string
		this.headers![header.toLowerCase!] ? true : false

	/**
	 * Set request header.
	 */
	def setHeader header\string, value\string
		self.reply.header(header, value)

		this

	/**
	 * Set request headers.
	 */
	def setHeaders headers\object
		const req = this

		Object.keys(headers).forEach do(value)
			req.setHeader(value, headers[value])

		this

	/**
	 * Get specified header.
	 */
	def header header\string, default = null
		this.headers![header] ?? default

	/**
	 * Get bearer token used to authenticate current request.
	 */
	def bearerToken
		const token = self.header('authorization', new String)

		token.startsWith('Bearer ') ? token.split(' ')[1] : new String

	/**
	 * Get request host.
	 */
	def getHost
		this.header 'host'

	/**
	 * Get full request host.
	 */
	def getFullOrigin
		this.header 'origin'

	/**
	 * Get request origin.
	 */
	def getOrigin
		try
			return this.getFullOrigin!.split('://')[1]

		return ''

	/**
	 * Get request origin protocol.
	 */
	def getOriginProtocol
		try
			return this.getFullOrigin!.split('://')[0] + '://'

		return ''

	/**
	 * Get request ip address.
	 */
	def ip
		this.request.ip

	/**
	 * Check if path matches.
	 */
	def pathIs path\string
		wildcard(this.route.path, path)

	/**
	 * Check if request matches specified route.
	 */
	def routeIs route\string
		wildcard(this.route.name ?? '', route)

	/**
	 * Get url param.
	 */
	def param name\String
		self.request.params[name]

	/**
	 * Get all url params.
	 */
	def params
		self.request.params

	/**
	 * Get request body.
	 */
	def body
		self.request.body !== null ? self.request.body : {}

	/**
	 * Get all query and body input.
	 */
	def all
		Object.assign(this.query!, self.body!)

	/**
	 * Get specified input from body.
	 */
	def input key\string|null = null, default = null
		if !key && !default then return self.body!

		dot(asObject(self.body!), key) ?? default

	/**
	 * Check body/query has key.
	 */
	def has key\string
		this.all![key] ? true : false

	/**
	 * Get key from body/query.
	 */
	def get key\string, default = null
		this.all![key] ?? default

	/**
	 * Get specified keys from request.
	 */
	def only keys\string[]
		if (!Array.isArray(keys))
			return []

		let response = {}

		keys.forEach do(key)
			const value = this.all![key]

			if value
				Object.assign response, {
					[key]: value
				}

		response

	/**
	 * Get specified query.
	 */
	def query key\string|null = null, default = null
		if (!key && !default)
			return this.request.query

		let value = this.request.query[key]

		value = value ? querystring.unescape(value) : value

		value ?? default

	/**
	 * Get files.
	 *
	 * @returns {FileCollection[]|[]}
	 */
	def files
		!isEmpty(request.rawFiles) ? Object.values(request.rawFiles) : []

	/**
	 * Get file.
	 *
	 * @returns {FileCollection|null}
	 */
	def file name\String
		!(isEmpty(request.rawFiles) && isEmpty(request.rawFiles[name])) ? request.rawFiles[name] : null

	/**
	 * Check if request has file.
	 *
	 * @returns {Boolean}
	 */
	def hasFile name\String
		!isEmpty(self.file(name))

	/**
	 * Check if request expects a json response.
	 *
	 * @returns {Boolean}
	 */
	def expectsJson
		wildcard(self.header('accept', ''), '*json')

	/**
	 * Validate a request using specified rules.
	 */
	def validate rules\Object|null = null
		const requestRules\Object = isEmpty(rules) ? self.getRules! : rules
		const files\Object = !isEmpty(request._rawFiles) ? request._rawFiles : {}
		const body\Object = Object.assign(self.input! ?? {}, files ?? {})

		Validator.make(body, requestRules, self.messages!)

	/**
	 * Set request rules.
	 *
	 * @param {Object} rules
	 * @returns {FormRequest}
	 */
	def setRules rules\Object
		if self._rules !== null
			throw new Error('FormRequest rules have already been set.')

		self._rules = rules

		self

	/**
	 * Get request rules.
	 *
	 * @returns {Object}
	 */
	def getRules
		self._rules === null ? this.rules! : self._rules

	/**
	 * Get currently authenticated user.
	 */
	def auth
		{
			user: do null
			check: do false
			can: do(perform\String) false
		}
