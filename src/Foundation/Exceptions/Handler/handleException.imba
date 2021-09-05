const ConfigRepostory = require '../../../Config/Repository'
const HttpException = require '../../../Http/Exceptions/HttpException'
const StackTrace = require 'stacktrace-js'
const ValidationException = require '../../../Validator/Exceptions/ValidationException'

const settings = {
	config: null
}

def handleException error, request, reply, returns\Boolean = false
	const statusCode = typeof error.getStatus === 'function' ? error.getStatus! : 500

	const response = {
		message: 'An error has occured.'
		exception: error.name
	}

	if error instanceof ValidationException
		response.message = error.message

	elif settings.config.get('app.debug', false)
		response.message = (error.message !== undefined || error.message !== null) ? error.message : response.message

		const stack = await StackTrace.fromError(error)

		response.file    = stack[0].fileName
		response.line    = stack[0].lineNumber
		response.stack   = stack

		console.error error

	elif error instanceof HttpException
		response.message = (error.message !== undefined || error.message !== null) ? error.message : response.message
		delete response.exception

	else
		response.message = 'Internal Server Error'
		delete response.exception

	if returns then return response

	if response.message !== undefined && response.message !== null && response.message.constructor == Object
		return reply.code(statusCode).send(response.message)

	reply.code(statusCode).send(response)

def setConfig config\ConfigRepostory
	if settings.config !== null
		throw new Error 'config repository is already set.'

	settings.config = config

exports.handleException = handleException
exports.setConfig = setConfig
