import InvalidSignatureException from '../Exceptions/InvalidSignatureException'
import jwt from 'jsonwebtoken'

export default class ValidateSignature

	prop config

	def constructor config
		this.config = config

	def handle request
		try
			const decodedSignature = await jwt.verify(request.signature! ?? '', self.config.get('app.key'))

			const uri = decodedSignature.uri

			if request.urlWithoutSignature! !== uri
				throw new InvalidSignatureException 'Invalid signature'

			return request

		throw new InvalidSignatureException 'Invalid signature'

