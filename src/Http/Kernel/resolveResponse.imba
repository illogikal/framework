import { Mailable } from '@formidablejs/mailer'
import isEmpty from '../../Support/Helpers/isEmpty'
import JsonResponse from '../Response/JsonResponse'
import Redirect from '../Redirect/Redirect'
import Response from '../Response/Response'

const settings = {
	resolvers: []
}

def addResolver resolver
	settings.resolvers.push resolver

exports.addResolver = addResolver

export default def resolveResponse response\any, reply
	for resolver of settings.resolvers
		const results = resolver(response, reply)

		if !isEmpty(results) then return results

	if response instanceof Redirect then return reply.code(response.statusCode).redirect(response.path)

	if response instanceof JsonResponse then return response.toJson(reply)

	if (response instanceof Mailable)
		reply.header('content-type', 'text/html')

		return response.render! ? String(await response.render!) : ''

	if response instanceof Response
		reply.code(response.statusCode)

		if response.data then return response.data;

		return ''

	if response === undefined then return null

	response
